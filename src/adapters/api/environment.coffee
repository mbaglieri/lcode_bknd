config   = require '../../config/config'
mongo    = require '../../dbs/mongoose'
{env}    = require '../../config/env'
Promise  = require 'bluebird'

@to_user = (val, key_comm,user,is_owner) ->
  status = "SUBSCRIBED"
  Promise.try ->
    mongo.environment_user.findOne( user: user, environment: val).exec()
  .then (env_user) ->
    if not env_user or env_user.status is "UNSUB"
      status = "UNSUBSCRIBED"
    environment = {}
    if((val.algorithm.env_type in ['public'] ) or is_owner)
      environment.id   = val._id
    menu_cfg        = val.algorithm.menu_config
    menu_cfg.wallet = true

    environment.env_type     = val.algorithm.env_type
    environment.menu_config  = menu_cfg

    environment.chat_config   = val.algorithm.chat_config
    environment.matchmaking   = val.algorithm.matchmaking
    environment.wallet        = val.algorithm.wallet
    environment.market        = val.algorithm.market
    environment.timetracking  = val.algorithm.timetracking
    environment.dashboard     = val.algorithm.dashboard
    environment.news          = val.algorithm.news
    environment.profile       = val.algorithm.profile 
    environment.assistant     = val.algorithm.assistant 
    environment.calendar      = val.algorithm.calendar 
    environment.social        = val.algorithm.social 
    environment.key           = val.key
    environment.name          = val.name
    environment.key_community = key_comm
    environment.status        = status
    if val.default_ai
      console.log val.default_ai
      default_ai =
        'name'       : val.default_ai.name
        'status'     : val.default_ai.status
        'config_json': val.default_ai.config_json
        'style' :
          'lang'      : val.default_ai.style.translation || {}
          'assistant' : val.default_ai.style.assistant || {}
          'pet'       : val.default_ai.style.pet || {}
          'background': val.default_ai.style.background || {}
          'sound'     : val.default_ai.style.sound || {}

      environment.default_ai =  default_ai
    else
      environment.default_ai =  {}

    return environment

@to_user_with_default_ai = (val, key_comm) ->
  environment = {}
  environment.id   = val._id
  menu_cfg = val.algorithm.menu_config

  environment.env_type     = val.algorithm.env_type
  environment.menu_config  = menu_cfg

  environment.chat_config   = val.algorithm.chat_config
  environment.matchmaking   = val.algorithm.matchmaking
  environment.wallet        = val.algorithm.wallet
  environment.market        = val.algorithm.market
  environment.timetracking  = val.algorithm.timetracking
  environment.dashboard     = val.algorithm.dashboard
  environment.news          = val.algorithm.news
  environment.profile       = val.algorithm.profile 
  environment.assistant     = val.algorithm.assistant 
  environment.calendar      = val.algorithm.calendar 
  environment.social        = val.algorithm.social 
  environment.key           = val.key
  environment.name          = val.name
  environment.key_community = key_comm
  if val.default_ai
    default_ai =
      'name'       : val.default_ai.name
      'status'     : val.default_ai.status
      'config_json': val.default_ai.config_json
      'style' :
        'lang'      : val.default_ai.style.translation || {}
        'assistant' : val.default_ai.style.assistant || {}
        'pet'       : val.default_ai.style.pet || {}
        'background': val.default_ai.style.background || {}
        'sound'     : val.default_ai.style.sound || {}

    environment.default_ai =  default_ai
  else
    environment.default_ai =  {}


  return environment
  
@to_user_with_ai = (val, ai, key_comm) ->
  environment = {}
  environment.id   = val._id
  menu_cfg = val.algorithm.menu_config

  environment.env_type = val.algorithm.env_type
  environment.menu_config  = menu_cfg

  environment.chat_config  = val.algorithm.chat_config
  environment.matchmaking  = val.algorithm.matchmaking
  environment.wallet       = val.algorithm.wallet
  environment.market       = val.algorithm.market
  environment.timetracking = val.algorithm.timetracking
  environment.social        = val.algorithm.social 
  environment.key  = val.key
  environment.name = val.name
  environment.key_community = key_comm
  if ai
    default_ai =
      'name'  : ai.name
      'status': ai.status
      'config_json': ai.config_json
      'style' :
        'lang'      : ai.style.translation
        'assistant' : ai.style.assistant || {}
        'pet'       : ai.style.pet || {}
        'background': ai.style.background || {}
        'sound'     : ai.style.sound || {}

    environment.default_ai =  default_ai
  else
    environment.default_ai =  {}


  return environment

