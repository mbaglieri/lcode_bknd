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
@users        = require './users'
###
###
  
@get_environment = get_environment = (env_id) ->
  if not env_id
    return null

  Promise.try ->
    mongo.environment.findById env_id
    .populate('default_ai')
    .populate('community')
    .exec()
  .then (environment) ->
    if not environment
      throw new Error('NO_ENVIRONMENT')

    return environment
  .catch (err) ->
    return null

@get_environments_by_id = (parms, user) ->
  d_json = {
    status: 200
  }
  is_owner = true
  Promise.try ->
    mongo.community.findOne
      key   : parms.key_community
      status: 'ACTIVE'
    .populate('network')
    .exec()
  .then (community) ->
    if not community
      throw new Error("NO_COMMUNITY_FOUND")

    if community.network.creator != user
      is_owner = false
    @community = community
    mongo.environment_user.find
      community: @community
      user     : user
      status   : 'SUB'
    .populate('environment')
    .exec()
  .then (environment_d) ->
    @environment_d = environment_d
    if not environment_d
      #or environment_d.length is 0
      throw new Error("NO_ACTIVE")
    
    qtask.user.get_create user
  .then (hai) ->

    mongo.hai_robot.find
      qtask_user: hai
    .populate('hai_robot_catalog')
    .exec()
  .then (robot) ->
    @robot = robot
    Promise.all( get_environment(env.environment._id) for env in @environment_d )
  .then (l_env_data) ->
    environment_data = []
    for environment in l_env_data
      add_t = true
      env_1 = {}
      for h_r in @robot
        if "#{environment._id}" is "#{h_r.environment}"
          add_t = false
          env_1 = h_r.hai_robot_catalog

      if environment != null
        if add_t
          environment_data.push data_adapter.api.environment.to_user_with_default_ai environment, parms.key_community
        else
          environment_data.push data_adapter.api.environment.to_user_with_ai environment, env_1, parms.key_community

    returnset = {
      data        : environment_data
      status      : 200
    }

    return returnset


@get_environments = get_environments = (parms, user) ->
  perPage = 10
  page    = parms.page || 0

  where = {}
  Promise.try ->

    mongo.community.findOne
      key  :  parms.key_community 
    .exec()
  .then (community) ->
    if not community
      throw new Error("NO_NETOWKR_FOUND")
    @community = community
    if parms.key
      where.key = { '$regex' : parms.key, '$options' : 'i' }
    if parms.name
      where.name = { '$regex' : parms.name, '$options' : 'i' }
    if parms.key_community
      where.community = 
        $in: [@community]
    if parms.longitude
      where.polygon_delimiter = 
        "$geoIntersects": {
          "$geometry": {
            "type": "Point",
            "coordinates": [parseFloat(parms.longitude), parseFloat(parms.latitude)]
          }
        } 

    if parms.enabled
      where.enabled = parms.enabled

    if parms.algorithm
      where.algorithm = 
        "type": parms.algorithm

    mongo.environment.countDocuments where
  .then (count_) ->
    @count_ = count_
    
    mongo.environment.find where
    .select(["-__v","-created_at"])
    .limit(perPage)
    .skip(perPage * page)
    .sort( created_at: 'asc')
    .populate('default_ai')
    .exec()
  .then (environment_d) ->
    if user? and @community.network.creator is user
      is_owner = true
    Promise.all(
      for environment in environment_d
        if(environment.algorithm.env_type in ['public'])
          data_adapter.api.environment.to_user environment,parms.key_community,user,is_owner
        else
          if( environment.algorithm.env_pass is parms.env_pass)
            data_adapter.api.environment.to_user_with_id environment,parms.key_community,user
          else
            data_adapter.api.environment.to_user environment, parms.key_community,user,is_owner
    )
  .then (environment_data) ->
    r = 
      count: @count_
      data : environment_data
    return r
    
@get_environments_v1 = get_environments_v1 = (parms, user) ->
  perPage = 10
  page    = parms.page || 0

  where = {}
  Promise.try ->

    mongo.community.findOne
      key  :  parms.key_community 
    .exec()
  .then (community) ->
    if not community
      throw new Error("NO_NETOWKR_FOUND")
    @community = community
    mongo.environment.findOne( key  : parms.key_env, community:@community  )
    .select(["-__v","-created_at","-polygon_delimiter"])
    .populate('community', {key:1,cfg:1,status:1})
    .exec()
  .then (env) ->
    if not env
      throw new Error("NO_ENV_FOUND")
     
    returnset = {
      data        : env
      status      : 200
    }

    return returnset

