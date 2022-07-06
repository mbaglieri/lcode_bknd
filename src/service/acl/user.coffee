Promise  = require 'bluebird'
async    = require 'async'

request       = Promise.promisifyAll require 'request'
fs            = Promise.promisifyAll require 'fs'
mongo         = require '../../dbs/mongoose'
config        = require '../../config/config'
{env}         = require '../../config/env'
log           = require('../../tools/log').create 'UserService'
jwt           = require 'jsonwebtoken'
randtoken     = require 'rand-token'
data_adapter  = require '../../adapters'
utils         = require '../../tools/utils'
firebase      = require './firebase'
validation    = require './validation'
qtask         = require '../qtask'
@bearer_user = (accessToken) ->
  Promise.try ->
    mongo.token.findOne
      value   : accessToken
      is_admin: false
    .populate('user')
    .exec()
  .then (token) ->
    if not token
      throw new Error('NOT_FOUND')

    return token.user
  .catch (err) ->
    return false
    
@bearer_admin = (accessToken) ->
  response = {}
  Promise.try ->
    mongo.token.findOne
      value   : accessToken
    .populate('user')
    .exec()
  .then (token) ->
    log.d token
    @token = token
    if not token
      throw new Error('token_not_found')
    mongo.user_role.find
      user: token.user
    .populate('role')
    .exec()
  .then (user_roles) ->
    @roles = []
    @roles.push rl3 for rl3 in user_roles
    response       = token.user
    response.roles = @roles
    delete response['password']
    return response
  .catch (err) ->
    return false
    
@decode_user_pass = (params) ->
  Promise.try ->
    mongo.token.findOne
      value: params.token
    .exec()
  .then (token) ->
    @token = token
    new Promise (resolve, reject) ->
      jwt.verify params.token, config.express.session_secret, (err, decoded) ->
        if err
          @token.removeAsync()
          reject err
        resolve decoded
  .then (data) ->
    return data

  .catch (err) ->
    throw new Error('TOKEN_REMOVED')

@getUserByEmail = (email) ->
  Promise.try ->
    mongo.user.findOne
      email: email
    .exec()
  .then (person) ->
    if not person
      throw new Error('USER_NOT_FOUND')

    return person
  .catch (err) ->
    return null

@build_user = (params, ip) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    _create_user_without_sms params, false
  .then (res) ->
    @show_data = res[0]
    @token_m   = res[1]
    @net       = res[2]

    validation.send(@show_data, 'registration')
  .then ( phone_v  ) ->
    @show_data.password = null
    code_phone          = ""

    delete @show_data['password']

    r = 
      status        : 200
      id_verif_phone: @system_validation._id

    if config.verification.token_on_create
      r.token         = @token_m.value
      r.refresh_token = @token_m.refresh_token

    if config.show_verif_phone 
      r.code_phone = @system_validation.number_code

    return r
  .catch (err) ->
    if err.message not in ['NOT_USER_FOUND']
      log.e "#{err.stack}"
    
_create_user_without_sms =(params, is_calendar, ip) ->
  Promise.try ->
    create_user params, is_calendar
  .then (user_s) ->

    #get the value and hide for user password
    @show_data =  user_s
    #TODO: REVIEW CREATE_USER_WITHOUT_SMS
    networkValidation(params.network_key, @show_data)
  .then ( net  ) ->
    @net = net.network
    params =
      user          : @show_data
      device_key    : params.device_key || 'WEB'
      firebase_token: params.firebase_token || ''
    token_generator(params, @show_data)
  .then (token_m) ->
    @token_m        = token_m
    qtask.user.get_create(@show_data)
  .then (hai_) ->
    @hai_ = hai_
    return [@show_data, @token_m, @net]

