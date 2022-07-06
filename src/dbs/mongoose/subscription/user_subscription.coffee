mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

user_subscription = mongoose.Schema



  user:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: false

  subscription:
    type: mongoose.Schema.ObjectId
    ref: 'subscription'
    required: true

  tx:
    type    : mongoose.Schema.ObjectId
    ref     : 'user_subscription_tx'
    required: true
  plan:
    type    : String
    enum    : ['ONE_TIME','RESERVATION', 'MONTHLY', 'CREDITS']
    default : "ONE_TIME"
    required: true

  type:
    type    : String
    enum    : ['SYSTEM','MERCHANT','COMMUNITY','ENVIRONMENT']
    default : "SYSTEM"
    required: true
    
  expiration_date: 
    type    : Date
    required: true

  status:
    type    : String
    enum    : ['PENDING','ACTIVE', 'PROCECING', 'DEACTIVATED', 'REMOVED']
    default : "ACTIVE"
    required: true

  created_at    : Date
  updated_at    : Date

user_subscription.index({user: 1,subscription: 1,tx: 1}, {unique: true})

module.exports = mongoose.model "user_subscription", (user_subscription
).pre 'save', utils.update_timestamp
