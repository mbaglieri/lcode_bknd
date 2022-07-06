Promise  = require 'bluebird'
async    = require 'async'

request       = Promise.promisifyAll require 'request'
fs            = Promise.promisifyAll require 'fs'
mongo         = require '../../dbs/mongoose'
config        = require '../../config/config'
{env}         = require '../../config/env'
log           = require('../../tools/log').create 'service.center.general'
jwt           = require 'jsonwebtoken'
randtoken     = require 'rand-token'
data_adapter  = require '../../adapters'
utils         = require '../../tools/utils'
###
  add item to cart by groups or individual for all the types
  {id_subscription}, {user}
###
@change_tx_state = change_tx_state = (id_tx, status, user) ->
  log.i "center.change_tx_state"
  if not id_tx or not status
    return null
  Promise.try ->
    mongo.notification_center.findOne
      _id     : id_tx
      user: user
    .exec()
  .then (notificat) ->
    if not notificat
      throw new Error("NOTIFICATION_NOT_FOUND")
    if status is 'READED'
      notificat.is_readed = true
      notificat.status  = 'INACTIVE'
    else if status is 'UNREADED'
      notificat.is_readed = false
      notificat.status  = 'PENDING'
    else
      notificat.status  = 'ACTIVE'

    notificat.saveAsync() 
  .then (notif_txd) ->
    return notif_txd


