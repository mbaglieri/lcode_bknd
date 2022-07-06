redis  = require './redis'
log    = require('../../tools/log').create 'Broadcast'
Promise  = require 'bluebird'

_publishMessage = (channel, message)->
  log.i "_publishMessage #{channel}"

  if not channel? or not message?
    log.e "channel #{channel} or message :#{JSON.stringify message} FAIL"
    return
  #CHECK IF NEED BE SINGLETON!!
  Promise.try =>
    unless @publisher?
      @publisher = new redis.Publisher()
      log.d "CREATED PUBLISHER"
    @publisher.publish(channel, JSON.stringify(message) )
  .catch (err) =>
    log.e err, "_publishMessage", "channel: #{channel}, message: #{message}"

_generateChannels = (id, typo)->

  channels = [
    "redis.#{typo}"
  ]

  if id?
    channels.push "redis.#{typo}.#{id}"

  return channels

@userChannels= (id) ->
  return _generateChannels id, "user"



@broadcastToUser = ( id, message) ->
  log.i "broadcastToUser"
  log.d "------------------broadcastToUser------------------"
  log.d message
  log.d "------------------broadcastToUser------------------"
  _publishMessage @userChannels( id)[1], message
