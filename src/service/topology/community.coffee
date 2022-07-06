Promise  = require 'bluebird'
async    = require 'async'

request       = Promise.promisifyAll require 'request'
fs            = Promise.promisifyAll require 'fs'
mongo         = require '../../dbs/mongoose'
config        = require '../../config/config'
{env}         = require '../../config/env'
log           = require('../../tools/log').create 'service.center.general'
jwt           = require 'jsonwebtoken'
randtoken     = require 'rand-token'
data_adapter  = require '../../adapters'
utils         = require '../../tools/utils'
environment_service = require './environment'
###
###

@my_communities = my_communities = (parms, user) ->
  perPage = 10
  page    = parms.page || 0

  where       = {}
  network_key = parms.network_key 
  Promise.try ->
    mongo.network.findOne
      key  : network_key
    .exec()
  .then (net) ->
    if net
      where.network = net
    where.user   = user

    if not parms.status
      where.status = 
        $in: ['SUBSCRIBED']
    else 
      where.status =
        $in: parms.status.split ","
    mongo.community_user.countDocuments where
  .then (count_) ->
    @count_ = count_
    
    mongo.community_user.find where
    .select(["-__v","-created_at"])
    .limit(perPage)
    .skip(perPage * page)
    .sort( created_at: 'asc')
    .populate('network')
    .exec()
  .then (network_d) ->
    Promise.all( get_network_guest(env.key) for env in network_d )
  .then (l_env_data) ->
    r = 
      count: @count_
      data : l_env_data
    return r

@get_network_guest = get_network_guest = (com_key) ->
  if not com_key
    return null

  Promise.try ->
    mongo.community.findOne
      key  : com_key
    .populate('network')
    .exec()
  .then (comunity) ->
    if not comunity
      throw new Error('NO_ENVIRONMENT')

    return  data_adapter.api.community.to_user_guest(comunity)
  .catch (err) ->
    return null

@pub_sub = (argss, user, is_system) ->
  d_json = {
    status: 404
  }
  console.log argss
  Promise.try ->
    if argss.id
      comm_q = 
        _id : argss.id
    else
      comm_q = 
        key : argss.key

    mongo.community.findOne comm_q
    .exec()
  .then (community) ->
    @community = community
    if not community
      throw new Error("NO_COMMUNITY_FOUND")
    if(community.status not in ['ACTIVE'])
      throw new Error("NO_ACTIVE")
    if community.cfg.type in ['public_pass','private_pass'] and not is_system
      if community.cfg.pass != argss.pass
        throw new Error("PASS_WRONG")
    
    mongo.community_user.findOne( user: user, key: @community.key).exec()
  .then (community_user) ->
    if not community_user
      community_user           = new mongo.community_user()
      community_user.user      = user
      community_user.network   = @community.network
      community_user.key       = @community.key
      community_user.community = @community

    @remove_envs = false
    if argss.status in ['SUBSCRIBED', 'UNSUBSCRIBED']
      if community_user.key is env.community
        community_user.status = 'SUBSCRIBED'
      else
        #console.log "PubSub #{argss.status}"
        community_user.status = argss.status
        @remove_envs = argss.status in ['UNSUBSCRIBED']

    if @community.cfg.type in ['public_pass','private_pass','private']
      community_user.cfg =  {
        pass      : argss.pass || '',
        url_server: argss.url_server  || @community.cfg.url
      }

    community_user.saveAsync()
  .then (community_user_) ->
    @community_user_ = community_user_
    community_user_h = new mongo.community_user_history()
    community_user_h.status = community_user_.status
    community_user_h.cfg    = community_user_.cfg
    community_user_h.key    = community_user_.key
    community_user_h.user   = community_user_.user
    community_user_h.community = community_user_.community
    community_user_h.saveAsync()
  .then (community_user_h_) ->
    remove_env(@community, user, @remove_envs)
  .then (rs) ->
    return d_json
  .catch (err) ->
    if err.message in ['NO_COMMUNITY_FOUND']
      d_json.status = 404
    if err.message in ['NO_ACTIVE']
      d_json.status = 400
    if err.message in ['PASS_WRONG']
      d_json.status = 410
    log.e "GET community: #{err.stack}"
    return d_json

