mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'
subq          = require 'mongoose-subquery'
system_validation = mongoose.Schema

  user:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: false

  status:
    type    : String
    enum    : ['INACTIVE','ACTIVE','DISCONNECTED', 'ERROR','TIMEOUT']
    default : "ACTIVE"
    required: true

  validation_type:
    type    : String
    enum    : ['PHONE','EMAIL']
    default : "PHONE"
    required: true
  validation_type:
    type    : String
    enum    : ['PHONE','EMAIL']
    default : "PHONE"
    required: true
    
  clazz:
    type    : String
    default : "login"
    required: true

  connection_retry:
    type   : Number
    default: 0

  number_code:
    type   : Number
    default: 0
  cfg:
    type   : mongoose.Schema.Types.Mixed
    default: {}
  enabled:
    type   : Boolean
    default: true

  created_at: Date
  updated_at: Date


# system_validation.plugin(subq)
module.exports = mongoose.model "system_validation", (system_validation
).pre 'save', utils.update_timestamp


