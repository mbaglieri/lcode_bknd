Promise  = require 'bluebird'
async    = require 'async'

request       = Promise.promisifyAll require 'request'
fs            = Promise.promisifyAll require 'fs'
mongo         = require '../../../dbs/mongoose'
config        = require '../../../config/config'
{env}         = require '../../../config/env'
log           = require('../../../tools/log').create 'card'
jwt           = require 'jsonwebtoken'
randtoken     = require 'rand-token'
data_adapter  = require '../../../adapters'
utils         = require '../../../tools/utils'
###
  card management
  {id_subscription}, {user_id}
###

@get_or_add = get_or_add = (parms, user) ->
  where = 
    user   : user   
  Promise.try ->
    if parms.id_card
      where._id = parms.id_card
    else
      where.is_primary
    mongo.user_payment_method.findOne where
    .exec()
  .then (paymt_methd_t) ->
    if not paymt_methd_t
      if not parms.card
        throw new Error("NOT_FOUND")
      json_data = 
        mmyy  : parms.mmyy   || ''
        holder: parms.holder || ''
        code  : parms.code   || ''
        
      paymt_methd_t = mongo.user_payment_method
        user           : user   
        card           : parms.card
        is_primary     : true
        json_data      : json_data
    paymt_methd_t.saveAsync()
  .then (subscr_tx) ->
    return subscr_tx
  .catch (err) ->
    return null

@add_card = add_card = (parms, is_primary, user) ->
  Promise.try ->
    mongo.user_payment_method.findOne
      user      : user   
      is_primary: true 
      status : 
        $nin : ['DEACTIVATED','OVERQUOTA']
    .exec()
  .then (paymt_methd_t) ->
    if not paymt_methd_t
      is_primary = true
    mongo.user_payment_method.findOne
      user   : user   
      card   : parms.card
    .exec()
  .then (paymt_methd) ->
    json_data = 
      mmyy  : parms.mmyy   || ''
      holder: parms.holder || ''
      code  : parms.code   || ''
    if not paymt_methd
      paymt_methd = mongo.user_payment_method
        user           : user   
        card           : parms.card
        is_primary     : is_primary
        json_data      : json_data
    else
      paymt_methd.json_data  = json_data
      paymt_methd.is_primary = is_primary
      paymt_methd.status     = "ACTIVE"
      paymt_methd.markModified("json_data")
    paymt_methd.saveAsync()
  .then (subscr_tx) ->
    return subscr_tx

@edit_card = edit_card = (parms, is_primary, user) ->
  Promise.try ->
    mongo.user_payment_method.findOne 
      _id    : parms.id
      user   : user   
    .exec()
  .then (payment_method) ->
    if not payment_method
      throw new Error("NOT_FOUND")
    @pmthd = payment_method
    _set_card_secundary(user   , is_primary)
  .then (payment_method) ->
    _find_another_to_set_primary user   , @pmthd, parms.status,  is_primary
  .then (is_primary_r) ->
    is_primary = is_primary_r
    @pmthd.is_primary = is_primary
    if parms.mmyy
      @pmthd.json_data.mmyy   = parms.mmyy
      @pmthd.markModified("json_data")
    if parms.holder
      @pmthd.json_data.holder   = parms.holder
      @pmthd.markModified("json_data")
    if parms.code
      @pmthd.json_data.code   = parms.code
      @pmthd.markModified("json_data")
    if parms.card
      @pmthd.card    = parms.card
    if parms.status
      @pmthd.status    = parms.status
    @pmthd.saveAsync()
  .then (payment_method) ->
    return payment_method

_find_another_to_set_primary = (user   , card, status, is_primary) ->
  if not status or status is not 'DEACTIVATED'
    return is_primary
  Promise.try ->
    mongo.user_payment_method.findOne
      user   : user   
      status : 
        $nin: ['DEACTIVATED','OVERQUOTA']
      _id     : 
        $nin: [card]
    .exec()
  .then (paymt_methd_t) ->
    if not paymt_methd_t  
      if config.subscription['SYSTEM'].on_remove_alow_empty
        throw new Error("ALLOW_EMPTY")
    paymt_methd_t.is_primary = true
    paymt_methd_t.saveAsync()
  .then (paymt_methd_t1) ->
    mongo.user_payment_method.updateMany( { 
      user   : user   ,id: card},
      {  is_primary:false}
    )
  .then (updated) ->
    return false
  .catch (err) ->
    if err.message in ['ALLOW_EMPTY']
      return is_primary
    else
      throw new Error("NOT_EMPTY_ALLOWED")


_set_card_secundary = (user   , set_secundary) ->
  if not set_secundary
    return true
  Promise.try ->
    log.i "_set_card_secundary"
    mongo.user_payment_method.updateMany( { 
      user   : user   },
      {  is_primary:false}
    )
  .then (updated) ->
    return true