@remove_env = remove_env = (cm, user, rm) ->
  if !rm
    return
  Promise.try ->
    mongo.environment_user.find
      community: cm
      user:user
      status:'SUB'
    .populate('environment')
    .exec()
  .then (resultset) ->
    console.log resultset
    Promise.all(exe_unsub_env(bm) for bm in resultset)
  .then (_results) ->
    return _results

exe_unsub_env = (env) ->
  console.log "exe_unsub_env----"
  Promise.try ->
    env.status = 'UNSUB'
    env.saveAsync()
  .then (env_s) ->
    return 1
  .catch (err) ->
    return 0

@get_communities = get_communities = (parms, user) ->
  perPage = 10
  page    = parms.page || 0

  where = {}
  Promise.try ->

    mongo.network.findOne
      key  :  parms.key_network 
    .exec()
  .then (net) ->
    if not net
      throw new Error("NO_NETOWKR_FOUND")
    @net = net
    if parms.key
      where.key = { '$regex' : parms.key, '$options' : 'i' }
    if parms.key_network
      where.network = 
        $in: [@net]
    if parms.longitude
      where.polygon_delimiter = 
        "$geoIntersects": {
          "$geometry": {
            "type": "Point", 
            "coordinates": [parseFloat(parms.longitude), parseFloat(parms.latitude)]
          }
        } 
 
    if parms.network_type
      where.cfg =  
        "type": parms.network_type

    if not parms.status
      where.status = 
        $in: ['ACTIVE','INACTIVE']
    else 
      where.status =
        $in: parms.status.split ","
    mongo.community.countDocuments where
  .then (count_) ->
    @count_ = count_
    
    mongo.community.find where
    .select(["-__v","-created_at"])
    .limit(perPage)
    .skip(perPage * page)
    .sort( created_at: 'asc')
    .exec()
  .then (community_d) ->
    Promise.all(
      for community in community_d 
        data_adapter.api.community.to_user community,user
    )
  .then (community_data) ->
    r = 
      count: @count_
      data : community_data
    return r

@build_community_and_env = build_community_and_env = (net_wd, c_key, parms) ->
  Promise.try ->
    mongo.community.findOne( key  : c_key, network: net_wd  ).exec()
  .then (community) ->
    rd8 = utils.randomNum(3,1)
    if not community
      conf               = parms.cfg || {}
      conf.pass          = parms.cfg.pass || ''
      conf['type']       = parms.cfg.type_c || 'public'
      conf.type_c        = parms.cfg.type_c || 'public'
      conf.has_pass      = parms.cfg.has_pass || false
      conf.translation   = parms.cfg.translation || {'en':'Central Hall','es':'Salón Central'}
      conf.message       = parms.cfg.message || {'en':'His Hall is for news and updates','es':'Su salón es para noticias y actualizaciones.'}
      conf.color         = parms.cfg.color || 'cccccc'
      conf.url           = parms.cfg.url   || config.server[config.env].url
      conf.lang_avaiable = parms.cfg.lang_avaiable   || 'es|en'
      conf.icon          = parms.cfg.icon            || env.spaces.img_community_icon
      conf.image         = parms.cfg.image           || env.spaces.img_community
      community = new mongo.community
        key              : c_key
        status           : 'ACTIVE'
        network          : net_wd
        polygon_delimiter: parms.polygon_delimiter || net_wd.polygon_delimiter
        location         : parms.location || net_wd.location
        cfg              : conf

    community.saveAsync()
  .then (community) ->
    @community = community
    environment_service.prebuilt_envs(community)
  .then (envs) ->
    return @community

