Promise = require 'bluebird'
base    = require './base'
utils   = require '../tools/utils'
crypto  = require 'crypto'
mongo   = require '../dbs/mongoose'
redis   = require '../dbs/redis/redis'
bcast   = require '../dbs/redis/broadcast'
service = require '../service'
config  = require '../config/config'
log     = require('../tools/log').create 'UserHandler'

class @UserHandler extends base.BaseHandler
  log: log.create 'UserHandler'
  kind: =>
    super()
    return "user"

  onConnected: ->
    Promise.try =>
      super()
      utils.closeConnection 'user', @params.id
      if not @params.user
        throw new Error('NOT_USER_FOUND')

      @channels = bcast.userChannels(@params.id)
      Promise.all( @subscribe channel for channel in @channels)
    .then (channls) =>
      log.i "User logged in "
    .catch (err) =>
      log.i  "connect user #{err} #{JSON.stringify @params}"

      if @socket?
        try
          @closeSocket 4000, "4000"
        catch e
          log.e e, "onConnected", ""

  closeSocket: (code, message) ->
    super()

  onDisconnected: ->
    super()
    log.d "Connection closed"

  onDisconnected: ->
    super()
    log.d "Connection closed"

  validateToken: (token, operation) ->
    if token != @params.token
      throw new Error("Invalid Token")

    if token != operation.user.token
      throw new Error("Invalid Token for operation")

  validateHmac: (text, key, hmac) ->
    if hmac != @createHmac text, key, hmac
      throw new Error("Invalid HMAC!")

  createHmac: (text, key) ->
    hash = crypto.createHmac('sha1', key).update(text).digest('base64')
    return hash

  @action 'ping', (message) ->
    log.i "ping : #{message}"
    if not @params.id
      return
    id  = @params.id
    Promise.try ->
      service.user.updateUserByPing message, id
    .then (user) ->

      log.d "Ping Success #{message}"
    .catch (err) ->
      log.e "UserHandler:Ping : #{err}"

  @action 'pong', (message) ->
    log.i  "pong : #{message}"
    if not @params.id
      return
    id = @params.id
    Promise.try ->
      service.user.updateUserByPing( message, id)
    .then (user) ->

      log.d "PONG OK  #{message}"
    .catch (err) ->
      log.e "UserHandler:Ping : #{err.stack}"

  @action 'send_message', (message) ->
    log.d "send_message"
    if not @params.id
      return
    id = @params.id
    Promise.try ->
      
      log.d "msg"
    .catch (err) =>
      log.e  "send_message #{err.stack}"

  @action 'ReadMessage', (message) ->
    log.d "User:ReadMessage: #{message}"

  @action 'ackPushMessageReceived', (message) ->
    log.d "ackmsg"
