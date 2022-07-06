Promise  = require 'bluebird'
async    = require 'async'

request       = Promise.promisifyAll require 'request'
fs            = Promise.promisifyAll require 'fs'
mongo         = require '../../dbs/mongoose'
config        = require '../../config/config'
{env}         = require '../../config/env'
log           = require('../../tools/log').create 'service.center.notification'
jwt           = require 'jsonwebtoken'
randtoken     = require 'rand-token'
data_adapter  = require '../../adapters'
utils         = require '../../tools/utils'
###
  add item to cart by groups or individual for all the types
  {id_subscription}, {user}
###

###
  @file_owner merchant
  @owner mbaglieri
  Tis class represent the products of the product (each product )
  @data 
###
@add = add = (parms, ctx) ->
  Promise.try ->
   
    mongo.user.findOne  
      _id      : ctx.qtask_user.user
    .exec()
  .then (user) ->
    @user = user
    if not user 
      throw new Error("USER_NOT_FOUND")

    state = parms.state || 0
    if state is 0
      action  = {'type':'match',id:user._id}
      title   = "Message:"
      message = "new match found"
      img     = "#{env.spaces.public_data}avatar/#{utils.randomNum(5)}.png"
    else if state is 1
      action  = {'type':'chat',id:user._id}
      title   = "Message:"
      message = "hey bro, i need some ......"
      img     = "#{env.spaces.public_data}user/#{utils.randomNum(7)}.png"
    else if state is 2
      action  = {'type':'follower',id:user._id}
      title   = "Message:"
      message = "you have a new follower"
      img     = "#{env.spaces.public_data}user/#{utils.randomNum(7)}.png"
    else if state is 3
      action  = {'type':'events',id:user._id}
      title   = "Message:"
      message = "you have a new event"
      img     = "#{env.spaces.public_data}user/#{utils.randomNum(7)}.png"
    else
      action  = {'type':'assistant',id:user._id}
      title   = "Message:"
      message = "you have a new question from your assistant"
      img     = "#{env.spaces.public_data}avatar/#{utils.randomNum(5)}.png"

    json_data = 
      action  : action
      message : message
      title   : title
      img     : img
    
    notif = new mongo.notification_center
      user        : ctx.qtask_user.user
      qtask_user  : ctx.qtask_user
      json_data   : json_data

    if ctx.is_white_label
      notif.network = ctx.community.network

    notif.saveAsync()
  .then (tx) ->
    return tx

@remove = remove = (parms, ctx) ->
  Promise.try ->
    mongo.notification_center.findOne
      id     : parms.id
      user   : ctx.qtask_user.user
    .exec()
  .then (prov) ->
    if not prov 
      throw new Error("NOTIFICATION_NOT_FOUND")
    prov.status   = "INACTIVE"
    prov.saveAsync() 
  .then (user_s) ->
    return user_s

@get = get = (parms, ctx) ->

  perPage = 10
  page    = parms.page || 0
  Promise.try ->
    mongo.network.findOne
      key  :  parms.network_key || env.network
    .exec()
  .then (net) ->
    if not net
      throw new Error("NO_NETOWKR_FOUND")
    @net = net
    if net.key is  env.network
      notif_rq = 
        status : 'PENDING'
        user: ctx.qtask_user.user
    else
      notif_rq =
        status : 'PENDING'
        network: @net.key
        user   : ctx.qtask_user.user

    mongo.notification_center.find notif_rq
    .populate('user qtask_user')
    .select(["-__v","-created_at"])
    .limit(perPage)
    .skip(perPage * page)
    .sort( created_at: 'asc')
    .exec()
  .then (txs) ->
    return txs

