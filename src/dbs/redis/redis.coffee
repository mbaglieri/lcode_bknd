redis  = require 'redis'
config = require '../../config/config'
log    = require('../../tools/log').create 'Redis'

createClient = () ->
  redis.createClient config.redis.port, config.redis.host


class @Subscriber
  constructor: (@callback, @onError) ->

  subscribe: (channel) ->
    log.i "Suscribed to #{channel}"

    if not @subscriber?
      @subscriber = createClient()
      @subscriber.on 'message', @callback
      @subscriber.on 'error', @onError
      @subscriber.on "punsubscribe", (pattern, count) -> log.d "punsubscribed from #{count} channels"
    @subscriber.subscribe channel

  punsubscribe:->
    log.d "punsubscribe"
    @subscriber.punsubscribe() if @subscriber?
    @stop()

  stop: ->
    log.d "stop"
    @subscriber.quit() if @subscriber?

class @Publisher
  constructor: () ->
    @publisher = createClient()


  publish: (channel, message) ->
    @publisher.publish channel, message
