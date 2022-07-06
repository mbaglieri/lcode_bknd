mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

aaarrr_factory_pre = mongoose.Schema

  aaarrr_factory:
    type: mongoose.Schema.ObjectId
    ref: 'aaarrr_factory'
    default:null
    
  status:
    type   : String
    enum: ['INACTIVE', 'ACTIVE']
    default: "ACTIVE"

  name :
    type    : String
    required: true

  clazz:
    type    : String
    enum    : ['USER_SUBSCRIPTION','DISPUTE','MERCHANT',
              'MERCHANT_CLIENT','MERCHANT_TX','MERCHANT_PRODUCT','MERCHANT_DEBATE',
              'USER_ADDRESS','FIREBASE_TOKEN','SYSTEM_VALIDATION','NETWORK_USER',
              'NETWORK_USER_HISTORY','COMMUNITY_USER','COMMUNITY_USER_HISTORY','ENVIRONMENT_USER',
              'ENVIRONMENT_USER_HISTORY', 'FIREBASE_MSG', 'NOTIFICATION_CENTER', 'USER_SUBSCRIPTION', 'QTASK_USER_EXEC', 'QTASK_USER_EXEC_HISTORY']
    default : "USER_SUBSCRIPTION"
    required: true
    
  ctx_objective_clazz:
    type    : String
    enum    : ['USER','MERCHANT','MERCHANT_CLIENT','COMMUNITY','ENVIRONMENT']
    default : "USER"
    required: true

  ctx_clazz:
    type    : String
    enum    : ['SYSTEM','MERCHANT','COMMUNITY','ENVIRONMENT']
    default : "SYSTEM"
    required: true
    
  execution_rules:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  created_at: Date
  updated_at: Date

# aaarrr_factory_pre.index({ 'coordinates': '2dsphere' })

module.exports = mongoose.model "aaarrr_factory_pre", (aaarrr_factory_pre
).pre 'save', utils.update_timestamp

