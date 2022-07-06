mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'
token = mongoose.Schema
  value:
    type    : String
    required: true

  refresh_token:
    type    : String
    required: true


  client:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: true

  user:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: true
    
  firebase_token:
    type    : String
    default: ''

  is_admin:
    type   : Boolean
    default: false


  network:
    type    : String
    required: true
  community:
    type    : String
  environment:
    type    : String

  token_type:
    type   : String
    enum   : ['ANDROID', 'IOS', 'WEB' ]
    default: 'WEB'

  firebase_uid:
    type   : String
    default: ''

  ip:
    type   : String
    default: ''
    
  ip_json:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  is_admin:
    type   : Boolean
    default: false

  created_at: Date
  updated_at: Date

module.exports =   mongoose.model "token", (token
).pre 'save',  utils.update_timestamp

