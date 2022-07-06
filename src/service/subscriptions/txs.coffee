Promise  = require 'bluebird'
async    = require 'async'

request       = Promise.promisifyAll require 'request'
fs            = Promise.promisifyAll require 'fs'
mongo         = require '../../dbs/mongoose'
config        = require '../../config/config'
{env}         = require '../../config/env'
log           = require('../../tools/log').create 'UserService'
jwt           = require 'jsonwebtoken'
randtoken     = require 'rand-token'
data_adapter  = require '../../adapters'
utils         = require '../../tools/utils'
###
  add item to cart by groups or individual for all the types
  {id_subscription}, {user}
###
@add_item_to_cart = (id, user) ->
  Promise.try ->
    mongo.subscription.findOne
      _id    : id
      status: "ACTIVE"
    .exec()
  .then (subsc) ->
    if not subsc
      throw new Error('NOT_FOUND')
    @subsc = subsc
    _only_one  user, subsc
  .then (is_added) ->
    _add_sub_tx(user,@subsc,is_added)
  .then (subscr_tx) ->
    return subscr_tx

_add_sub_tx = (user, sub, is_added) ->
  if not is_added
    return {}

  Promise.try ->
    mongo.user_subscription_tx
      user           : user
      subscription   : sub
      status         : "PENDING"
      currency       :  sub.currency
      price          :  sub.price
      type           :  sub.type
    .saveAsync()
  .then (subscr_tx) ->
    return subscr_tx

_only_one = (user, subscription) ->
  # if not config.subscription.only_one
  #   return
  elements = subscription.upgrade
  elements3 = elements.concat subscription.downgrade
  elements3.push subscription
  si_list = []

  Promise.try ->
    if config.subscription[subscription.type].accept_by_group
      q =
        group    : subscription.group
        type     : subscription.type
        status   : "ACTIVE"
    else
      q =
        type     : subscription.type
        status   : "ACTIVE"
    mongo.subscription.findOne q
  .then (subsc_l) ->
    @subsc_l = subsc_l
    if config.subscription[subscription.type].accept_by_group
      q1 = 
        user           : user
        type           : subscription.type
        status         : $in: ['PENDING','ACTIVE',  'OVERQUOTA', 'LIMITED']
        subscription   : elements3
    else
      q1 =
        user           : user
        type           : subscription.type
        status         : ['PENDING','ACTIVE',  'OVERQUOTA', 'LIMITED']
    mongo.user_subscription.find q1
    .populate('subscription')
    .exec()
  .then (subscription_item) ->

    si_list = subscription.upgrade.concat subscription.downgrade
    si_list.push f.subscription for f in subscription_item
    si_list.push f1 for f1 in @subsc_l
    si_list.push subscription
    if config.subscription[subscription.type].accept_by_group
      q2 =
        status: "PENDING"
        type  : subscription.type
        user  : user
        subscription: $in: si_list
    else
      q2 =
        status: "PENDING"
        type  : subscription.type
        user: user

    mongo.user_subscription_tx.find q2
    .exec()
  .then (subsc_list) ->
    Promise.all(_deactivate_sub_tx r for r in subsc_list)
  .then (r_maps) ->
    return true
  .catch (err) ->
    return false

_deactivate_sub_tx = (tx) ->
  Promise.try ->
    tx.status = 'DEACTIVATED' 
    tx.saveAsync()
  .then (num) ->
    return num
  .catch (err) ->
    log.e err.stack
    return null