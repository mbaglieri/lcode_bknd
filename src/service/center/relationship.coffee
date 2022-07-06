Promise  = require 'bluebird'
async    = require 'async'

request       = Promise.promisifyAll require 'request'
fs            = Promise.promisifyAll require 'fs'
mongo         = require '../../dbs/mongoose'
config        = require '../../config/config'
{env}         = require '../../config/env'
log           = require('../../tools/log').create 'service.center.relationship'
jwt           = require 'jsonwebtoken'
randtoken     = require 'rand-token'
data_adapter  = require '../../adapters'
utils         = require '../../tools/utils'
###
  add item to cart by groups or individual for all the types
  {id_subscription}, {user}
###
@add = add = (parms, ctx) ->
  log.i "add"
  Promise.try ->

    mongo.user.findOne 
      id: parms.id
    .exec()
  .then (user) ->
    @user = user
    if not user 
      throw new Error("USER_NOT_FOUND")

    mongo.user_connect.findOne 
      connection: @user.dataValues.id
      user      : ctx.qtask_user.user
    .exec()
  .then (connect) ->
    @connect = connect
    if not connect 
      @connect =  new mongo.user_connect
        connection: @user.dataValues.id
        user      : ctx.qtask_user.user

    if @connect.status is 0
      @connect.status = 1
    else
      @connect.status = 0

    @connect.saveAsync()
  .then (user_s) ->
    getOne(user_s.id)    
  .then (tx1) ->
    return tx1

@get = get = (parms, ctx) ->
  log.i "service.center.relationship.get"
  if not parms.nickname
    return []

  perPage = 10
  page    = parms.page || 0
  q = 
    user   : parms.user
    status : $in: [0,1]
  Promise.try ->

    mongo.user_connect.countDocuments q
  .then (count_) ->
    @count_ = count_

    mongo.user_connect.find q
    .populate('user connection')
    .select(["-__v","-created_at"])
    .limit(perPage)
    .skip(perPage * page)
    .sort( created_at: 'asc')
    .exec()
  .then (users) ->
    r = 
      count: @count_
      data : users
    return r

@getv1 = getv1 = (parms, ctx) ->
  log.i "service.center.relationship.get"
  if not parms.nickname
    return []

  perPage = 10
  page    = parms.page || 0
  q = 
    user   : ctx.qtask_user.user
    status : 0
  Promise.try ->
    mongo.user.findOne
      nickname: parms.nickname
    .exec()
  .then (usr) ->
    q.user = usr
    if not usr
      throw new Error("NO_NETOWKR_FOUND")
    mongo.user_connect.find q
    .populate('user connection')
    .select(["-__v","-created_at"])
    .limit(perPage)
    .skip(perPage * page)
    .sort( created_at: 'asc')
    .exec()
  .then (users) ->
    return users
  .catch (err) ->
    return []

@profile = profile = (parms, ctx) ->
  log.i "service.center.relationship.profile"
  if not parms.id
    return []

  
  parms.page     = Math.max(0, parms.page)
  parms.limit    = parseInt(parms.limit) || 10
  Promise.try ->
    mongo.user.findOne 
      _id: parms.id
    .exec()
  .then (usr) ->
    @usr = usr
    #TODO: REQUEST API NO_CODE
    return []
  .catch (err) ->
    return []

@analytics = analytics = (parms, ctx) ->
  Promise.try ->
    if parms.id_product
      q = 
        user   : 
          $ne : ctx.qtask_user.user
        id_product: parms.id_product
    else if parms.id_tx
      q = 
        user: 
          $ne : ctx.qtask_user.user
        id_tx  : parms.id_tx
    else
      q = 
        user: ctx.qtask_user.user

    # TODO: ADD ANALYTICS OF CONNECTIONS VIEWS 
    mongo.user_connect.find q
    .exec()
  .then (txs) ->
    for tx in txs
      stars_attr_0 = stars_attr_0 + tx.stars_attr_0
      stars_attr_1 = stars_attr_1 + tx.stars_attr_1
      stars_attr_2 = stars_attr_2 + tx.stars_attr_2
    dat = 
      stars_attr_0: (stars_attr_0/txs.length) || 0
      stars_attr_1: (stars_attr_1/txs.length) || 0
      stars_attr_2: (stars_attr_2/txs.length) || 0
    return dat
  .catch (err) ->
    return []
