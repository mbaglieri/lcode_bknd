config   = require '../../config/config'
mongo    = require '../../dbs/mongoose'
{env}    = require '../../config/env'
Promise  = require 'bluebird'
service  = require '../../service'

@public_data = (val) ->
  Promise.try ->
    member = val.creator
    if not member
      throw new Error("not_member_found")
    @ff =
      first_name      : member.first_name
      last_name       : member.last_name
      phone           : member.phone
      email           : member.email
      avatar          : member.avatar

    service.qtask.user.get_create(member)
  .then (hai) ->
    @ff.hai = hai._id
    network = {}
    network.id      = val._id
    network.key     = val.key
    network.counter = val.counter
    network.location = val.location
    network.categories = []
    for cat in val.categories
      network.categories.push cat.cfg.translation
    cfg_network =
      'name'     : val.name
      'lang'     : val.cfg.translation || {}
      'message'  : val.cfg.message || {}
      'color'    : val.cfg.color || {}
      'icon'     : val.cfg.icon || env.spaces.img_network_icon
      'image'    : val.cfg.image || env.spaces.img_network
      'type'     : val.cfg.type || {}
      'url'      : val.cfg.url || {}
      'country_network': val.cfg.country_network || env.country
    network.cfg     =  cfg_network
    network.creator = @ff
    return network
  .catch (err) ->
    console.log err.stack
    return

@to_user = (val) ->
  network = {}
  network.id      = val._id
  network.key     = val.key
  cfg_network =
    'name'     : val.name
    'lang'     : val.cfg.translation || {}
    'message'  : val.cfg.message || {}
    'location' : val.location || {}
    'color'    : val.cfg.color || {}
    'icon'     : val.cfg.icon || env.spaces.img_network_icon
    'image'    : val.cfg.image || env.spaces.img_network
    'type'     : val.cfg.type || {}
    'url'      : val.cfg.url || {}
    'country_network': val.cfg.country_network || env.country
  network.cfg =  cfg_network


  return network

@to_user_guest = (val) ->
  #console.log val
  network = {}
  network.id      = val._id
  network.key     = val.key
  cfg_network =
    'name'     : val.name
    'lang'     : val.cfg.translation || {}
    'message'  : val.cfg.message || {}
    'location' : val.location || {}
    'color'    : val.cfg.color || {}
    'icon'     : val.cfg.icon || env.spaces.img_network_icon
    'image'    : val.cfg.image || env.spaces.img_network
    'type'     : val.cfg.type || {}
    'url'      : val.cfg.url || {}
  network.cfg =  cfg_network

  return network