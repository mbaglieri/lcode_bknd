Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../config/config'
mongo   = require '../../../../dbs/mongoose'
service  = require '../../../../service'
{env}    = require '../../../../config/env'
utils    = require '../../../../tools/utils'
data_adapter = require '../../../../adapters'
request   = require 'request'
requestPM = Promise.promisifyAll require 'request'

@postUsers = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->

    service.acl.validation.exists(req.body.email, 'EMAIL')
  .then (u_v) ->
    service.acl.validation.exists(req.body.phone, 'PHONE')
  .then (u_v) ->
    service.acl.user_user(req.body, utils.get_ip_req(req))
  .then (response) ->
    @response = response
    res.json @response
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)


@new_user = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    service.acl.validation.exists(req.body.email, 'EMAIL')
  .then (u_v) ->
    service.acl.validation.exists(req.body.phone, 'PHONE')
  .then (u_v) ->
    data = req.body
    data.username = data.email
    data.background_img = data.background_img || env.spaces.img_profile_back
    mongo.user data
    .saveAsync()
  .then (user_s) ->

    #get the value and hide for user password
    @show_data =  user_s
    service.acl.validation.send(@show_data, 'registration')
  .then ( system_validation  ) ->
    @system_validation = system_validation

    service.acl.user.token_generator(req.body, @show_data, utils.get_ip_req(req))
  .then (token_m) ->
    @token_m = token_m
    service.acl.user.create_get_qtask_user @show_data.id, null
  .then (hai_) ->
    d_json.hai = hai_


    @show_data.password = null
    delete @show_data['password']

    r = 
      status        : 200
      id_verif_phone: @system_validation._id

    if config.verification.token_on_create
      r.token         = @token_m.value
      r.refresh_token = @token_m.refresh_token
      r.data          = data_adapter.api.user.get_me(@show_data)

    res.json r

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

#check https://ipapi.co/#api to get user context data (  and base on that validate security layer 2)
@login = (req,res) ->
  email        = req.body.email or req.query.email
  password     = req.body.password or req.query.password
  network_key  = req.body.network_key or req.query.network_key || env.network
  firebase_token = req.body.firebase_token or req.query.firebase_token || ''
  device_key     = req.body.device_key  or req.query.device_key || 'WEB'
  returnset = {
    status: 404
  }
  Promise.try ->
    mongo.user.findOne
      email: email
    .exec()
  .then (person) ->
    if not person
      throw new Error('NO_PERSON_FOUND')

    if not utils.authenticate password, person.password
      throw new Error('USER_NOT_AUTHENTICATED')
    if not firebase_token
      firebase_uid = person.firebase_uid
    else
      person.firebase_uid = firebase_token
    person.saveAsync()
  .then (person) ->
    @person    = person
    @show_data = person

    service.acl.user.networkValidation(network_key, @person, env.environment)
  .then ( net  ) ->
    @net = net.network

    params =
      user          : person
      device_key    : @device_key
      firebase_token: firebase_token
      network       : net.network.key
      community     : net.community.key
      environment   : net.environment.key
    service.acl.user.token_generator(params, @show_data, utils.get_ip_req(req))
  .then (token_m) ->
    @token_m = token_m

    service.acl.user.loginValidation(@show_data, @net)
  .then ( system_validation  ) ->
    if system_validation
      returnset =
        status        : 200
        status        : @person.status
        validation    : @person.validation
        id_verif_phone: system_validation._id

      if config.show_verif_phone
        returnset.code_phone = system_validation.number_code
    else
      returnset =
        status        : 200
        token         : @token_m.value
        refresh_token : @token_m.refresh_token
        status        : @person.status
        validation    : @person.validation

    res.json returnset

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)



#check https://ipapi.co/#api to get user context data (  and base on that validate security layer 2)
@login_guest = (req,res) ->
  network_key    = req.body.network_key or req.query.network_key || env.network
  firebase_token = req.body.firebase_token or req.query.firebase_token || ''
  device_key     = req.body.device_key  or req.query.device_key || 'WEB'
  returnset = {
    status: 404
  }
  ip =  utils.get_ip_req(req).split(',')[0];
  ip = ip.split(':').slice(-1);
  Promise.try ->
    ip_user = ip[0].split(".").join("");
    ip_user = ip_user + "@doors.digital"
    parms = 
      first_name  : 'unknow'
      last_name   : 'unknow'
      phone       : 'unknow'
      email       : ip_user
      username    : ip_user
      password    : ip_user
      device_key  : device_key
    service.acl.user.create_user parms, true
  .then (person) ->
    if not person
      throw new Error('NO_PERSON_FOUND')

    @person    = person
    @show_data =  person

    service.acl.user.create_get_qtask_user( @person, null, 'CONNECTED')
  .then (hai_s) ->
    if not hai_s
      throw new Error('HAI_NOT_FOUND')
    service.acl.user.networkValidation(network_key, @person, env.environment)
  .then ( net  ) ->
    @net = net.network

    params =
      user          : @person
      device_key    : @device_key
      firebase_token: firebase_token
      network       : net.network.key
      community     : net.community.key
      environment   : net.environment.key
    service.acl.user.token_generator(params, @show_data, utils.get_ip_req(req))
  .then (token_m) ->
    @token_m = token_m

    returnset = {
      status        : 200
      token         : @token_m.value
      refresh_token : @token_m.refresh_token
    }
    res.json returnset

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@upload_photos =  (req, res) ->
  utils.set_req_res_upload(req,res)
  upload_type = req.body.upload_type or req.query.upload_type
  f = 0
  if not req.files or not req.user
    res.json
      status: 200
      files : 0
      data   : []
    return;

  Promise.try ->

    @person = req.user
    Promise.all(service.acl.user.add_photos(f, req.user) for f in req.files)
  .then (user_s) ->
    if upload_type is 'photo'
      @person.avatar = "#{req.files[0].location}"
    else
      @person.background_img = "#{req.files[0].location}"

    @person.saveAsync()
  .then (person) ->
    res.json data_adapter.api.user.get_me person
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@upload_file =  (req, res) ->
  utils.set_req_res_upload(req,res)
  upload_type = req.body.upload_type or req.query.upload_type
  f = 0
  if not req.files or not req.user
    res.json
      status: 200
      files : 0
      data   : []
    return;

  Promise.try ->
    mongo.user.findOne
      _id: req.user._id
    .exec()
  .then (person) ->
    if not person
      throw new Error('NO_USER')

    @person = person
    Promise.all(service.acl.user.add_file(f, req.user) for f in req.files)
  .then (user_s) ->
    res.json user_s
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@get_files = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    service.acl.user.get_files(req.query, req.user)
  .then (files) ->
    res.send JSON.stringify files
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)


