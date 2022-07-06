Promise   = require 'bluebird'
moment    = require 'moment'
request   = require 'request'
requestPM = Promise.promisifyAll require 'request'
config    = require '../../../../config/config'
mongo     = require '../../../../dbs/mongoose'
serviceAccount = require("../../../../config/firebase.json");
#firebase require setup emiter # Possible EventEmitter memory leak detected. 16 uncaughtException listeners added to [process]. Use emitter.setMaxListeners() to increase limit
# admin     = require "firebase-admin"
# require('events').EventEmitter.defaultMaxListeners = 15;

@push_test =  (req, res) ->
  res.header 'Access-Control-Allow-Origin', '*'
  res.header 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE'
  res.header 'Access-Control-Allow-Headers', 'Content-Type, Authorization'
  res.header 'Content-Type', 'application/json'

  returnset = {
    status: 404

  }
  if not req.user.firebase_uid
    res.json returnset
    return;
  # message =
  #   to: req.user.firebase_uid
  #   collapse_key: 'your_collapse_key'
  #   data: your_custom_data_key: 'your_custom_data_value'
  #   notification:
  #     title: 'Title of your push notification'
  #     body: 'Body of your push notification'
  options =
    uri: 'https://fcm.googleapis.com/fcm/send'
    method: 'POST'
    headers:
      'Authorization': "key=#{config.firebase.key}"
      'project_id'   : config.firebase.project_id
    json:
      registration_ids: [req.user.firebase_uid]
      priority: 'high',
      project_id: config.firebase.project_id,
      data:
        title: req.body.message_title
        body :  req.body.message

  request options, (error, response, body) ->
    if !error and response.statusCode == 200
      d_json = {
        status: 200
        data  : body
      }

    else
      d_json = {
        status: 500
        data  : body
      }
      res.json d_json

@firebase_test = (req, res) ->
  bdy_token  = req.body.firebase_token or req.query.firebase_token
  type_push  = req.body.type_push or req.query.type_push || 'ANDROID'
  title      = req.body.title or req.query.title || 'this is a tst'
  body       = req.body.content or req.query.content || 'this is a tst'

  dta = 
    title: fcm_queue.notification.title
    body : fcm_queue.notification.body
  if type_push == 'ANDROID'
    options =
      uri: 'https://fcm.googleapis.com/fcm/send'
      method: 'POST'
      headers:
        'Authorization': "key=#{config.firebase.key}"
        'project_id'   : config.firebase.project_id
      json:
        registration_ids: bdy_token
        priority        : 120,
        data            : dta
        android:
          ttl:"86400s"
  else
    options =
      uri: 'https://fcm.googleapis.com/fcm/send'
      method: 'POST'
      headers:
        'Authorization': "key=#{config.firebase.key}"
        'project_id'   : config.firebase.project_id
      json:
        registration_ids: bdy_token
        priority        : 120,
        data            : dta,
        collapse_key    : 'test',
        notification    : dta

  if options
    request options, (error, response, body) ->
      if !error and response.statusCode == 200
        d_json = {
          status: 200
          data  : body
        }
      else
        d_json = {
          status: 500
          data  : body
        }
      res.json d_json

@push_test_new =  (req, res) ->
  res.header 'Access-Control-Allow-Origin', '*'
  res.header 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE'
  res.header 'Access-Control-Allow-Headers', 'Content-Type, Authorization'
  res.header 'Content-Type', 'application/json'

  returnset = {
    status: 404

  }
  if not req.user.firebase_uid
    res.json returnset
    return;
  Promise.try ->
    payload =
      data:
        MyKey1:"test"
    options =
      priority  :"high"
      timeToLive: 60*60*24
    # admin.messaging().sendToDevice(req.user.firebase_uid, payload, options)
  # .then (num) ->
    res.json
      message: options
      status : 200
  .catch (err) ->

    res.json err
