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
community_service = require './community'
###
###
@my_networks = my_networks = (parms, user) ->
  perPage = 10
  page    = parms.page || 0

  where = {}
  Promise.try ->

    where.user   = user
    if not parms.status
      where.status = 
        $in: ['SUBSCRIBED']
    else 
      where.status =
        $in: parms.status.split ","
    mongo.network_user.countDocuments where
  .then (count_) ->
    @count_ = count_
    
    mongo.network_user.find where
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

@owner_networks = owner_networks = (parms, user) ->
  perPage = 10
  page    = parms.page || 0

  where = {}
  Promise.try ->

    mongo.category_type.findOne(key  : parms.key_category  ).exec()
  .then (category_t) ->
    @category_t = category_t
    if parms.key
      where.key = { '$regex' : parms.key, '$options' : 'i' }
    if parms.key_category and category_t
      where.categories = 
        $in: [@category_t]

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

    where.creator = user
    mongo.network.countDocuments where
  .then (count_) ->
    @count_ = count_
    
    mongo.network.find where
    .select(["-__v","-created_at","-polygon_delimiter"])
    .limit(perPage)
    .skip(perPage * page)
    .sort( created_at: 'asc')
    .exec()
  .then (qt_users_exec) ->
    r = 
      count: @count_
      data : qt_users_exec
    return r

@public_user_data = public_user_data = (parms) ->
  d_json = {
    status: 200
  }
  _id         =  parms.id
  data_rating =  parms.data_rating
  Promise.try ->

    mongo.qtask_user.findOne({ _id: _id})
    .populate('user')
    .exec()
  .then (hai) ->
    if not hai
      throw new Error("NO_HAI_FOUND")
    @hai = hai
    member = hai.user
    if not member
      throw new Error("not_member_found")
    data_adapter.api.user.profile_user member
  .then (user_profile) ->
    @user_profile = user_profile
    mongo.network_user.countDocuments(
      user  : @hai.user,
      status: "SUBSCRIBED")
  .then (count_network) ->
    @count_network = count_network

    mongo.community_user.countDocuments(
      user  : @hai.user,
      status: "SUBSCRIBED")
  .then (count_communities) ->
    @count_communities = count_communities

    console.log "----------123"
    mongo.environment_user.countDocuments(
      user  : @hai.user,
      status: "SUBSCRIBED")
  .then (count_env) ->
    @count_env = count_env


    console.log "----------1234"
    mongo.network_user.find(
      user  : @hai.user,
      status: "SUBSCRIBED" 
    )
    .limit(3)
    .populate('network')
    .sort({'updated_at': -1})
    .exec()
  .then (network_d) ->
    Promise.all( get_network_guest(env.key) for env in network_d )
  .then (l_env_data) ->
    rating = []
    if data_rating and data_rating is "true"
      for i in [0...3] 
        rating.push 
          name: "Cafe Bar"
          date: "1/1/2020"
          id  : "21312341241f11d12e312"
          uri : env.spaces.img_profile_back
          description:
            es:"Lorem Ipsum is simply dummy text of the pr make but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum"
            en:"Lorem Ipsum is simply dummy text of the pr make but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum"
    
    console.log "----------125"
    user_f = 
      location     : @user_profile.location
      email        : @user_profile.email
      phone        : @user_profile.phone
      first_name   : @user_profile.first_name
      last_name    : @user_profile.last_name
      avatar       : @user_profile.avatar
      job          : @user_profile.job
      education    : @user_profile.education
      description  : @user_profile.description
    returnset = {
      user        : user_f
      networks    : l_env_data
      counter:
        network     : @count_network
        community   : @count_communities
        env         : @count_env
      raiting       : rating
    }
    return returnset
    
@get_detail_network = get_detail_network = (com_key) ->
  Promise.try ->
    mongo.network.findById com_key
    .populate('categories creator')
    .exec()
  .then (net) ->
    if not net
      throw new Error("NO_NETOWKR_FOUND")
    console.log net
    data_adapter.api.network.public_data net
  .then (net) ->
    console.log net
    return net
  .catch (err) ->
    console.log err.stack
    return null

@get_network_guest = get_network_guest = (com_key) ->
  if not com_key
    return null

  Promise.try ->
    mongo.network.findOne
      key  : com_key
    .exec()
  .then (comunity) ->
    if not comunity
      throw new Error('NO_ENVIRONMENT')

    return data_adapter.api.network.to_user_guest(comunity)
  .catch (err) ->
    return null

@get_network_categories = get_network_categories = (parms) ->
  perPage = 10
  page    = parms.page || 0

  where = {}
  Promise.try ->
    if parms.key
      where.key = { '$regex' : parms.key, '$options' : 'i' }

    if not parms.status
      where.status = 
        $in: ['ACTIVE']
    else 
      where.status =
        $in: parms.status.split ","

    mongo.category_type.countDocuments where
  .then (count_) ->
    @count_ = count_
    
    mongo.category_type.find where
    .select(["-__v","-created_at"])
    .limit(perPage)
    .skip(perPage * page)
    .sort( created_at: 'asc')
    .exec()
  .then (qt_users_exec) ->
    r = 
      count: @count_
      data : qt_users_exec
    return r

