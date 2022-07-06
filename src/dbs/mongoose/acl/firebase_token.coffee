mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

firebase_token = mongoose.Schema

  user:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: true
    
  type_push:
    type        : String
    enum: ['ANDROID','IOS','WEB','UNKNOW']
    default: 'ANDROID'
    required   : true
    
  status:
    type    : String
    enum: ['NOT_VALIDATED','ACTIVE','INACTIVE']
    default: 'NOT_VALIDATED'
    required   : true

  token:
    type     : String
    required: true

  created_at    : Date
  updated_at    : Date


module.exports = mongoose.model "firebase_token", (firebase_token
).pre 'save', utils.update_timestamp
