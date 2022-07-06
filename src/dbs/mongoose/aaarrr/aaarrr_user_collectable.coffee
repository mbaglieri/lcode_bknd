mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'
###
Collect data from the user and generate an appropate state
###
aaarrr_user_collectable = mongoose.Schema

  status:
    type    : String
    enum    : ['PENDING', 'ACTIVE','DENIED','BANNED','REMOVED']
    default : "PENDING"
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
    
  aaarrr:
    type: mongoose.Schema.ObjectId
    ref: 'aaarrr'
    required: true
    
  factory_pre:  [{
    type: mongoose.Schema.ObjectId,
    ref: 'aaarrr_factory_pre' }]
  cfg:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  created_at    : Date
  updated_at    : Date


module.exports = mongoose.model "aaarrr_user_collectable", (aaarrr_user_collectable
).pre 'save', utils.update_timestamp

