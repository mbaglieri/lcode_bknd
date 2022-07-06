mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

aaarrr_user_state = mongoose.Schema

  status:
    type    : String
    enum    : ['PENDING', 'ACTIVE','DEACTIVATED','REMOVED']
    default : "PENDING"
    required: true

  aaarrr:
    type: mongoose.Schema.ObjectId
    ref: 'aaarrr'
    required: true

  cfg:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  created_at    : Date
  updated_at    : Date


module.exports = mongoose.model "aaarrr_user_state", (aaarrr_user_state
).pre 'save', utils.update_timestamp