@remove_file = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    service.acl.user.remove_file(req.query, req.user)
  .then (files) ->
    res.send JSON.stringify files
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@my_devices = (req,res) ->
  Promise.try ->
    token = req.headers['authorization'].split(' ')[1]
    mongo.token.findOne
      value   : token
    .exec()
  .then (token) ->
    if not token
      throw new Error('token_not_found')
    network = null 
    if !(token.network is env.network)
      network = token.network

    parm = 
      user    : req.user
      network : network
      token_id: [token._id]

    service.acl.user.devices_connected(parm)
  .then ( tokns  ) ->
    res.json tokns
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@remove_my_devices = (req,res) ->
  Promise.try ->
    token = req.headers['authorization'].split(' ')[1]
    mongo.token.findOne
      value   : token
    .exec()
  .then (token) ->
    if not token
      throw new Error('token_not_found')
    network = null 
    if !(token.network is env.network)
      network = token.network

    parm = 
      user    : req.user
      network : network
      token_id: [token._id]

    service.acl.user.rm_devices_connected(parm)
  .then ( tokns  ) ->
    res.json tokns
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)


@get_me =  (req, res) ->
  res.json data_adapter.api.user.get_me req.user

    
@logout = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    @firebase_token = req.body.firebase_token or req.query.firebase_token
    if not device_key
      throw new Error("DEVICE_TOKEN")

    if not firebase_token
      throw new Error("DEVICE_KEY")

    params =
      user          : req.user
      firebase_token: @firebase_token
    service.acl.firebase.remove_token params
  .then (user_item) ->
    res.json
      status : 200
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

# Create endpoint /me for PUT
@update_profile = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.user.findOne
      _id: req.user._id
  .then (ff) ->
    if req.body.email
      ff.email = req.body.email

    if req.body.description
      ff.description = req.body.description

    if req.body.first_name
      ff.first_name = req.body.first_name

    if req.body.last_name
      ff.last_name = req.body.last_name

    if req.body.latitude
      ff.latitude = req.body.latitude

    if req.body.longitude
      ff.longitude = req.body.longitude

    if req.body.radius
      ff.radius = req.body.radius

    if req.body.currentLocation
      ff.currentLocation = req.body.currentLocation

    if req.body.lang
      ff.lang = req.body.lang

    if req.body.avatar
      ff.avatar = req.body.avatar

    if req.body.birthday
      ff.birthday = req.body.birthday

    if req.body.job
      ff.job = req.body.job

    if req.body.education
      ff.education = req.body.education

    if req.body.relationship
      ff.relationship = req.body.relationship

    ff.saveAsync()
  .then (user_item) ->
    res.json data_adapter.api.user.get_me user_item
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

#/api/users
@edit_phone_email = (req,res) ->

  new_value  = req.body.new_value or req.query.new_value
  type_op    = req.body.type_op   or req.query.type_op  || "PHONE"
  type_op_key = 'change_phone'
  if type_op isnt "PHONE"
    type_op     = "EMAIL"
    type_op_key = "change_email"
  Promise.try ->
    if not type_op or  not  new_value
      throw new Error('VALIDATION_FIELD_DOESNT_EXIST')
    

    service.acl.validation.exists(new_value, type_op)
  .then (u_v) ->
    service.acl.validation.send(req.user,type_op_key)
  .then (system_validation) ->
    system_validation.cfg.new_value = new_value
    system_validation.markModified('cfg');
    system_validation.saveAsync()
  .then (system_validation) ->
    r = 
      status  : 200
      id      : system_validation._id
    res.json r
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

#/api/phone
@edit_phone_email_verify = (req,res) ->
  id     = req.body.id
  code   = req.body.code

  Promise.try ->
    if not id or not code
      throw new Error('VALIDATION_FIELD_DOESNT_EXIST')
    mongo.system_validation.findById id
    .exec()
  .then (candid) ->
    if not candid
      throw new Error('ID_NOT_FOUND')
    if candid.number_code != parseInt(code)
      throw new Error('VALIDATION_CODE_NOT_FOUND')
    if candid.connection_retry > candid.cfg.block_limit
      throw new Error('VALIDATION_SENT_EXEDED')
    @new_value = candid.cfg.new_value 
    candid.connection_retry = candid.connection_retry + 1
    candid.saveAsync()
  .then (candid) ->
    @candid = candid
    mongo.user.findOne
      _id: req.user._id
    .exec()
  .then (person) ->
    if @candid.cfg.type is "PHONE"
      person.phone = @new_value
    else
      person.email = @new_value

    person.saveAsync()
  .then (user_item) ->
    r = 
      status  : 200
    res.json r

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

