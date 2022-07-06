Promise    = require 'bluebird'
moment     = require 'moment'
{catchAsync} = require  "../../tools/catch.async";
service  = require '../../service'
log      = require('../../tools/log').create 'UnregisteredController'
utils    = require '../../tools/utils'
mongo    = require '../../dbs/mongoose'

@countries = catchAsync (req, res) ->
  init  = parseInt(req.query.init) || 0
  limit = parseInt(req.query.limit) || 10
  q = req.query.q || ""
  page = init
  init = init * 10
  Promise.try ->
    mongo.countries.find
      status : 'ACTIVE'
      name   : { '$regex' : q, '$options' : 'i' }
    .skip(init)
    .limit(limit)
    .exec()
  .then (category_type_d) ->
    res.json category_type_d
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@currency_by_country = catchAsync (req, res) ->
  country_name  = req.query.country_name || "Argentina"
  init  = parseInt(req.query.init) || 0
  limit = parseInt(req.query.limit) || 10
  page = init
  init = init * 10
  Promise.try ->
    mongo.countries.findOne
      name: country_name
    .exec()
  .then (country) ->
    if not country
      throw new Error("COUNTRY_NOT_FOUND")
    mongo.currencies.find
      country: country
    .skip(init)
    .limit(limit)
    .exec()
  .then (currency) ->
    res.json currency
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@msg_balancer = catchAsync (req, res) ->
  id = req.query.search || "+5491164616122"
  Promise.try ->
    service.acl.sms.twilio_test("+5491164616122")
  .then (num) ->
    res.send
      'status': 200
  .catch (err) ->
    log.e "Error starting server, #{err.stack}"
    res.send
      'status': 400

@test_cdn = catchAsync (req, res) ->
  res.header 'Access-Control-Allow-Origin', '*'
  res.header 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE'
  res.header 'Access-Control-Allow-Headers', 'Content-Type, Authorization'
  res.header 'Content-Type', 'application/json'
  req.socket.setTimeout(10 * 60 * 1000);
  f = 0
  if not req.files
    res.json
      status: 400
      files : 0
      data   : []
  else
    res.json
      status: 200
      data   : req.files[0]

@test_twilio_sms = catchAsync (req, res) ->
  id = req.query.search || "+5491164616122"
  Promise.try ->
    service.acl.sms.twilio_test(id)
  .then (num) ->
    res.send
      'status': 200
  .catch (err) ->
    log.e "Error starting server, #{err.stack}"
    res.send
      'status': 400

@test_send_email = catchAsync (req, res) ->
  Promise.try ->
    service.mail.test_send_email("04",req.query.email)
  .then (num) ->
    res.send
      'status': 200
  .catch (err) ->
    log.e "Error starting server, #{err.stack}"
    res.send
      'status': 400

@test_send_api_req = catchAsync (req, res) ->
  Promise.try ->
    service.axios.findQoute("PETR4")
  .then (num) ->
    res.send
      'status': 200
  .catch (err) ->
    log.e "Error starting server, #{err.stack}"
    res.send
      'status': 400

@quota_data =  (req, res) ->
  time = Date.now().toString().slice(8, 13);
  res.json({ time, data: '1' });
  
@sexual_orientation =  (req, res) ->
  returnset = []

  returnset.push
    key  : 'homosexual'
    lang : {'en':'homosexual','es':'homosexual'}
    value: 'homosexual'

  returnset.push
    key  : 'heterosexual'
    lang : {'en':'heterosexual','es':'heterosexual'}
    value: 'heterosexual'

  returnset.push
    key  : 'bisexual'
    lang : {'en':'bisexual','es':'bisexual'}
    value: 'bisexual'

  res.send
    'status': 200
    'data'  : returnset