@create_user = create_user = (params, is_calendar) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    if is_calendar
      q = 
        email  : params.email
    else
      q = 
        phone  : params.phone
        visible: true
    mongo.user.findOne q
    .exec()
  .then (user) ->
    if not user
      data = params
      data.username = data.email
      phone = ""
      if params.phone
        phone = params.phone.split(/\s/).join('');
        phone = phone.split("-").join('');
        phone = phone.split("+").join('');
        
      user = mongo.user
        first_name     : params.first_name
        last_name      : params.last_name
        phone          : phone
        email          : params.email
        username       : params.email
        password       : params.password
        latitude       : params.latitude || 0.0
        longitude      : params.longitude || 0.0
        avatar         : env.spaces.img_avatars
        photo          : env.spaces.img_profile_back
        device_key     : params.device_key || "WEB"
        device_token   : params.device_token || "NOT_IMPLEMENTED_WEB"
        firebase_uid   : params.firebase_token || "NOT_IMPLEMENTED"
        background_img : params.background_img || env.spaces.img_profile_back

    user.saveAsync()
  .then (user_s) ->
    return user_s

###
Save the hai worker assigned
###
@create_get_qtask_user = create_get_qtask_user  = (user, worker, status = 'INTRO', environment =  env.environment ) ->

  Promise.try ->
    if not user
      throw new Error('NOT_USER_FOUND')

    mongo.environment.findOne(  key: env.environment )
    .exec()
  .then (env) ->
    @env = env
    if not env
      throw new Error('ENVIRONMENT_NOT_FOUND')

    qtask.user.get_create(user)
  .then (hai) ->
    if status not in ['INTRO','CONNECTED']
      hai.status = status
    else
      hai.status           = 'CONNECTED'
      hai.connection_retry = 0
    hai.environment =  @env
    #UPDATE THE WORKER IF THE IA NEED TO BE UPDATED
    if worker
      hai.hai_worker = worker

    hai.pong_date = new Date()
    hai.saveAsync()
  .then (hai_s) ->
    if hai_s and hai_s.length > 0
      return hai_s[0]
    else
      return hai_s

  .catch (err) ->
    if err.message not in ['NOT_USER_FOUND']
      log.e "#{err.stack}"

#network_validation for login_registration_forgot    
@networkValidation = networkValidation = (network_key, user, environment_key = null) ->
  if not network_key or network_key == ""
    network_key = env.network
  if not environment_key or environment_key 
    environment = env.environment
  Promise.try ->
    mongo.network.findOne
      key: network_key
    .exec()
  .then (network) ->
    if not network
      throw new Error("NO_NETWORK_FOUND")
    @network = network

    mongo.environment.findOne(  key: environment )
    .populate('community')
    .exec()
  .then (env) ->
    @env = env
    if not network
      throw new Error("NO_ENVIRONMENT_FOUND")

    mongo.network_user.findOne( user  : user, key: network_key).exec()
  .then (network_user) ->
    if not network_user
      cfg_json     = 
        pass      : @network.cfg.pass
        url_server: @network.cfg.url

      network_user = new mongo.network_user
        user      : user
        key       : network_key
        network   : @network
        status    : 'SUBSCRIBED'
        cfg       : cfg_json
      
    else if network_user.status is "UNSUBSCRIBED"
      network_user.status = 'SUBSCRIBED'

    network_user.saveAsync()
  .then (network_user_) ->
    @default_community = @env.community

    mongo.community_user.findOne( user  : user, key: @env.community.key).exec()
  .then (community_user) ->
    if not community_user
      community_user = new mongo.community_user()
      community_user.user      = user
      community_user.key       = @default_community.key
      community_user.community = @default_community
      community_user.network   = @network
      community_user.status    = 'SUBSCRIBED'
      if @default_community.cfg.type in ['public_pass','private_pass','private']
        community_user.cfg =  {
          pass: params.pass || '',
          url_server: params.url_server  || @default_community.cfg.url
        }
    else if community_user.status is "UNSUBSCRIBED"
      community_user.status = 'SUBSCRIBED'

    community_user.saveAsync()
  .then (community_user_) ->

    create_get_qtask_user( user, null, 'CONNECTED')
  .then (hai) ->
    if not hai
      throw new Error('HAI_NOT_FOUND')
    @hai = hai
    if not @hai?.environment
      @hai.environment = @env
    @hai.saveAsync()
  .then (hai_) ->
    mongo.environment_user.findOne( user  :user, environment: @env )
    .exec()
  .then (environment_d) ->
    @environment_user = environment_d
    if not environment_d
      environment_d  = new mongo.environment_user(
        user       : user,
        key        : @env.key,
        community  : @env.community,
        environment: @env,
        status     : "SUB"
      )
    else if environment_d.status is "UNSUB"
      environment_d.status = 'SUB'
    environment_d.saveAsync()
  .then (env_d) ->
    resp = 
      network    : @network
      community  : @default_community
      environment: @env
    return resp

