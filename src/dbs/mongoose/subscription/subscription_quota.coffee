mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

SubscriptionQuotaSchema = mongoose.Schema
  key:
    type   : String
    default: ''
    required: true

  subscription:
    type: mongoose.Schema.ObjectId
    ref: 'subscription'
    required: true

  user:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: false
 
  cfg:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  status:
    type    : String
    enum    : ['INACTIVE', 'ACTIVE']
    default : "ACTIVE"
    required: true

  created_at    : Date
  updated_at    : Date

SubscriptionQuotaSchema.index({key: 1,user:1}, {unique: true})

module.exports = mongoose.model "subscription_quota", (SubscriptionQuotaSchema
).pre 'save', utils.update_timestamp
