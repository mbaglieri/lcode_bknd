Promise   = require 'bluebird'
moment    = require 'moment'
request   = require 'request'
requestPM = Promise.promisifyAll require 'request'
config    = require '../../../../config/config'
mongo     = require '../../../../dbs/mongoose'
utils     = require '../../../../tools/utils'
jwt       = require 'jsonwebtoken'

@refreshToken = (req,res) ->
  bdy_token      = req.body.token or req.query.token
  firebase_token = req.body.firebase_token or req.query.firebase_token || ''
  device_key     = req.body.device_key  or req.query.device_key        || 'WEB'
  Promise.try ->
    mongo.refresh_token.findOne
      value  : bdy_token
    .populate('user')
    .exec()
  .then (r_token) ->
    @r_token = r_token
    if not r_token
      throw new Error("NO_HAI_TYPE_EVENT_FOUND")

    
    @person  = r_token.user
    json_usr = @person.toJSON()
    @token_j = jwt.sign json_usr, config.express.session_secret
    ip       = utils.get_ip_req(req)
    token = new mongo.token(
      refresh_token : bdy_token
      value         : @token_j
      client        : r_token.user
      user          : r_token.user
      network       : @r_token.network
      community     : @r_token.community
      environment   : @r_token.environment
      firebase_token: firebase_token
      token_type    : device_key
      ip            : ip
      ip_json       : utils.get_ip_info(ip)
      )
    token.saveAsync()
  .then (token_m) ->
    returnset = {
      status    : 200,
      token     : token_m.value,
      refresh_token: token_m.refresh_token
      status    : @person.status
      validation: @person.validation
    }
    res.send returnset

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
