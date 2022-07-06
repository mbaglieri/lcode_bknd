url       = require 'url'
moment    = require 'moment'
Promise   = require 'bluebird'
Q         = require "bluebird-q"
mongo     = require '../dbs/mongoose'
redis     = require '../dbs/redis/redis'
bcast     = require '../dbs/redis/broadcast'

service      = require '../service'
config       = require '../config/config'
log          = require('../tools/log').create 'BaseHandler'

tryLog = (self, fname) -> ->
  try
    self[fname].apply self, arguments

  catch err
    log.e "#{self.constructor.name}.#{fname}: #{err.stack}"

class @BaseHandler
  log: log.create 'BaseHandler'

  constructor: (@socket,@req) ->
    parsed_url = url.parse @req.url, true

    if config.socket.options.show_ip?
      log.w @req.headers['host']
    if @socket?
      @connect_e(@socket, @req)
    else
      log.e "BaseHandler:SOCKET ERROR HANDLER DIDNT EXIST #{parsed_url}"

  onRedisError : (err) ->
    log.e err, "onRedisError", ""

  onConnected: ->
    # If onConnected() returns a Promise, this BaseHandler will wait until
    # its fullfilment before attaching the onMessage callback. This enables
    # async inithailization before messages start flowing in.

    connection_record       = new mongo.Connection
    connection_record.db_id = @params.id
    connection_record.kind  = @kind()
    connection_record.type  = "CONNECTED"
    connection_record.saveAsync()

    Promise.try ->
      @validateLogin()
    .then (login_is_valid) ->
      unless login_is_valid
        @closeSocket 4001, "Invalid User"

    .catch (err) ->
      log.e err, "onConnected", ""

  connect_e: (@socket,@re) ->
    Promise.try ->
      @domain = @req.headers['host']
      @params = @getParams @req.url.split("?")[1]
      log.d @params
      @validateLoginConstructor(@params)
    .then (login_is_valid) ->
      if not login_is_valid
        throw new Error('INVALID_LOGIN')
      service.acl.user.decode_user_pass @params
    .then (data) ->
      service.acl.user.getUserByEmail(data.username)
    .then (user) ->
      if not user
        throw new Error('USER_NOT_FOUND')

      @params.user  = user
      @params.email = user.email
      @params.id    = user.id
      @params.ip   = @req.headers['host'].split(":")[0]
      @_subscriber = new redis.Subscriber tryLog(@, 'onRedisMessage'), @onRedisError
      log.d @params.id
      @channels    = [
        "redis.#{@params.id}",
        "redis.#{@params.id}.#{@kind()}",
      ]

      @socket.on 'close', ->
        tryLog(@, 'onDisconnected')()

      Q.mcall @, 'onConnected'
      .then ->
        @socket.on 'message', tryLog @, 'onMessage'

      .catch (err) ->
        log.d err
        log.e err, "BaseHandler:constructor", "err: #{err.stack}"
        @closeSocket 4000, "4000"
    .catch (err) ->
      log.d err
      log.e err, "BaseHandler:constructor", "err: #{err.stack}"
      @closeSocket 4003, err.message

  getParams: (query) ->
    raw_vars = query.split("&")

    params = {}

    for v in raw_vars
      [key, val] = v.split("=")
      params[key] = decodeURIComponent(val)

    params

  validateLogin: ->

    Promise.try ->
      if !config.socket.validate_login.token
        throw new Error('IS_NOT_VALID')
      @_isLoginValid(@params.token)
    .then (is_valid) ->
      if is_valid
        throw new Error('IS_NOT_VALID')
      return false
    .catch (err) ->
      if err.message is 'IS_NOT_VALID'
        return true
      else
        log.e err, "NOT_DRIVER_FOUND", ""
        return false

  validateLoginConstructor: (args) ->

    Promise.try ->
      if !config.socket.validate_login.token_constructor
        throw new Error('IS_NOT_VALID')
      token = args.split(' ')[1]
      log.d token
      @_isLoginValid(token)
    .then (is_valid) ->
      if is_valid
        throw new Error('IS_NOT_VALID')

      return false
    .catch (err) ->
      if err.message is 'IS_NOT_VALID'
        return true
      else
        return false

  _isLoginValid: (token) ->
    log.d "TOKEN:#{token}"
    Promise.try ->
      models.token.find
        where:
          token   : token
    .then (user) ->
      if not user
        throw new Error('NOT_LOGGED_USER')

      return true
    .catch (err) ->
      if err.message not in ['NOT_LOGGED_USER']
        log.e err, "validateLogin", ""
      return false

  closeSocket : (code, message) ->
    log.d "closeSocket"
    if @socket?
      Q()
      .then ->
        @_subscriber.punsubscribe()
        log.d @_subscriber
        @socket.close(code, message)
      .catch (err) ->
        log.e err, "closeSocket", ""

  onDisconnected: ->
    log.d "onDisconnected"

    Promise.try ->
      connection_record       = new mongo.Connection()
      connection_record.db_id = @params.id
      connection_record.kind  = @kind()
      connection_record.type  = "DISCONNECTED"

      connection_record.saveAsync()
    .then ->
      hai = @params.hai
      hai.status = 'INACTIVE'
      hai.saveAsync()
    .then (hai_s) ->
      log.i "user_disconnected #{@params.email}"

      @_subscriber.punsubscribe()
    .catch (err) ->
      log.e err, "onDisconnected", ""

  subscribe: (channel) ->

    Promise.try ->
      @_subscriber.subscribe channel
    .catch (err) ->
      log.e err, "subscribe", ""


  #mensaje que viene por redis
  onRedisMessage: (channel, message) ->

    Promise.try ->
      @onMessage message, 'redis'
    .catch (err) ->
      log.e err, "onRedisMessage", ""


  send_message: (message) ->
    date_format = moment().format 'MMMM Do YYYY, h:mm:ss a'

    try
      log.i "SOCKET _SEND#{message}"
      if @socket.readyState is @socket.CLOSING
        return
      @socket.send JSON.stringify(message),(err)->
        if err?
          log.i "#{date_format} send_message SEND = message:#{JSON.stringify message}  error:#{err.stack}"
          # log.e err, "send_message", "message:#{JSON.stringify message}","socket state:#{@socket.readyState}"
          @closeSocket 4000, "4000"
    catch e
      log.i "#{date_format} send_message = message:#{JSON.stringify message}  error:#{e.stack}"
      log.e e, "send_message", "message:#{JSON.stringify message}","socket state:#{@socket.readyState}"
      if  'not opened' in e
        log.i "#{date_format} the socket will be close because can't send message"
        if config.socket.options.force_close
          @closeSocket 4000, "4000"


  onMessage: (bytes, source = 'socket') ->
    try
      message = JSON.parse bytes

    catch SyntaxError
      log.e SyntaxError, "onMessage", "bytes: #{@bytes[..50]}(trunc 50), source: #{source}", "Malformed message"
      return

    message.source = source
    try
      if source is 'redis'
        if message.action is 'close'
          @closeSocket message.code, message.reason
          return
        @send_message message
        return

      if not message?.action?
        log.e "Unknown action in #{@constructor.name}"
        return

      if '/' in message.action
        [domain, action] = message.action.split '/'
      else
        action = message.action

      callback = @actions[action]

      if callback?
        callback.call @, message
      else
        log.e "Unknown action #{action} in #{@constructor.name}"
    catch e
      log.e err, "onMessage", ""

  kind: ->
    return "base"

  @action = (type, callback) ->
    # Adds an entry in the class-level registry of callbacks by action type
    # See subclasses for usage
    @prototype.actions = {} unless @prototype.hasOwnProperty 'actions'
    @prototype.actions[type] = (message) ->
      log.d "--------action ws--------"
      log.d message
      log.d "--------action ws--------"
      Promise.try ->
        promise       = callback.call @, message
        record        = message
        record.source = undefined
        action_log    = new mongo.DebugLog(record)

        action_log.type = "action"
        action_log.saveAsync()

        return promise

      .catch (err) ->
        log.i err.stack


