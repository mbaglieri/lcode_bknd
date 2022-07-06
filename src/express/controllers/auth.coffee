Promise        = require 'bluebird'
passport       = require 'passport'
BasicStrategy  = require('passport-http').BasicStrategy
BearerStrategy = require('passport-http-bearer').Strategy
config         = require '../../config/config'
mongo          = require '../../dbs/mongoose'
jwt            = require 'jsonwebtoken'
log            = require('../../tools/log').create 'auth'
utils          = require '../../tools/utils'
service        = require '../../service'

###*
# Return a unique identifier with the given `len`.
#
#     utils.uid(10);
#     // -> "FDaS435D2z"
#
# @param {Number} len
# @return {String}
# @api private
###

uid = (len) ->
  buf = []
  chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
  charlen = chars.length
  i = 0
  while i < len
    buf.push chars[getRandomInt(0, charlen - 1)]
    ++i
  buf.join ''

###*
# Return a random int, used by `utils.uid()`
#
# @param {Number} min
# @param {Number} max
# @return {Number}
# @api private
###

getRandomInt = (min, max) ->
  Math.floor(Math.random() * (max - min + 1)) + min

#OAUTH2 IMPLEMENTATION REVIEW !!!
passport.use 'client-basic', new BasicStrategy (username, password, callback) ->
  log.d "client-basic"
  Promise.try ->
    mongo.Client.findOne
      id: username
    .exec()
  .then (client) ->
    if !client or client.secret != password
      return callback null, false

    return callback null, client
  .catch (err) ->
    return callback err

#waring (node:56572) Warning: a promise was created in a handler at node:internal/timers:
passport.use 'bearer', new BearerStrategy (accessToken, callback) ->
  Promise.try ->
    service.acl.user.bearer_user(accessToken)
  .then (person) ->
    return callback(null, person)

passport.use 'admin', new BearerStrategy (accessToken, callback) ->
  Promise.try ->
    service.acl.user.bearer_admin(accessToken)
  .then (person) ->
    return callback(null, person)

@isClientAuthenticated = passport.authenticate('client-basic', { session : false })
@isBearerAuthenticated = passport.authenticate('bearer', { session: false })
@isBearerAdmin = passport.authenticate('admin', { session: false })
