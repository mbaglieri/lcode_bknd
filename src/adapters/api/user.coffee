config   = require '../../config/config'
mongo    = require '../../dbs/mongoose'
service  = require '../../service'
{env}    = require '../../config/env'
Promise  = require 'bluebird'
moment   = require 'moment'
@profile_user = (user) ->
  Promise.try ->
    # data  :data_adapter.get_me(req.user.dataValues),
    mongo.community.findOne
      key  : env.community
    .populate('network')
    .exec()
  .then (community) ->
    @default_community = community
    if not community
      throw new Error("NO_DEFAULT_COMMUNITY_FOUND")

    mongo.environment.findOne( key  : env.environment, community: community ).exec()
  .then (environment) ->
    @default_environment = environment
    if not environment
      throw new Error("NO_DEFAULT_COMMUNITY_FOUND")

    mongo.qtask_user.findOne({ user:  user})
    .populate('environment')
    .exec()
  .then (hai) ->
    if not hai
      hai = new mongo.qtask_user
        user    : user
        status     : 'INTRO'
        enabled    : true
    if hai.environment == null
        hai.environment = @default_environment
    hai.saveAsync()
  .then (hai_) ->
    @hai = hai_
    mongo.user_photo.find
      user: user
    .exec()
  .then (photos_db) ->
    @photos_db = photos_db
    id = @hai.environment._id || @hai.environment

    mongo.environment.findById @hai.environment
    .populate('community')
    .exec()
  .then (environment) ->
    if not environment
      throw new Error("NO_ENVIRONMENT_FOUND")
    @environment = environment

    service.topology.environment.pre_built_catalog environment
  .then (default_ai_f) ->
    @default_ai_f = default_ai_f
    if @environment.default_ai
      #console.log "OLD ROBOT"
      mm = 
        _id: @environment.default_ai
    else
      #console.log "NEW ROBOT"
      mm =
        name  : 'matt'
    console.log mongo.hai_robot_catalog
    mongo.hai_robot_catalog.findOne( mm ).exec()
  .then (default_ai) ->
    if not default_ai
      @environment.default_ai = default_ai_f
    else
      @environment.default_ai = default_ai
    @environment.saveAsync()
  .then (enfv) ->
    @environment = enfv

    mongo.network.findById @environment.community.network
    .exec()
  .then (network) ->
    if not network
      console.log @environment.community
      console.log network
      throw new Error("NO_ENVIRONMENT_FOUND")

    @network = network
    mongo.environment_user.findOne( user:user, environment: @hai.environment )
    .populate('environment community')
    .sort
      updated_at: -1
    .exec()
  .then (environment_d) ->
    @environment_user = environment_d
    if environment_d == null
      environment_d  = new mongo.environment_user(
        user     : user,
        key        : @environment.key,
        community  : @environment.community,
        environment: @environment,
        status     : "SUB"
      )
    if @environment.algorithm.env_type in ['public_pass','private_pass']
      environment_d.cfg =  {
        pass: @environment.algorithm.env_pass || ''
      }
    environment_d.saveAsync()
  .then (environment_user) ->

    mongo.community_user.findOne( user: user, key: @environment.community.key).exec()
  .then (community_user) ->
    if not community_user
      community_user           = new mongo.community_user()
      community_user.user      = user
      community_user.key       = @environment.community.key
      community_user.community = @environment.community
      community_user.network   = @network
      community_user.status    = 'SUBSCRIBED'
      if @environment.community.cfg.type in ['public_pass','private_pass','private']
        community_user.cfg =  {
          pass: user.pass || '',
          url_server: user.url_server  || @environment.community.cfg.url
        }

    community_user.saveAsync()
  .then (community_user_) ->
    @community_user_ = community_user_
    mongo.network_user.findOne( user: user, key: @network.key).exec()
  .then (network_user) ->
    if not network_user
      network_user        = new mongo.network_user()
      network_user.user   = user
      network_user.key    = @network.key
      network_user.network= @network
      network_user.status = 'SUBSCRIBED'
      network_user.cfg    = 
        pass      : @network.cfg.pass
        url_server: @network.cfg.url

    network_user.saveAsync()
  .then (network_user_) ->

    mongo.community.findOne
      _id  : @environment_user.community._id
    .populate('network')
    .exec()
  .then (community) ->
    role = 'player'
    data = {}
    location = {}
    latitude    = user.latitude || 0.0
    longitude   = user.longitude || 0.0
    radius      = user.radius || 0.0
    currentLocation   = user.currentLocation || ""
    location.latitude        = latitude
    location.longitude       = longitude
    location.radius          = radius
    location.currentLocation = currentLocation
    data.location     = location
    data.username     = user.username
    data.password     = user.photos

    data.id          = user._id
    data.email       = user.email
    data.validated   = user.validated || ""
    data.first_name  = user.first_name || ""
    data.last_name   = user.last_name || ""
    data.phone       = user.phone || ""
    data.description = user.description || ""
    data.avatar      = user.avatar || ""
    data.photo       = user.photo || ""
    data.lang        = user.lang || ""
    data.birthday    = user.birthday || ""
    data.job         = user.job || ""
    data.education   = user.education || ""
    data.relationship= user.relationship || ""
    data.updated_at  = moment(user.updatedAt).format('YYYY-MM-DD HH:mm:ss')
    data.created_at  = moment(user.createdAt).format('YYYY-MM-DD HH:mm:ss')
    # data.photos      = photos
    data.environment = fav_environment(@environment, @community_user_.key)
    data.community   = fav_community(community)
    if @network.creator is user
      role = 'editor'
    data.network = role
    @data = data

    return @data
  .catch (err) ->
    console.log err.stack
    return null

