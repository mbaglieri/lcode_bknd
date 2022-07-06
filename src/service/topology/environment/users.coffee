Promise  = require 'bluebird'
async    = require 'async'

request       = Promise.promisifyAll require 'request'
fs            = Promise.promisifyAll require 'fs'
mongo         = require '../../../dbs/mongoose'
qtask         = require '../../qtask'
config        = require '../../../config/config'
{env}         = require '../../../config/env'
log           = require('../../../tools/log').create 'service.center.general'
jwt           = require 'jsonwebtoken'
randtoken     = require 'rand-token'
data_adapter  = require '../../../adapters'
utils         = require '../../../tools/utils'
###
###
   

@get = (argss, user) ->
  d_json = {
    status: 200
  }
  perPage = 10
  page    = argss.page || 0
  Promise.try ->
    q_env = 
      _id: argss.id

    mongo.environment.findOne q_env
    .populate('community')
    .exec()
  .then (environment) ->
    if not environment
      throw new Error("NO_ENVIRONMENT_FOUND")
    @environment = environment
    if argss.status
      @q1 = 
        environment: @environment
        status         : $in: argss.status.split ','
    else
      @q1 =
        environment: @environment
        status         : ['UNSUB', 'SUB','DENIED','WRONG_URL','BANNED']
    mongo.environment_user.find @q1
    .select(["-__v","-created_at"])
    .limit(perPage)
    .skip(perPage * page)
    .sort( created_at: 'asc')
    .exec()
  .then (environment_user) ->
    @environment_user = environment_user

    mongo.user_guest.countDocuments @q1
  .then (count_user_guest) ->
    returnset = {
      data        : @environment_user
      count       : count_user_guest
      current_page: page
      status      : 200
    }
    return returnset

  .catch (err) ->
    console.log err.stack
    if err.message in ['NO_COMMUNITY_FOUND']
      d_json.status = 404
    if err.message in ['NO_ACTIVE']
      d_json.status = 400
    if err.message in ['PASS_WRONG']
      d_json.status = 1
    log.e "GET environments: #{err.stack}"
    return null

@add = (argss, admin) ->
  d_json = {
    status: 200
  }
  Promise.try ->
    q_env = 
      _id: argss.id
 
    mongo.environment.findOne q_env
    .populate('community')
    .exec()
  .then (environment) ->
    if not environment
      throw new Error("NO_ENVIRONMENT_FOUND")
    @environment = environment
    mongo.community.findOne environment.community
    .populate('network')
    .exec()
  .then (community) ->
    if not community
      throw new Error("NO_ENVIRONMENT_FOUND")
    @community = community
    q = 
      email  : argss.email
    mongo.user.findOne q
    .exec()
  .then (user) ->
    if not user
      data = argss
      delete data['id']
      data.username = data.email
      data.background_img = data.background_img || env.spaces.img_profile_back
      user = mongo.user data
    user.saveAsync()
  .then (user_s) ->
    @user = user_s
    #get the value and hide for user password
    @show_data =  user_s
    if argss.status
      @q1 = 
        user       : user_s
        environment: @environment
        status     : $in: argss.status.split ','
    else
      @q1 =
        user       : user_s
        environment: @environment
        status         : ['UNSUB', 'SUB','DENIED','WRONG_URL','BANNED']
    mongo.environment_user.findOne @q1
    .exec()
  .then (environment_d) ->
    @environment_d = environment_d
    if not @environment_d 
      environment_d  = new mongo.environment_user(
        user       : @user,
        key        : @environment.key,
        community  : @environment.community,
        environment: @environment,
        status     : "SUB"
      )
      if @environment.algorithm.env_type in ['public_pass','private_pass']
        environment_d.cfg =  {
          pass: @environment.algorithm.env_pass || ''
        }
    else
      environment_d.status = argss.status || 'SUB'
    environment_d.saveAsync()
  .then (environment_user) ->
    @environment_user = environment_user
    mongo.community_user.findOne( user: @user, community: @environment.community).exec()
  .then (community_user) ->
    if not community_user
      community_user           = new mongo.community_user()
      community_user.user      = @user
      community_user.key       = @environment.community.key
      community_user.community = @environment.community
      community_user.network   = @network
      community_user.status    = 'SUBSCRIBED'
      if @environment.community.cfg.type in ['public_pass','private_pass','private']
        community_user.cfg =  {
          pass: user.pass || '',
          url_server: user.url_server  || @environment.community.cfg.url
        }
    else
      community_user.status    = 'SUBSCRIBED'

    community_user.saveAsync()
  .then (community_user_) ->
    @community_user_ = community_user_
    mongo.network_user.findOne( user: user, network: @community.network).exec()
  .then (network_user) ->
    if not network_user
      network_user        = new mongo.network_user()
      network_user.user   = user
      network_user.key    = @community.network.key
      network_user.network= @community.network
      network_user.status = 'SUBSCRIBED'
      network_user.cfg    = 
        pass      : @community.network.cfg.pass
        url_server: @community.network.cfg.url
    else
      community_user.status    = 'SUBSCRIBED'

    network_user.saveAsync()
  .then (network_user_) ->
    return @environment_user

  .catch (err) ->
    if err.message in ['NO_COMMUNITY_FOUND']
      d_json.status = 404
    if err.message in ['NO_ACTIVE']
      d_json.status = 400
    if err.message in ['PASS_WRONG']
      d_json.status = 1
    log.e "GET environments: #{err.stack}"
    return null
    
@remove = (argss, admin) ->
  d_json = {
    status: 200
  }
  Promise.try ->
    q_env = 
      _id: argss.id

    mongo.environment.findOne q_env
    .populate('community')
    .exec()
  .then (environment) ->
    if not environment
      throw new Error("NO_ENVIRONMENT_FOUND")
    @environment = environment
    mongo.community.findOne environment.community
    .populate('network')
    .exec()
  .then (community) ->
    if not community
      throw new Error("NO_ENVIRONMENT_FOUND")
    @community = community
    q = 
      'community.network': @community.network

    mongo.community_user.countDocuments  q
  .then (environment_user) ->
    console.log environment_user
    return environment_user

  .catch (err) ->
    if err.message in ['NO_COMMUNITY_FOUND']
      d_json.status = 404
    if err.message in ['NO_ACTIVE']
      d_json.status = 400
    if err.message in ['PASS_WRONG']
      d_json.status = 1
    log.e "GET environments: #{err.stack}"
    return null