@pub_sub = (argss, user) ->
  d_json = {
    status: 200
  }
  Promise.try ->
    mongo.community.findOne 
      key: argss.key_community
    .exec()
  .then (community) ->
    @community = community
    if not community and argss.key_community
      throw new Error("NO_COMMUNITY_FOUND")

    if(argss.key_community and community.status not in ['ACTIVE'])
      throw new Error("NO_ACTIVE")
    if argss.id
      q_env = 
        _id: argss.id
    else
      q_env = 
        community: @community
        key      : argss.key

    mongo.environment.findOne q_env
    .populate('community')
    .exec()
  .then (environment) ->
    if not environment
      throw new Error("NO_ENVIRONMENT_FOUND")
    if not @community
      @community = environment.community
    console.log @community
    @environment = environment
    if environment.algorithm.env_type in ['public_pass','private_pass']
      if environment.algorithm.env_pass != argss.pass
        throw new Error("PASS_WRONG")

    mongo.community_user.findOne( user: user, community: @community)
    .exec()
  .then (community_user) ->
    if not community_user
      community_user = new mongo.community_user()
      community_user.user      = user
      community_user.community = @community
      community_user.key       = @community.key
      community_user.network   = @community.network
      community_user.status    = 'SUBSCRIBED'
      if @community.cfg.type in ['public_pass','private_pass','private']
        community_user.cfg =  {
          pass      : argss.pass || '',
          url_server: argss.url_server  || @community.cfg.url
        }

    community_user.saveAsync()
  .then (community_user_) ->
    mongo.environment_user.findOne(
      user     : user,
      community  : @community,
      environment: @environment
    ).exec()
  .then (environment_user) ->
    if not environment_user
      environment_user  = new mongo.environment_user(
        user     : user,
        key        : @environment.key,
        community  : @community,
        environment: @environment,
        status     : 'SUB'
      )
    else
      if @community.key is env.community
        if @environment.key is not env.environment
          if not argss.status
            if environment_user.status is 'SUB' 
              environment_user.status = 'UNSUB'
            else if environment_user.status is 'UNSUB' 
              environment_user.status = 'SUB'   
          else
            if argss.status is "SUBSCRIBED"
              environment_user.status = 'SUB'
            else if  argss.status is "UNSUBSCRIBED"
              environment_user.status = 'UNSUB'  

      else
          if not argss.status
            if environment_user.status is 'SUB'
              environment_user.status = 'UNSUB'
            else if environment_user.status is 'UNSUB'
              environment_user.status = 'SUB'  
          else
            if argss.status is "SUBSCRIBED"
              environment_user.status = 'SUB'
            else if  argss.status is "UNSUBSCRIBED"
              environment_user.status = 'UNSUB'  

    if @environment.algorithm.env_type in ['public_pass','private_pass']
      environment_user.cfg =  {
        pass: argss.pass || ''
      }
    environment_user.saveAsync()
  .then (environment_user_) ->
    @environment_user_ = environment_user_
    environment_user_h = new mongo.environment_user_history(
      user       : environment_user_.user,
      key        : environment_user_.key,
      community  : environment_user_.community,
      environment: environment_user_.environment,
      status     : environment_user_.status
    )
    environment_user_h.saveAsync()
  .then (environment_user_h) ->
    return @environment_user_

  .catch (err) ->
    if err.message in ['NO_COMMUNITY_FOUND']
      d_json.status = 404
    if err.message in ['NO_ACTIVE']
      d_json.status = 400
    if err.message in ['PASS_WRONG']
      d_json.status = 1
    log.e "GET environments: #{err.stack}"
    return null