@loginValidation = (user, net) ->
  if user.validation != "NOT_VALIDATED"
    return

  Promise.try ->
    validation.send(user, 'login')
  .then ( system_validation  ) ->
    return system_validation

@token_generator = token_generator = (params, show_data, ip) ->
  firebase_token = params.firebase_token || ''
  device_key     = params.device_key     || 'WEB'
  network        = params.network        || env.network
  community      = params.community      || "#{network}_hall"
  environment    = params.environment    || "#{network}_hall_guest"
  Promise.try ->
    mongo.refresh_token.findOne
      user    : show_data
      network : network
    .exec()
  .then (r_token) ->
    if not r_token
      r_token = new mongo.refresh_token(
        value   : randtoken.uid(256)
        user    : show_data
        network : network
        community   : community
        environment : environment
      )

    r_token.saveAsync()
  .then (refresh_token) ->
    @refresh_token = refresh_token
    params =
      user          : show_data
      device_key    : device_key
      firebase_token: firebase_token
    firebase.add_token params
  .then (user_item) ->
    mongo.token.findOne
      user          : show_data
      network       : network
      firebase_token: firebase_token
      ip            : ip
    .exec()
  .then (token) ->
    if not token
      token_j = jwt.sign show_data.toJSON(), config.express.session_secret, {expiresIn: config.express.expire }
      token   = new mongo.token
        value         : token_j
        client        : show_data
        refresh_token : @refresh_token.value
        user          : show_data
        firebase_token: firebase_token
        network       : network
        community     : community
        environment   : environment
        ip            : ip
        ip_json       : utils.get_ip_info(ip)
    
    token.saveAsync()
  .then (token_m) ->
    return token_m
 
@remove_sessions = remove_sessions = (force_removal, user   ) ->
  if not force_removal
    return 
  Promise.try ->
    mongo.refresh_token.deleteManyAsync
      user  : user   
  .then (stris) ->
    mongo.token.deleteManyAsync
      user   : user   
  .then (stris) ->
    return stris

@add_photos = add_photos = (params, user) ->
  Promise.try ->
    content_type = 1
    if 'image' in params.mimetype.split '/'
      content_type = 1
    else 
      throw new Error("IMAGE_NOT_FOUND")
    data =
      filename    : params.key
      fieldname   : params.fieldname
      destination : params.destination
      originalname: params.originalname
      size        : params.size
      mimetype    : params.mimetype
      encoding    : params.encoding
      location    : params.location
      content_type: content_type
      user        : user
    user = mongo.user_photo data
    user.saveAsync()
  .then (user_s) ->
    return user_s

@add_file = add_file = (params, user) ->
  Promise.try ->
    content_type = 1
    if 'image' in params.mimetype.split '/'
      content_type = 1
    else 
      throw new Error("IMAGE_NOT_FOUND")

    data =
      filename    : params.key
      fieldname   : params.fieldname
      originalname: params.originalname
      size        : params.size
      mimetype    : params.mimetype
      encoding    : params.encoding
      location    : params.location
      content_type: content_type
      user        : user
    user = mongo.aws_user_files data
    user.saveAsync()
  .then (user_s) ->
    return user_s

@get_files = (params, user) ->
  d_json = {
    status: 404
  }
  perPage = 10
  page    = params.page || 0
  Promise.try ->

    mongo.aws_user_files.find
        user         :  user
    .select(["-__v","-created_at"])
    .limit(perPage)
    .skip(perPage * page)
    .sort( created_at: 'asc')
    .exec()
  .then (photos) ->
    phts = []
    for r in photos
      phts.push r 
    returnset = {
      data  : phts
      status: 200
    }
    return returnset

@remove_file = (params,user) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.aws_user_files.findOne
      user   : user
      _id    : params.id_file
    .exec()
  .then (aws_user_files) ->
    if not aws_user_files
      throw new Error('NOT_FOUND')
    aws_user_files.removeAsync()
  .then (num) ->
    return  num 
