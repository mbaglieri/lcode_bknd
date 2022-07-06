mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

subscription_spells = mongoose.Schema
 
      
  subscription:
    type: mongoose.Schema.ObjectId
    ref: 'subscription'
    required: true
    
  key:
    type   : String
    default: ''
    required: true

  description:
    type   : String
    default: ''
    required: true

  exec:
    type    : String
    enum    : ['API','QTASK_ONE_TIME', 'QTASK_MONTHLY', 'QTASK_DAILY']
    default : 'API'
    required: true
      
  status:
    type    : String
    enum    : ['ACTIVE', 'DEACTIVATED', 'REMOVED']
    default : 'ACTIVE'
    required: true
  config:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  created_at    : Date
  updated_at    : Date


module.exports = mongoose.model "subscription_spells", (subscription_spells
).pre 'save', utils.update_timestamp
