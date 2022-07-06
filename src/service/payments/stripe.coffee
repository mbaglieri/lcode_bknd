Promise  = require 'bluebird'
async    = require 'async'

request       = Promise.promisifyAll require 'request'
fs            = Promise.promisifyAll require 'fs'
mongo         = require '../../dbs/mongoose'
config        = require '../../config/config'
{env}         = require '../../config/env'
log           = require('../../tools/log').create 'StripeService'
jwt           = require 'jsonwebtoken'
randtoken     = require 'rand-token'
data_adapter  = require '../../adapters'
utils         = require '../../tools/utils'
###
  add item to cart by groups or individual for all the types
  {id_subscription}, {user}
###
@payment = (parms, user) ->
  Promise.try ->
    _process(parms, user)
  .then (pmnt) ->
    return pmnt