@fav_community = fav_community = (val) ->
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
  

@fav_environment = fav_environment = (val, key_comm) ->
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


@get_context = get_context = (req) ->
  token        = req.headers.authorization.split(" ")[1]
  network_key  = req.body.network_key or req.query.network_key || env.network
  user         = req.user
  community   =  env.community
  environment =  env.environment
  Promise.try ->
    # data  :data_adapter.get_me(req.user.dataValues),
    mongo.token.findOne
      value   : token
      is_admin: false
    .exec()
  .then (token) ->
    if token.community
      community = token.community
    if token.environment
      environment = token.environment

    mongo.community.findOne
      key  : community
    .populate('network')
    .exec()
  .then (community) ->
    @default_community = community
    if not community
      throw new Error("NO_DEFAULT_COMMUNITY_FOUND")

    mongo.environment.findOne( key  : environment, community: community )
    .populate('community')
    .exec()
  .then (environment) ->
    @default_environment = environment
    if not environment
      throw new Error("NO_DEFAULT_COMMUNITY_FOUND")

    service.qtask.user.get_create(user)
  .then (qtask_user) ->
    if qtask_user.environment == null
        qtask_user.environment = @default_environment
    qtask_user.saveAsync()
  .then (qtask_user_) ->
    @qtask_user = qtask_user_
    data =
      qtask_user    : @qtask_user
      environment   : @default_environment
      community     : @default_community
      is_white_label: true
    return data
    
@get_me = (user) ->
  if not user
    return {}

  return {
      'email'           : user?.email ? ''
      'id'              : user?._id    ? 0
      'account_expired' : user?.account_expired ? false
      'account_locked'  : user?.account_locked ? false
      'password_expired': user?.password_expired ? false
      'account_locked'  : user?.account_locked ? false
      'agree'           : user?.agree ? false
      'first_name'      : user?.first_name ? ''
      'last_name'       : user?.last_name ? ''
      'phone'           : user?.phone ? false
      'phone1'          : user?.phone1 ? false
      'status'          : user?.status ? false
      'avatar'          : user?.avatar ? ''
      'background_img'  : user?.background_img ? ''
      'latitude'        : user?.latitude ? false
      'longitude'       : user?.longitude ? false
      'id_facebook'     : user?.id_facebook ? ''
      'config_user'     : {},
      'status'          : user?.status
      'validation'      : user?.validation?.split "," ? ''
  }

@get_devices = (devices) ->
  if not devices
    return []
  dev = []
  for device in devices
    dev.push
      id            : device?._id ? ''
      network       : device?.network ? ''
      community     : device?.community    ? ''
      environment   : device?.environment ? ''
      type          : device?.token_typ ? ''
      ip            : device?.ip ? ''
      region        : device?.ip_json?.region ? ''
      country       : device?.ip_json?.countryLong ? ''
      iso_a3        : device?.ip_json?.countryShort ? ''
      city          : device?.ip_json?.city ? ''
      zip_code      : device?.ip_json?.zipCode ? ''
      latitude      : device?.ip_json?.latitude ? ''
      longitude     : device?.ip_json?.longitude ? ''
      time_zone     : device?.ip_json?.timeZone ? ''
      updated_at    : device?.updated_at
  return dev