@get_networks = get_networks = (parms, required_categories) ->
  perPage = 10
  page    = parms.page || 0

  where = {}
  Promise.try ->

    mongo.category_type.findOne(key  : parms.key_category  ).exec()
  .then (category_t) ->
    if required_categories and not category_t
      throw new Error("NO_CATEGORY_FOUND")
    @category_t = category_t
    if parms.key
      where.key = { '$regex' : parms.key, '$options' : 'i' }
    if parms.key_category
      where.categories = 
        $in: [@category_t]
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
    mongo.network.countDocuments where
  .then (count_) ->
    @count_ = count_
    
    mongo.network.find where
    .select(["-__v","-created_at","-polygon_delimiter"])
    .limit(perPage)
    .skip(perPage * page)
    .sort( created_at: 'asc')
    .exec()
  .then (qt_users_exec) ->
    r = 
      count: @count_
      data : qt_users_exec
    return r

@get_best_ranked_networks = get_best_ranked_networks = (parms) ->
  perPage = 10
  page    = parms.page || 0

  key_category = page.key_category || "stage"
  longitude    = page.longitude    || "-58.381"
  latitude     = page.latitude     || "-34.6037"
  network_type = page.network_type     || "public"
  where = {}
  Promise.try ->

    mongo.category_type.findOne(key  : parms.key_category  ).exec()
  .then (category_t) ->
    if not category_t
      throw new Error("NO_CATEGORY_FOUND")
    @category_t = category_t
    if parms.key
      where.key = { '$regex' : parms.key, '$options' : 'i' }
    if parms.key_category
      where.categories = 
        $in: [@category_t]
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
        $in: ['ACTIVE']
    else 
      where.status =
        $in: parms.status.split ","
    mongo.network.countDocuments where
  .then (count_) ->
    @count_ = count_
    
    mongo.network.find where
    .select(["-__v","-created_at","-polygon_delimiter"])
    .limit(perPage)
    .skip(perPage * page)
    .populate('categories')
    .sort({'counter': -1})
    .exec()
  .then (qt_users_exec) ->
    r = 
      count: @count_
      data : qt_users_exec
    return r
    


@pub_sub = (argss, user) ->
  d_json = {
    status: 200
  }
  Promise.try ->
    mongo.network.findOne( key  : argss.key  ).exec()
  .then (network) ->
    if not network
      throw new Error("NO_COMMUNITY_FOUND")
    if(network.status not in ['ACTIVE'])
      throw new Error("NO_ACTIVE")
    if network.cfg.type in ['public_pass','private_pass']
      if network.cfg.pass != argss.pass
        throw new Error("PASS_WRONG")
    @network = network
    mongo.network_user.findOne( user: user, key: @network.key).exec()
  .then (network_user) ->
    if not network_user
      network_user        = new mongo.network_user()
      network_user.user   = user
      network_user.key    = @network.key
      network_user.network= @network

    @remove_env = false
    if argss.status in ['SUBSCRIBED', 'UNSUBSCRIBED']
      if network_user.key is env.network
        #console.log "status  lock subscribed"
        network_user.status = 'SUBSCRIBED'
      else
        #console.log "PubSub #{argss.status}"
        network_user.status = argss.status
        @remove_env = argss.status in ['UNSUBSCRIBED','UNSUBSCRIBE']

    if @network.cfg.type in ['public_pass','private_pass','private']
      network_user.cfg =  {
        pass      : argss.pass || '',
        url_server: argss.url_server  || @network.cfg.url
      }

    network_user.saveAsync()
  .then (network_user_) ->
    @network_user_ = network_user_
    network_user_h = new mongo.network_user_history()
    network_user_h.status = network_user_.status
    network_user_h.cfg    = network_user_.cfg
    network_user_h.key    = network_user_.key
    network_user_h.user   = network_user_.user
    network_user_h.network= network_user_.network
    network_user_h.saveAsync()
  .then (network_user_h_) ->
    find_remove_communities(@network, user, @remove_env)
  .then (rs) ->
     mongo.network_user.countDocuments( key: @network.key).exec()
  .then (counter) ->
    @network.counter = counter
    @network.saveAsync()
  .then (network_user_h_) ->
    return d_json
  .catch (err) ->
    if err.message in ['NO_COMMUNITY_FOUND']
      d_json.status = 404
    if err.message in ['NO_ACTIVE']
      d_json.status = 400
    if err.message in ['PASS_WRONG']
      d_json.status = 410
    log.e "GET network: #{err.stack}"
    return d_json

@find_remove_communities = find_remove_communities = (netw, user, rm) ->
  console.log "find_remove_communities"
  if !rm
    return
  Promise.try ->
    mongo.community.find
      network:netw
    .exec()
  .then (resultset) ->
    Promise.all(remove_com_u(bm, user, rm) for bm in resultset)


