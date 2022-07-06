mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

aaarrr_history = mongoose.Schema
 
  user_state_history:
    type: mongoose.Schema.ObjectId
    ref: 'aaarrr_user_state_history'
    required: true

  ctx_objective_obj:
    type: mongoose.Schema.ObjectId
    required: true
    
  #{system:[user],merchant:[merchant,merchant_client],network:[network_user,community_user,environment_user]}
  ctx_objective_clazz:
    type    : String
    enum    : ['SYSTEM','MERCHANT','COMMUNITY','ENVIRONMENT']
    default : "SYSTEM"
    required: true

  ctx_obj:
    type: mongoose.Schema.ObjectId
    required: true

  #{system:[user],merchant:[merchant,merchant_client],network:[network_user,community_user,environment_user]}
  ctx_clazz:
    type    : String
    enum    : ['SYSTEM','MERCHANT','COMMUNITY','ENVIRONMENT']
    default : "SYSTEM"
    required: true

  state:
    type    : String
    enum    : ['AWARENESS','ADQUISITION','ACTIVATION','RETENTION','REVENUE','REFERRAL']
    default : "AWARENESS"
    required: true

  status:
    type    : String
    enum    : ['ACTIVE','PRE_PROCESSED','PROCESSED','REMOVED','DEACTIVATED', ]
    default : "ACTIVE"
    required: true

  json_data:
    type   : mongoose.Schema.Types.Mixed
    default: {}
 

  created_at    : Date
  updated_at    : Date


module.exports = mongoose.model "aaarrr_history", (aaarrr_history
).pre 'save', utils.update_timestamp
