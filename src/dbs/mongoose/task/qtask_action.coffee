mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

###
QTaskAction contian the actions available for execute a process (Qtask)
###
qtask_action  = mongoose.Schema
  config_json:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  #ACTIVE|INACTIVE
  ac_type:
    type    : String
    default : "GENERIC"
    required: true


  #number of process executed
  hits:
    type   : Number
    default: 0

  is_disabled:
    type   : Boolean
    default: false
    
  created_at: Date
  updated_at: Date

qtask_action.index({ac_type: 1}, {unique: true})

module.exports = mongoose.model "qtask_action", (qtask_action
).pre('save', utils.update_with_hit)