@post_environments =  (parms,user) ->
  d_json = {
    status: 200
  }

  Promise.try ->
    console.log parms
    if not config.topology.environments.user_create
      throw new Error("USER_CANT_CREATE")

    mongo.community.findOne
      key    : parms.key_community
    .populate('network')
    .exec()
  .then (community) ->
    if not community
      throw new Error("NO_COMMUNITY_FOUND")

    @community = community

    if not community.network
      throw new Error("NO_NETOWKR_FOUND")

    if "#{community.network.creator}" != "#{user._id}"
      throw new Error("USER_CANT_EDIT")

    mongo.environment.findOne
      key       : parms.key
      community : community
    .exec()
  .then (env_guest) ->
    if env_guest
      throw new Error("ENVIRONMENT_ALREADY_EXIST")
    env_guest  = new mongo.environment
      key       : parms.key
      name      : parms.name
      algorithm : pre_built_menu(parms)
      enabled   : true
      community : @community
      location         : @community.location
      polygon_delimiter: @community.polygon_delimiter
    env_guest.saveAsync()
  .then (environment_) ->
    @environment_ = environment_
    pre_built_catalog environment_
  .then (catalog_) ->
    @catalog_ = catalog_
    mongo.environment.findOne
      key       : parms.key
      community : community
  .then (env_guest) ->
    env_guest.default_ai = @catalog_
    env_guest.saveAsync()
  .then (env) ->
    return d_json
  .catch (err) ->
    console.log err.stack
    if err.message in ['NO_COMMUNITY_FOUND']
      d_json.status = 404
    else if err.message in ['NO_ACTIVE']
      d_json.status = 400
    else if err.message in ['PASS_WRONG']
      d_json.status = 410
    else if err.message in ['USER_CANT_CREATE']
      d_json.status = 200
    else if err.message in ['ENVIRONMENT_ALREADY_EXIST']
      d_json.status = 401
    else
      log.e "GET community: #{err.stack}"
    return d_json

@pre_built_menu = pre_built_menu = (params) ->
  color = params.color || 'cccccc'
  algoritm_2 =
    'type'        : 2
    'color'       : color
    'monolyth'    : true
    'store_chat'  : 10
    'store_type'  : 'min'
    'env_type'    : params.env_type
    'env_pass'    : params.env_pass
    'add_ons'     : ''
    'color'       : color
    'menu_config' :{'chat':true,'matchmaking':true,'assistant':true,'wallet':false,'market':false,'timetracking':false,'news':false,'dashboard':false,'profile':true,'calendar':false,'social':false}
    'calendar'    :{'basic':false,'advance':false,'add_free':false,'add_merchant':false,'ongoing':false,'history':false,'add':false}
    'social'      :{'follows':false,'call':false,'calendar':false,'products':false,'reputation':false}
    'assistant'   :{'user':true,'record':true}
    'profile'     :{'user':true,'stadistics':true}
    'news'        :{'story':true,'instant':true}
    'dashboard'   :{'operations':true,'users':true,'petitions':true}
    'chat_config' :{'chat':true, 'groups':false,'contacts':false}
    'matchmaking' :{'pending':true,'history':true}
    'wallet'      :{'send':false,'receive':false,'history':false}
    'market'      :{'buy':false,'sell':false,'history':false  }
    'timetracking':{  'new_task':false, 'tasks':false,  'history':false,  'pomodoro':false, 'receive_operations':false}
  return algoritm_2

@pre_built_catalog = pre_built_catalog = (env) ->
  Promise.try ->
    mm = mongo.hai_robot_catalog.findOne
      name        : "matt"
      environment : env
    mm.exec()
  .then (hai_robot_catalog) ->
    if not hai_robot_catalog
      catalog_data =
        name        : 'matt'
        style       : { 'translation': { 'en': 'Matt', 'es': 'Matias' },'lang_avaiable': 'es|en' }
        config_json : {'url':env.spaces.robot_catalog,'count_files':'8','eg':'00.gif'}
        status      : 'ACTIVE'
        price       : 0
        radius      : 0
        latitude    : 0
        environment : env

      hai_robot_catalog = new mongo.hai_robot_catalog catalog_data

    hai_robot_catalog.saveAsync()
  .then (catalog_) ->
    return catalog_

