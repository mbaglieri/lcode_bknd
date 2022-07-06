Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../config/config'
mongo   = require '../../../../dbs/mongoose'
service = require '../../../../service'
utils   = require '../../../../tools/utils'
data_adapter = require '../../../../adapters'

# @TODO: IMPLEMENT KYC
@upload_kyc =  (req, res) ->
  res.header 'Access-Control-Allow-Origin', '*'
  res.header 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE'
  res.header 'Access-Control-Allow-Headers', 'Content-Type, Authorization'
  res.header 'Content-Type', 'application/json'
  req.socket.setTimeout(10 * 60 * 1000);
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
    Promise.all(service.acl.user.saveUploadedFiles(f, req.user) for f in req.files)
  .then (user_s) ->
    @person.avatar = "#{req.files[0].location}"
    @person.saveAsync()
  .then (person) ->
    @person1 = person
    data_adapter.api.user.profile_user person
  .then (data) ->

    returnset = {
      data  :data
      status: 200,
    }
    res.json returnset
      # data  :data
      # status: 200
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@resend_code = (req,res) ->
  email     = req.body.email

  Promise.try ->
    if not email
      throw new Error('VALIDATION_FIELD_DOESNT_EXIST')
    mongo.user.findOne
      email: email
    .exec()
  .then (user) ->
    if not user
      throw new Error('USER_DOESNT_EXIST')
    service.acl.validation.send(user,'verify')
  .then ( system_validation  ) ->
    res.status(200).send
      id_verif: system_validation._id
      success : true
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)


#/api/phone
@device_verify = (req,res) ->
  id     = req.body.id
  code   = req.body.code

  Promise.try ->
    if not id or not code
      throw new Error('VALIDATION_FIELD_DOESNT_EXIST')
    mongo.system_validation.findById id
    .populate('user')
    .exec()
  .then (candid) ->
    if not candid
      throw new Error('ID_NOT_FOUND')
    if candid.connection_retry > candid.cfg.block_limit
      throw new Error('VALIDATION_SENT_EXEDED')
    candid.connection_retry = candid.connection_retry + 1
    candid.saveAsync()
  .then (candid) ->
    if candid.number_code != parseInt(code)
      throw new Error('VALIDATION_CODE_NOT_FOUND')
    @candid = candid
    mongo.user.findOne
      _id: candid.user._id
  .then (user) ->
    user.status     = "ACTIVE"
    user.validation = @candid.cfg.type
    user.saveAsync()
  .then (user_item) ->
    @show_data = user_item
    @show_data.password = null
    delete @show_data['password']

    service.acl.user.token_generator(req.body, @show_data, utils.get_ip_req(req))
  .then (token_m) ->
    r = 
      token         : token_m.value
      refresh_token : token_m.refresh_token
      data          : data_adapter.api.user.get_me(@show_data)
    res.json r

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

#/api/users
@edit_device_identification = (req,res) ->

  id         = req.body.id or req.query.id
  new_value  = req.body.new_value or req.query.new_value

  Promise.try ->
    if not id or  not  new_value
      throw new Error('VALIDATION_FIELD_DOESNT_EXIST')
    mongo.system_validation.findById id
    .populate('user')
    .exec()
  .then (candid) ->
    if not candid
      throw new Error('ID_NOT_FOUND')
    @candid = candid
    candid.connection_retry = candid.connection_retry + 1
    candid.saveAsync()
  .then (cnd) ->
    if cnd.connection_retry > cnd.cfg.block_limit
      throw new Error('VALIDATION_SENT_EXEDED')

    service.acl.validation.exists(new_value, cnd.cfg.type)
  .then (u_v) ->
    mongo.user.findOne
      _id: candid.user._id
    .exec()
  .then (user) ->
    if(@candid.cfg.type is "PHONE")
      user.phone = new_value
    else
      user.email = new_value
    user.saveAsync()
  .then (user_item) ->
    service.acl.validation.send(user_item,'verify')
  .then (v) ->
    r = 
      status  : 200
      id_verif: v._id
    res.json r
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@forgot = (req,res) ->
  email     = req.body.email
  Promise.try ->
    if not email
      throw new Error('VALIDATION_FIELD_DOESNT_EXIST')
    mongo.user.findOne
      email: email
    .exec()
  .then (user) ->
    if not user
      throw new Error('USER_DOESNT_EXIST')
    @user = user
    service.acl.validation.send(user,'forgot')
  .then ( system_validation  ) ->
    res.status(200).send
      id_verif: system_validation._id
      success : true
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@forgot_code = (req,res) ->
  id       = req.body.id
  code     = req.body.code
  password = req.body.password or req.query.password
  force_close_sessions  = req.body.force_close_sessions or req.query.force_close_sessions || config.validation.force_close_sessions
  
  Promise.try ->
    if not id or not code
      throw new Error('VALIDATION_FIELD_DOESNT_EXIST')
    mongo.system_validation.findById id
    .populate('user')
    .exec()
  .then (candid) ->
    if not candid
      throw new Error('ID_NOT_FOUND')
    if candid.number_code != parseInt(code)
      throw new Error('VALIDATION_CODE_NOT_FOUND')
    if candid.connection_retry > candid.cfg.block_limit
      throw new Error('VALIDATION_SENT_EXEDED')
    candid.connection_retry = candid.connection_retry + 1
    candid.saveAsync()
  .then (candid) ->
    @candid = candid
    mongo.user.findOne
      _id: candid.user._id
  .then (user) ->
    if not user
      throw new Error('NO_PERSON_FOUND')
    user.password = req.body.password

    user.saveAsync()
  .then (user_s) ->
    @user_s = user_s
    service.acl.user.remove_sessions(force_close_sessions, @user_s.id)
  .then ( cst  ) ->
    service.acl.user.token_generator(req.body, @user_s, utils.get_ip_req(req))
  .then (token_m) ->
    returnset =
      status : 200,
      token         : token_m.value,
      refresh_token : token_m.refresh_token
    res.json returnset
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

# /me/change_password
@change_passwrd = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.user.findOne
      _id: req.user._id
  .then (member) ->
    if not member or not req.body.password
      throw new Error('NOT_USER_FOUND')
    member.password = req.body.password

    member.saveAsync()
  .then (user_s) ->
    @show_data =  user_s
    service.acl.user.token_generator(req.body, @show_data, utils.get_ip_req(req))
  .then (token_m) ->
    @token_m = token_m
    res.json
      status       : 200
      token        : @token_m.value
      refresh_token: @token_m.refresh_token

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