@to_user_with_id = (val,  key_comm, user) ->
  status = "SUBSCRIBED"
  Promise.try ->
    mongo.environment_user.findOne( user: user, key: val.key).exec()
  .then (env_user) ->
    if not env_user or env_user.status is "UNSUB"
      status = "UNSUBSCRIBED"
    environment     = {}
    environment.id  = val._id
    menu_cfg        = val.algorithm.menu_config
    menu_cfg.wallet = true

    environment.env_type     = val.algorithm.env_type
    environment.menu_config  = menu_cfg

    environment.chat_config   = val.algorithm.chat_config
    environment.matchmaking   = val.algorithm.matchmaking
    environment.wallet        = val.algorithm.wallet
    environment.market        = val.algorithm.market
    environment.timetracking  = val.algorithm.timetracking
    environment.dashboard     = val.algorithm.dashboard
    environment.news          = val.algorithm.news
    environment.profile       = val.algorithm.profile 
    environment.assistant     = val.algorithm.assistant 
    environment.calendar      = val.algorithm.calendar 
    environment.social        = val.algorithm.social 
    environment.key           = val.key
    environment.name          = val.name
    environment.key_community = key_comm
    environment.status        = status

    return environment

@to_user_id_parsed = to_user_id_parsed = (val, key_comm) ->
  environment      = {}
  environment.id   = val._id
  menu_cfg         = val.algorithm.menu_config

  environment.env_type     = val.algorithm.env_type
  environment.menu_config  = menu_cfg

  environment.chat_config   = val.algorithm.chat_config
  environment.matchmaking   = val.algorithm.matchmaking
  environment.wallet        = val.algorithm.wallet
  environment.market        = val.algorithm.market
  environment.timetracking  = val.algorithm.timetracking
  environment.dashboard     = val.algorithm.dashboard
  environment.news          = val.algorithm.news
  environment.profile       = val.algorithm.profile 
  environment.assistant     = val.algorithm.assistant 
  environment.calendar      = val.algorithm.calendar 
  environment.social        = val.algorithm.social 
  environment.key           = val.key
  environment.name          = val.name
  environment.key_community = key_comm

  return environment

@to_user_admin = (val, key_comm,user,is_owner) ->
  environment = {}
  if((val.algorithm.env_type in ['public'] ) or is_owner)
    environment.id   = val._id
  menu_cfg        = val.algorithm.menu_config
  menu_cfg.wallet = true 

  environment.env_type     = val.algorithm.env_type
  environment.menu_config  = menu_cfg

  environment.chat_config   = val.algorithm.chat_config
  environment.matchmaking   = val.algorithm.matchmaking
  environment.wallet        = val.algorithm.wallet
  environment.market        = val.algorithm.market
  environment.timetracking  = val.algorithm.timetracking
  environment.dashboard     = val.algorithm.dashboard
  environment.news          = val.algorithm.news
  environment.profile       = val.algorithm.profile 
  environment.assistant     = val.algorithm.assistant 
  environment.calendar      = val.algorithm.calendar 
  environment.social        = val.algorithm.social 
  environment.key           = val.key
  environment.name          = val.name
  environment.key_community = key_comm
  if val.default_ai
    console.log val.default_ai
    default_ai =
      'name'       : val.default_ai.name
      'status'     : val.default_ai.status
      'config_json': val.default_ai.config_json
      'style' :
        'lang'      : val?.default_ai?.style?.translation || {}
        'assistant' : val?.default_ai?.style?.assistant || {}
        'pet'       : val?.default_ai?.style?.pet || {}
        'background': val?.default_ai?.style?.background || {}
        'sound'     : val?.default_ai?.style?.sound || {}

    environment.default_ai =  default_ai
  else
    environment.default_ai =  {}

  return environment