@by_network = by_network = (parms, user, is_enable_to_read) ->
  perPage = 10
  page    = parms.page || 0

  where       = {}
  Promise.try ->
    q_network = 
      key  : parms.network_key
    if(not is_enable_to_read)
      q_network.creator = user
    mongo.network.findOne q_network
    .exec()
  .then (net) ->
    if not net
      throw new Error("NO_NETOWKR_FOUND")
    where.network = net
    if not parms.status
      where.status = 
        $in: ['ACTIVE', 'INACTIVE']
    else 
      where.status =
        $in: parms.status.split ","
    mongo.community.countDocuments where
  .then (count_) ->
    @count_ = count_
    
    mongo.community.find where
    .select(["-__v","-created_at"])
    .limit(perPage)
    .skip(perPage * page)
    .sort( created_at: 'asc')
    .populate('network')
    .exec()
  .then (community_d) ->
    Promise.all(
      for community in community_d 
        data_adapter.api.community.to_user community,user
    )
  .then (community_data) ->
    r = 
      count: @count_
      data : community_data
    return r

@add =  add = (parms, user, is_enable_to_create) ->
  d_json = {
    status: 404
  }
  cat_key = parms.cfg.category_type  
  Promise.try ->
    country_q = 
      name: parms.cfg.country_network || env.country
    mongo.countries.findOne country_q
    .exec()
  .then (country) ->
    @country = country
    q_network = 
      key  : parms.key_network
    if(not is_enable_to_create)
      q_network.creator = user
    mongo.network.findOne q_network
    .exec()
  .then (network) ->
    if not network 
      throw new Error("NO_NETOWKR_FOUND")
    @network = network
    if not @country 
      parms.polygon_delimiter = @network.polygon_delimiter
    else 
      parms.polygon_delimiter = @country.polygon_delimiter

    build_community_and_env(@network, parms.key, parms)
  .then (community) ->
    return community

@modify = (parms, user, is_system) ->
  cat_key = parms.cfg.category_type  
  is_key_editable = false
  Promise.try ->
    country_q = 
      name: parms.cfg.country_network
    mongo.countries.findOne country_q
    .exec()
  .then (country) ->
    @country = country
    mongo.community.findOne 
      _id    : parms.id
    .populate('network')
    .exec()
  .then (community) ->
    if not community
      throw new Error("NO_COMMUNITY_FOUND")
    if not is_system and community.network.creator is not user
      throw new Error("NO_COMMUNITY_FOUND")

    @community = community

    mongo.community.findOne
      key       : parms.key
      network   : community.network
    .exec()
  .then (c) ->
    if not c
      is_key_editable = true

    if parms.cfg.category_type and parms.cfg.category_type.split('.').length > 1 
      cat_key = parms.cfg.category_type.split('.')[1]
    
    if(is_key_editable )
      @community.key = parms.key
    
    if(parms.status)
      if parms.status in ["DISABLE","INACTIVE"]
        @community.status = "INACTIVE"
      else
        @community.status = "ACTIVE"
    if parms.location
      @community.location  = parms.location

    if @country
      @community.polygon_delimiter = @country.polygon_delimiter

    if parms.cfg
      if parms.cfg.color
        @community.cfg.color   =  parms.cfg.color
      if parms.cfg.translation
        @community.cfg.translation   =  parms.cfg.translation
      if parms.cfg.message
        @community.cfg.message   =  parms.cfg.message
      if parms.cfg.type_c
        @community.cfg['type']       = parms.cfg.type_c
        @community.cfg.type_c        = parms.cfg.type_c
      if parms.cfg.pass
        @community.cfg.pass          = parms.cfg.pass
      if cat_key
        @community.cfg.category_type = cat_key
      if parms.cfg.country_network and @country
        @community.polygon_delimiter = @country.polygon_delimiter
      @community.markModified('cfg');

    @community.saveAsync()
  .then (community) ->
    return community