@prebuilt_envs = prebuilt_envs = (community) ->
  env_guest = community.key + '_guest'
  env_admin = community.key + '_admin'
  Promise.try ->
    mongo.environment.findOne( key  : env_guest ,community : community )
    .exec()
  .then (environment) ->
    if not environment
      algoritm_2 = {
        'type'      : 2
        'monolyth'  : true
        'store_chat': 10
        'store_type': 'min'
        'env_type': 'public'
        'env_pass': ''
        'add_ons' : ''
        'color'   : 'cccccc'
        'menu_config' :{'chat':true,'matchmaking':true,'assistant':true,'wallet':false,'market':false,'timetracking':false,'news':false,'dashboard':false,'profile':true,'calendar':false,'social':false}
        'calendar'    :{'basic':false,'advance':false,'add_free':false,'add_merchant':false,'ongoing':false,'history':false,'add':false}
        'social'      :{'follows':false,'call':false,'calendar':false,'products':false,'reputation':false}
        'assistant'   :{'user':true,'record':false}
        'profile'     :{'user':true,'stadistics':false}
        'news'        :{'story':false,'instant':false}
        'dashboard'   :{'operations':false,'users':false,'petitions':false}
        'chat_config' :{'chat':true, 'groups':false,'contacts':false}
        'matchmaking' :{'pending':true,'history':true}
        'wallet'      :{'send':false,'receive':false,'history':false}
        'market'      :{'buy':false,'sell':false,'history':true  }
        'timetracking':{  'new_task':false, 'tasks':false,  'history':false,  'pomodoro':false, 'receive_operations':false}
        }
      environment = new mongo.environment
        key       : env_guest
        name      : {'es':'Invitado','en':'Guest'}
        algorithm : algoritm_2
        enabled   : true
        community : community
        location         : community.location
        polygon_delimiter: community.polygon_delimiter
    environment.saveAsync()
  .then (environment_) ->
    @environment_ = environment_

    mm = mongo.hai_robot_catalog.findOne
      name        : "matt"
      environment : environment_
    mm.exec()
  .then (hai_robot_catalog) ->
    if not hai_robot_catalog
      catalog_data =
        name        : 'matt'
        style       : { 'translation': { 'en': 'Matt', 'es': 'Matias' },'lang_avaiable': 'es|en' }
        config_json : {'url':env.spaces.robot_catalog,'count_files':'8','eg':'00.gif'}
        status      : 'ACTIVE'
        price       : 0
        radius      : 0
        latitude    : 0
        environment : @environment_

      hai_robot_catalog = new mongo.hai_robot_catalog catalog_data
    hai_robot_catalog.saveAsync()
  .then (catalog_) ->
    @catalog_ = catalog_
    @environment_.default_ai = catalog_
    @environment_.saveAsync()
  .then (catalog_) ->
    mongo.environment.findOne( key  : env_admin ,community : community )
    .exec()
  .then (environment) ->
    if not environment
      algoritm_2 = {
        'type'    :2
        'monolyth':true
        'store_chat':10
        'store_type':'min'
        'env_type':'public'
        'env_pass':''
        'add_ons' :''
        'color'   :'cccccc'
        'menu_config' :{'chat':true,'matchmaking':true,'assistant':true,'wallet':false,'market':false,'timetracking':false,'news':false,'dashboard':false,'profile':true,'calendar':false,'social':false}
        'calendar'    :{'basic':false,'advance':false,'add_free':false,'add_merchant':false,'ongoing':false,'history':false,'add':false}
        'social'      :{'follows':false,'call':false,'calendar':false,'products':false,'reputation':false}
        'assistant'   :{'user':true,'record':false}
        'profile'     :{'user':true,'stadistics':false}
        'news'        :{'story':false,'instant':false}
        'dashboard'   :{'operations':false,'users':false,'petitions':false}
        'chat_config' :{'chat':true, 'groups':false,'contacts':false}
        'matchmaking' :{'pending':true,'history':true}
        'wallet'      :{'send':false,'receive':false,'history':false}
        'market'      :{'buy':false,'sell':false,'history':true  }
        'timetracking':{'new_task':false, 'tasks':false,  'history':false,  'pomodoro':false, 'receive_operations':false}
      }
      environment = new mongo.environment
        key       : env_admin
        name      : {'es':'Administrador','en':'Administrator'}
        algorithm : algoritm_2
        enabled   : true
        community : community
        location         : community.location
        polygon_delimiter: community.polygon_delimiter
    environment.saveAsync()
  .then (environment_) ->
    @environment_ad = environment_
   
    @environment_ad.saveAsync()
  .then (catalog_) ->
    return true

