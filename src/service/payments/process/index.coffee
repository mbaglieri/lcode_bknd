Promise  = require 'bluebird'
async    = require 'async'

request       = Promise.promisifyAll require 'request'
fs            = Promise.promisifyAll require 'fs'
mongo         = require '../../../dbs/mongoose'
config        = require '../../../config/config'
{env}         = require '../../../config/env'
log           = require('../../../tools/log').create 'ProcessService'
jwt           = require 'jsonwebtoken'
randtoken     = require 'rand-token'
data_adapter  = require '../../../adapters'
utils         = require '../../../tools/utils'
systm         = require './p_system'
@card         = require './card'
###
  add item to cart by groups or individual for all the types
  {id_subscription}, {user}
###
@payment = (parms, user) ->
  Promise.try ->
    _process(parms, user)
  .then (pmnt) ->
    return pmnt

@pay  = (user_subscr, tx) ->
  Promise.try ->
    # TODO: PROCESS PAYMENT
    user_subscr.status = 'ACTIVE'
    user_subscr.expiration_date = systm.set_expiration_date(user_subscr.plan)
    user_subscr.saveAsync()
  .then (pmnt) ->
    tx.status = 'PAID'
    tx.saveAsync()
  .then (pmnt) ->
    return pmnt

_process = (parms,user) ->
  switch parms.type
    when 'MERCHANT' then return _process_merchant(parms,user)
    when 'COMMUNITY' then return _process_community(parms,user)
    when 'ENVIRONMENT' then return _process_environment(parms,user)
    else  return  systm.process_system(parms,user)

_process_merchant = (parms,user) ->
  if  parms.type is not 'MERCHANT'
    return {}

_process_community = (parms,user) ->
  if  parms.type is not 'COMMUNITY'
    return {}

_process_environment = (parms,user) ->
  if  parms.type is not 'ENVIRONMENT'
    return {}

