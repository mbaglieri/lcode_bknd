mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

user_subscription_history = mongoose.Schema

  user_subscription:
    type: mongoose.Schema.ObjectId
    ref: 'user_subscription'
    default:null

  user:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    default:null

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
    enum    : ['PENDING','ACTIVE', 'DEACTIVATED', 'REMOVED', 'OVERQUOTA', 'LIMITED']
    default : "ACTIVE"
    required: true

  created_at    : Date
  updated_at    : Date


module.exports = mongoose.model "user_subscription_history", (user_subscription_history
).pre 'save', utils.update_timestamp
