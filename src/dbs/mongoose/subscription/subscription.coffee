mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

subscription = mongoose.Schema

  key:
    type     : String
    required: false

  description:
    type     : String
    required: false

  type_operation:
    required: false
    type    : String
    enum: ['ONE_TIME','RESERVATION', 'MONTHLY', 'CREDITS']
    default: 'ONE_TIME'

  status:
    type    : String
    enum: ['ACTIVE','INACTIVE']
    default: 'ACTIVE'
    required   : false
      
  type:
    type    : String
    enum    : ['SYSTEM','MERCHANT','COMMUNITY','ENVIRONMENT']
    default : "SYSTEM"
    required: true
    
  currency:
    type    : String
    default : "USD"
    required: true

  group:
    type    : String
    default : "professional"
    required: true
    
  price:
    type    : Number
    default : 0
    required: true

  config:
    type   : mongoose.Schema.Types.Mixed
    default: {}



  downgrade: [{
    type: mongoose.Schema.ObjectId,
    ref: 'subscription' }]

  upgrade: [{
    type: mongoose.Schema.ObjectId,
    ref: 'subscription' }]

  created_at    : Date
  updated_at    : Date


module.exports = mongoose.model "subscription", (subscription
).pre 'save', utils.update_timestamp
