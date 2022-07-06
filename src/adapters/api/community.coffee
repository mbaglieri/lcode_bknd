config   = require '../../config/config'
mongo    = require '../../dbs/mongoose'
{env}    = require '../../config/env'
Promise  = require 'bluebird'

@to_user = to_user = (val,user) ->
  status = "SUBSCRIBED"
  Promise.try ->
    mongo.community_user.findOne( user: user, key: val.key).exec()
  .then (community_user) ->
    if not community_user  or community_user.status is "UNSUBSCRIBED"
      status = "UNSUBSCRIBED"
    #console.log val
    community = {}
    community.id      = val._id
    community.key     = val.key
    community.status  = status
    cfg_community =
      'name'  : val.name
      'lang'    : val.cfg.translation || {}
      'message' : val.cfg.message || {}
      'icon'    : val.cfg.icon || env.spaces.img_community_icon
      'image'   : val.cfg.image || env.spaces.img_community
      'type'    : val.cfg.type || 'public'
      'url'     : val.cfg.url || config.server[config.env].url
    community.cfg =  cfg_community


    return community
    
@to_user_admin = to_user_admin = (val,user) ->
  #console.log val
  community = {}
  community.id      = val._id
  community.key     = val.key
  community.status  = val.status
  cfg_community =
    'name'  : val.name
    'lang'    : val.cfg.translation || {}
    'message' : val.cfg.message || {}
    'icon'    : val.cfg.icon || env.spaces.img_community_icon
    'image'   : val.cfg.image || env.spaces.img_community
    'type'    : val.cfg.type || 'public'
    'url'     : val.cfg.url || config.server[config.env].url
  community.cfg =  cfg_community

  return community

@to_user_guest = to_user_guest = (val) ->
  #console.log val
  community = {}
  community.id      = val._id
  community.key     = val.key
  cfg_community =
    'name'  : val.name || ''
    'network_lang': val.network.cfg.translation || {}
    'lang'    : val.cfg.translation || {}
    'message' : val.cfg.message || {}
    'icon'    : val.cfg.icon || env.spaces.img_community_icon
    'image'   : val.cfg.image || env.spaces.img_community
    'type'    : val.cfg.type || 'public'
    'url'     : val.cfg.url || config.server[config.env].url
  community.cfg =  cfg_community
  return community


  