@remove_com_u = remove_com_u = (community, user, rm) ->
  if !rm
    return
  Promise.try ->
    mongo.community_user.find
      key    : community.key
      user   : user
      status :'SUBSCRIBED'
    .exec()
  .then (resultset) ->
    Promise.all(exe_unsub_comm(community, bm, user, rm) for bm in resultset)
  .then (_results) ->
    return _results

exe_unsub_comm = (community, comm, user, rm) ->
  if !rm
    return
  Promise.try ->
    comm.status = 'UNSUBSCRIBED'
    comm.saveAsync()
  .then (env_s) ->
    remove_all_env(community, user, rm)
  .then (env_ss) ->
    return 1
  .catch (err) ->
    return 0

@remove_all_env = remove_all_env = (cm, user, rm) ->
  console.log "remove_all_env"
  console.log user
  if !rm
    return
  Promise.try ->
    mongo.environment_user.find
      community: cm
      user     : user
      status   : 'SUB'
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

@add =  add = (parms, user, is_system) ->
  d_json = {
    status: 404
  }
  cat_key = parms.cfg.category_type  
  Promise.try ->
    console.log parms.cfg.category_type.split('.').length
    console.log parms.cfg.category_type.split('.').length > 1
    if parms.cfg.category_type.split('.').length > 1 
      cat_key = parms.cfg.category_type.split('.')[1]
    
    mongo.category_type.findOne
      key  : cat_key
    .exec()
  .then (category_type) ->
    if not category_type
      throw new Error("NO_NETOWKR_CATEGORY")
    @category_type = category_type
    @country = parms.cfg.country_network || env.country
    mongo.countries.findOne
      name  : @country
    .exec()
  .then (country) ->
    if not country
      throw new Error("NO_COUNTRY")

    @country = country
    q_network = 
      key  : parms.key
    if(not is_system)
      q_network.creator = user

    mongo.network.findOne q_network
    .exec()
  .then (network) ->
    if network 
      throw new Error("NETWORK_EXISTS")
    conf = parms.cfg
    conf.color   =  parms.cfg.color || 'cccccc'
    conf.url     =  parms.cfg.url   || config.server[config.env].url
    conf.category_type   =  cat_key
    conf.lang_avaiable   =  parms.cfg.lang_avaiable   || 'es|en'
    conf.icon            =  parms.cfg.icon            || env.spaces.img_network
    conf.image           =  parms.cfg.image           || env.spaces.img_network_icon
    conf.country_network =  @country
    conf.url     =  parms.cfg.url   || config.server[config.env].url
    conf.type_c = parms.cfg.type
    network = new mongo.network
      key   : parms.key
      status: "ACTIVE"
      cfg   : conf
      creator: user

    if @country
      network.polygon_delimiter = @country.polygon_delimiter
    network.categories.push @category_type
    network.saveAsync()
  .then (network) ->
    @network = network
    community_key = network.key + '_hall'
    community_service.build_community_and_env(network,community_key,{})
  .then (comm) ->
    return comm

@modify =  (parms, user, is_system) ->
  cat_key         = parms.cfg.category_type  
  is_key_editable = false

  Promise.try ->
    q_network = 
      _id  : parms.key

    if(not is_system)
      q_network.creator = user
    mongo.network.findOne q_network
    .exec()
  .then (network) ->
    if not network
      throw new Error("NO_NETOWKR_FOUND")
    @network = network

    mongo.category_type.findOne
      key  : cat_key
    .exec()
  .then (category_type) ->
    if not category_type
      throw new Error("NO_NETOWKR_CATEGORY")
    @category_type = category_type

    @country = parms.cfg.country_network || env.country
    mongo.countries.findOne
      name  : @country
    .exec()
  .then (country) ->
    if not country
      throw new Error("NO_COUNTRY")
    @country = country

    mongo.network.findOne
      key       : parms.key
    .exec()
  .then (c) ->
    if not c
      is_key_editable = true
    if parms.cfg.category_type.split('.').length > 1 
      cat_key = parms.cfg.category_type.split('.')[1]
    
    if(is_key_editable )
      console.log "CHANGING key"
      @network.key = parms.key
    
    if(parms.status)
      console.log "CHANGING status"
      if parms.status in ["DISABLE","INACTIVE"]
        @network.status = "INACTIVE"
    if parms.cfg
      if parms.cfg.color
        @network.cfg.color   =  parms.cfg.color
      if parms.cfg.translation
        @network.cfg.translation   =  parms.cfg.translation
      if parms.cfg.message
        @network.cfg.message   =  parms.cfg.message
      if parms.location
        @network.location  = parms.location
      if parms.cfg.type_c
        @network.cfg['type']       = parms.cfg.type_c
        @network.cfg.type_c        = parms.cfg.type_c
      if parms.cfg.pass
        @network.cfg.pass          = parms.cfg.pass
      if cat_key
        @network.cfg.category_type = cat_key
      if parms.cfg.country_network
        @network.cfg.country_network = parms.cfg.country_network
        if @country
          @network.polygon_delimiter = @country.polygon_delimiter
      @network.markModified('cfg');

    @network.saveAsync()
  .then (network) ->
    return network
