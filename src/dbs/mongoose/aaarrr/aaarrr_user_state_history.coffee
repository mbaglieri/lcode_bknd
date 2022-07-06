mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

aaarrr_user_state_history = mongoose.Schema

  status:
    type    : String
    enum    : ['PENDING', 'ACTIVE','DEACTIVATED','REMOVED']
    default : "PENDING"
    required: true

  aaarrr:
    type: mongoose.Schema.ObjectId
    ref: 'aaarrr'
    required: true

  aaarrr_user_state:
    type: mongoose.Schema.ObjectId
    ref: 'aaarrr_user_state'
    required: true
    
  cfg:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  created_at    : Date
  updated_at    : Date


module.exports = mongoose.model "aaarrr_user_state_history", (aaarrr_user_state_history
).pre 'save', utils.update_timestamp