@by_network = by_network = (parms, user, is_enable_to_read) ->
  perPage = 10
  page    = parms.page || 0

  where       = {}
  Promise.try ->
    mongo.community.findOne
      key  :  parms.key_community 
    .populate('network')
    .exec()
  .then (community) ->
    if not community
      throw new Error("NO_NETOWKR_FOUND")
    if(not is_enable_to_read and community.network.creator is not user)
      throw new Error("NO_NETOWKR_FOUND")
    @community = community
    if parms.key
      where.key = { '$regex' : parms.key, '$options' : 'i' }
    if parms.name
      where.name = { '$regex' : parms.name, '$options' : 'i' }
    if parms.key_community
      where.community = 
        $in: [@community]
    if parms.longitude
      where.polygon_delimiter = 
        "$geoIntersects": {
          "$geometry": {
            "type": "Point",
            "coordinates": [parseFloat(parms.longitude), parseFloat(parms.latitude)]
          }
        } 

    if parms.enabled
      where.enabled = parms.enabled

    if parms.algorithm
      where.algorithm = 
        "type": parms.algorithm

    mongo.environment.countDocuments where
  .then (count_) ->
    @count_ = count_
    
    mongo.environment.find where
    .select(["-__v","-created_at"])
    .limit(perPage)
    .skip(perPage * page)
    .sort( created_at: 'asc')
    .populate('default_ai')
    .exec()
  .then (environment_d) ->
    if user? and @community.network.creator is user
      is_owner = true
    environment_data = []
    for environment in environment_d
      environment_data.push data_adapter.api.environment.to_user_admin environment,parms.key_community,user,is_enable_to_read
    r = 
      count: @count_
      data : environment_data
    return r
    
@add =  add = (parms, user, is_enable_to_create) ->
  d_json = {
    status: 200
  }
  Promise.try ->
    mongo.community.findOne
      key    : parms.key_community
    .populate('network')
    .exec()
  .then (community) ->
    if not community
      throw new Error("NO_COMMUNITY_FOUND")

    @community = community

    if not community.network
      throw new Error("NO_NETOWKR_FOUND")

    if "#{community.network.creator}" != "#{user._id}"
      throw new Error("USER_CANT_EDIT")
    country_q = 
      name: parms?.cfg?.country_network || env.country
    mongo.countries.findOne country_q
    .exec()
  .then (country) ->
    @country = country
    if not @country 
      parms.polygon_delimiter = @network.polygon_delimiter
    else 
      parms.polygon_delimiter = @country.polygon_delimiter
    if not config.topology.environments.user_create
      throw new Error("USER_CANT_CREATE")


    mongo.environment.findOne
      key       : parms.key
      community : @community
    .exec()
  .then (env_guest) ->
    if env_guest
      throw new Error("ENVIRONMENT_ALREADY_EXIST")
    env_guest  = new mongo.environment
      key       : parms.key
      name      : parms.name
      algorithm : pre_built_menu(parms)
      enabled   : true
      community : @community
      location         : parms.location || @community.location
      polygon_delimiter: parms.polygon_delimiter
    env_guest.saveAsync()
  .then (environment_) ->
    @environment_ = environment_
    pre_built_catalog environment_
  .then (catalog_) ->
    @catalog_ = catalog_
    mongo.environment.findOne
      key       : parms.key
      community : community
    .exec()
  .then (env_guest) ->
    env_guest.default_ai = @catalog_
    env_guest.saveAsync()
  .then (env) ->
    return d_json
  .catch (err) ->
    console.log err.stack
    if err.message in ['NO_COMMUNITY_FOUND']
      d_json.status = 404
    else if err.message in ['NO_ACTIVE']
      d_json.status = 400
    else if err.message in ['PASS_WRONG']
      d_json.status = 410
    else if err.message in ['USER_CANT_CREATE']
      d_json.status = 200
    else if err.message in ['ENVIRONMENT_ALREADY_EXIST']
      d_json.status = 401
    else
      log.e "GET community: #{err.stack}"
    return d_json

