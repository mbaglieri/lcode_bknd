Promise  = require 'bluebird'
async    = require 'async'

request       = Promise.promisifyAll require 'request'
fs            = Promise.promisifyAll require 'fs'
mongo         = require '../../dbs/mongoose'
config        = require '../../config/config'
{env}         = require '../../config/env'
log           = require('../../tools/log').create 'service.qtask.qtask_user'
jwt           = require 'jsonwebtoken'
randtoken     = require 'rand-token'
data_adapter  = require '../../adapters'
utils         = require '../../tools/utils'

@get_create =(user) ->
  Promise.try ->
    mongo.qtask_user.findOne({ user   : user}).exec()
  .then (hai) ->
    if not hai
      hai = new mongo.qtask_user
        user   : user
        status : 'INTRO'
        enabled: true

    hai.saveAsync()
  .then (hai_) ->
    return hai_
