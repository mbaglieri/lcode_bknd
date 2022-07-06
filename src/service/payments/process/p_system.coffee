Promise  = require 'bluebird'
async    = require 'async'

request       = Promise.promisifyAll require 'request'
fs            = Promise.promisifyAll require 'fs'
mongo         = require '../../../dbs/mongoose'
config        = require '../../../config/config'
{env}         = require '../../../config/env'
log           = require('../../../tools/log').create 'p_system'
jwt           = require 'jsonwebtoken'
randtoken     = require 'rand-token'
data_adapter  = require '../../../adapters'
utils         = require '../../../tools/utils'
card          = require './card'
###
  add item to cart by groups or individual for all the types
  {id_subscription}, {user}
###
@process_system =  process_system = (parms, user) ->
  log.i "process_system"
  if not parms.type or  parms.type is not 'SYSTEM'
    log.i "_process_system #{parms.type}"
    return {}
  u_subscr = []
  Promise.try ->
    card.get_or_add(parms, user)
  .then (card) ->
    @card_it = card
    if not card
      throw new Error('NOT_FOUND')
    mongo.user_subscription_tx.find
      user        : user
      type           : "SYSTEM"
      status         : "PENDING"
    .populate('user_subscription subscription')
    .exec()
  .then (subscr_tx) -> 
    if not subscr_tx or subscr_tx.length is 0
      throw new Error("NOT_FOUND")
    for f in subscr_tx
      if f.user_subscription
        u_subscr.push f.user_subscription
    @subscr_tx = subscr_tx
    #add or edit subscription
    Promise.all( _add_new_user_subscription tx for tx in @subscr_tx )
  .then (rn_u_s_li) ->
    #mark tx paid
    Promise.all( _paid(tx_, user, parms.id_card, 'SYSTEM', @card_it)  for tx_ in @subscr_tx )
  .then (recpnt) ->
    return recpnt

_add_new_user_subscription = (tx) ->
  log.i "_add_new_user_subscription"
  Promise.try ->
    #TODO: PROCESS PAYMENT
    mongo.user_subscription.findOne 
      user           : tx.user
      status         : ['PENDING','ACTIVE',  'OVERQUOTA',  'LIMITED']
      subscription   : tx.subscription
    .exec()
  .then (subscr_tx) ->
    if not subscr_tx
      subscr_tx = mongo.user_subscription
        user           : tx.user
        subscription   : tx.subscription
        tx             : tx
        plan           : tx.subscription.type_operation
        type           : tx.type
        expiration_date: set_expiration_date(tx.subscription.type_operation)
        status         : "ACTIVE"
    else
      subscr_tx.expiration_date =  set_expiration_date(tx.subscription.type_operation)
      subscr_tx.status          = "ACTIVE"
      subscr_tx.tx              = tx

    subscr_tx.saveAsync()
  .then (subscr_tx) ->
    @subscr_tx = subscr_tx
    tx.user_subscription = subscr_tx
    #TODO: ADD NOTIFICATION AARRR
    tx.saveAsync()
  .then (tx_) ->
    @tx_ = tx_
    _add_user_subscription_history(tx_)
  .then (tx_) ->
    return @tx_

_add_user_subscription_history= (tx) ->
  Promise.try ->
    mongo.user_subscription_history 
      user           : tx.user_subscription.user
      subscription   : tx.user_subscription.subscription
      tx             : tx
      plan           : tx.user_subscription.subscription.type_operation
      type           : tx.user_subscription.type
      expiration_date: tx.user_subscription.expiration_date
      status         : tx.user_subscription.status
    .saveAsync()
  .then (u_subscr_tx_hiistory) ->
    return u_subscr_tx_hiistory

_paid = (txs, user,id_card,type_op, card_it) ->
  Promise.try ->
    #add payment 
    txs.card   = card_it
    txs.status = "PAID"
    txs.saveAsync()
  .then (subscr_tx_s) ->
    return subscr_tx_s
    
_find_add_card = (parms, user) -> 
  Promise.try ->
    mongo.user_payment_method.findOne 
      _id    : parms.id_card
      user   : user
      status : $in: ['PENDING','ACTIVE']
    .exec()
  .then (card) ->
    if not card
      throw new Error('NOT_FOUND')
    return card


@set_expiration_date = set_expiration_date = (type_operation) ->
  switch type_operation
    when 'ONE_TIME' then return utils.getQueryDayAfterXDays(30)
    when 'RESERVATION' then return utils.getQueryDayAfterXDays(7)
    when 'MONTHLY' then return utils.getQueryDayAfterXDays(30)
    else  return  utils.getQueryDayAfterXDays(360)