@modify =  (parms, user, is_system) ->
  d_json = {
    status: 200
  }

  environment_id     = parms.environment_id
  module_chat        = parms.module_chat
  g_chat             = parms.g_chat
  g_groups           = parms.g_groups
  g_contacts         = parms.g_contacts

  module_matchmaking = parms.module_matchmaking
  m_pending          = parms.m_pending
  m_history          = parms.m_history
  
  module_assistant   = parms.module_assistant
  a_user             = parms.a_user
  a_record           = parms.a_record

  module_wallet      = parms.module_wallet
  w_send             = parms.w_send
  w_receive          = parms.w_receive
  w_history          = parms.w_history
  
  module_market      = parms.module_market
  mkt_buy            = parms.mkt_buy
  mkt_sell           = parms.mkt_sell
  mkt_history        = parms.mkt_history
  
  module_timetracking = parms.module_timetracking
  t_new_task          = parms.t_new_task
  t_tasks             = parms.t_tasks
  t_history           = parms.t_history
  t_pomodoro          = parms.t_pomodoro

  module_news        = parms.module_news
  mws_story          = parms.mws_story 
  mws_instant        = parms.mws_instant

  module_calendar  = parms.module_calendar
  c_basic          = parms.c_basic 
  c_advance        = parms.c_advance
  c_add_free       = parms.c_add_free
  c_add_merchant   = parms.c_add_merchant
  c_ongoing        = parms.c_ongoing
  c_history        = parms.c_history
  c_add            = parms.c_add

  module_social  = parms.module_social
  s_follows      = parms.s_follows 
  s_call         = parms.s_call
  s_calendar     = parms.s_calendar
  s_products     = parms.s_products
  s_reputation   = parms.s_reputation
  is_key_editable= false
  Promise.try ->
    mongo.environment.findById parms.id
    .populate('community')
    .exec()
  .then (env) ->
    @env = env
    if not env
      throw new Error("NO_ENVIRONMENT_FOUND")

    mongo.network.findById env.community.network
    .exec()
  .then (network) ->
    if not network
      throw new Error("NO_NETWORK_FOUND")

    if not is_system and network.creator != req.user
      throw new Error("USER_CANT_EDIT")

    mongo.environment.findOne
      key       : parms.key
      community : @env.community
    .exec()
  .then (c) ->
    if not c
      is_key_editable = true

    if(is_key_editable )
      @env.key = parms.key
    
    if(parms.status)
      if parms.status in ["DISABLE","INACTIVE"]
        @env.status = "INACTIVE"
      else
        @env.status = "ACTIVE"
    if parms.location
      @env.location  = parms.location

    if @country
      @env.polygon_delimiter = @country.polygon_delimiter

    if parms.env_type
      @env.algorithm.env_type = parms.env_type
    if parms.env_pass
      @env.algorithm.env_pass = parms.env_pass
    if parms.color
      @env.algorithm.color    = parms.color
    menu_cfg            = @env.algorithm.menu_config
    chat_config         = @env.algorithm.chat_config
    matchmaking_config  = @env.algorithm.matchmaking
    assistant_config    = @env.algorithm.assistant
    wallet_config       = @env.algorithm.wallet
    market_config       = @env.algorithm.market
    timetracking_config = @env.algorithm.timetracking
    social_config       = @env.algorithm.social
    calendar_config     = @env.algorithm.social
    news_config         = @env.algorithm.news
    calendar_config     = @env.algorithm.calendar
    # simplify to a 1 method out of time... 
    if module_chat
      menu_cfg.chat = (module_chat == 'true')
      if chat_config is null
        chat_config = { }
      if menu_cfg.chat
        if g_chat
          chat_config.chat     = (g_chat == 'true')
        if g_groups
          chat_config.groups   = (g_groups == 'true')
        if g_contacts
          chat_config.contacts = (g_contacts == 'true')
        if chat_config.chat == false 
          chat_config.contacts = false
      else
        chat_config.chat     = false
        chat_config.groups   = false
        chat_config.contacts = false

    if module_matchmaking
      menu_cfg.matchmaking = (module_matchmaking == 'true')
      if matchmaking_config is null
        matchmaking_config = { }
      if menu_cfg.matchmaking
        if m_pending
          matchmaking_config.pending   = (m_pending == 'true')
        if m_history
          matchmaking_config.history   = (m_history == 'true')
      else
        matchmaking_config.matchmaking  = false
        matchmaking_config.pending      = false
        matchmaking_config.history      = false


    if module_assistant
      menu_cfg.assistant = (module_assistant == 'true')
      if assistant_config is null
        assistant_config = { }
      if menu_cfg.assistant
        if a_user
          assistant_config.user   = (a_user == 'true')
        if a_record
          assistant_config.record  = (a_record == 'true')
      else
        assistant_config.user      = false
        assistant_config.record    = false

    if module_wallet
      menu_cfg.wallet = (module_wallet == 'true')
      if wallet_config is null
        wallet_config = { }
      if menu_cfg.wallet
        if w_send
          wallet_config.send   = (w_send == 'true')
        if w_receive
          wallet_config.receive   = (w_receive == 'true')
        if w_history
          wallet_config.history   = (w_history == 'true')
      else
        wallet_config.send     = false
        wallet_config.receive    = false
        wallet_config.history = false

    if module_market
      console.log "module_market"
      menu_cfg.market = (module_market == 'true')
      console.log menu_cfg.market
      if market_config is null
        market_config = {}
      if menu_cfg.market
        if mkt_buy
          market_config.buy       = (mkt_buy == 'true')
        if mkt_sell
          market_config.sell      = (mkt_sell == 'true')
        if mkt_history
          market_config.history   = (mkt_history == 'true')
      else
        market_config.buy     = false
        market_config.sell    = false
        market_config.history = false

    if module_timetracking
      menu_cfg.timetracking = (module_timetracking == 'true')
      if timetracking_config is null
        timetracking_config = {}
      if menu_cfg.timetracking
        if t_new_task
          timetracking_config.new_task   = (t_new_task == 'true')
        if t_tasks
          timetracking_config.tasks   = (t_tasks == 'true')
        if t_history
          timetracking_config.history   = (t_history == 'true')
        if t_pomodoro
          timetracking_config.pomodoro   = (t_pomodoro == 'true')
      else
        timetracking_config.new_task   = false
        timetracking_config.tasks      = false
        timetracking_config.history    = false
        timetracking_config.pomodoro   = false


    if module_news
      menu_cfg.news = (module_news == 'true')
      if news_config is null
        news_config = {}
      if menu_cfg.news
        if mws_story
          news_config.story   = (mws_story == 'true')
        if mws_instant
          news_config.instant   = (mws_instant == 'true')
      else
        news_config.story   = false
        news_config.instant = false

    if module_calendar
      menu_cfg.calendar = (module_calendar == 'true')
      if module_calendar is null
        calendar_config = {}
      if menu_cfg.calendar
        if c_basic
          calendar_config.basic     = (c_basic == 'true')
        if c_advance
          calendar_config.advance   = (c_advance == 'true')
        if c_add_free
          calendar_config.add_free     = (c_add_free == 'true')
        if c_add_merchant
          calendar_config.add_merchant = (c_add_merchant == 'true')
        if c_ongoing
          calendar_config.ongoing   = (c_ongoing == 'true')
        if c_history
          calendar_config.history   = (c_history == 'true')
        if c_add
          calendar_config.add       = (c_add == 'true')
      else
        calendar_config.basic   = false
        calendar_config.advance = false
        calendar_config.add_free      = false
        calendar_config.add_merchant  = false
        calendar_config.ongoing       = false
        calendar_config.history       = false
        calendar_config.add           = false


    if module_social
      menu_cfg.social = (module_social == 'true')
      if social_config is null
        social_config = {}
      if menu_cfg.social
        if s_follows
          social_config.follows   = (s_follows == 'true')
        if s_call
          social_config.call      = (s_call == 'true')
        if s_calendar
          social_config.calendar   = (s_calendar == 'true')
        if s_products
          social_config.products   = (s_products == 'true')
        if s_reputation
          social_config.reputation = (s_reputation == 'true')
      else
        social_config.follows    = false
        social_config.call       = false
        social_config.calendar   = false
        social_config.products   = false
        social_config.reputation = false

    @env.algorithm.menu_config  = menu_cfg
    @env.algorithm.chat_config  = chat_config
    @env.algorithm.matchmaking  = matchmaking_config
    @env.algorithm.assistant    = assistant_config
    @env.algorithm.wallet       = wallet_config
    @env.algorithm.timetracking = timetracking_config
    @env.algorithm.market       = market_config
    @env.algorithm.news         = news_config
    @env.algorithm.calendar     = calendar_config
    @env.algorithm.social       = social_config

    @env.markModified('algorithm');
    @env.saveAsync()
  .then (env) ->
    return env