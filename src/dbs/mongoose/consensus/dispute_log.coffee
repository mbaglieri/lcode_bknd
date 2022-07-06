mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

dispute_log = mongoose.Schema
 
  user:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: true
  
  dispute:
    type: mongoose.Schema.ObjectId
    ref: 'dispute'
    required: false
      
  status:
    type    : String
    enum    : ['MESSAGE', 'PETITON']
    default : "MESSAGE"
    required: true
  clazz:
    type    : String
    enum    : ['SUBSCRIPTION','PRODUCTS', 'AUCTION']
    default : "SUBSCRIPTION"
    required: true

  actor:
    type    : String
    enum    : ['BUYER', 'SELLER', 'ARBITER']
    default : "BUYER"
    required: true

  open_by_buyer:
    type   : String
    default: ''

  json_data:
    type   : mongoose.Schema.Types.Mixed
    default: {}
 

  created_at    : Date
  updated_at    : Date

module.exports = mongoose.model "dispute_log", (dispute_log
).pre 'save', utils.update_timestamp
