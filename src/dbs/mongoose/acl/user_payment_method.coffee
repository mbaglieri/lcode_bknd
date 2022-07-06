mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

user_payment_method = mongoose.Schema
 
  user:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: true

  status:
    type    : String
    enum    : ['PENDING','ACTIVE', 'DEACTIVATED', 'REMOVED', 'OVERQUOTA', 'LIMITED']
    default : "PENDING"
    required: true

  card:
    type   : Number
    required: true
      
  is_primary:
    type   : Boolean
    default: false
      
  retry:
    type    : Number
    default : 0
    required: true

  json_data:
    type   : mongoose.Schema.Types.Mixed
    default: {}


module.exports = mongoose.model "user_payment_method", (user_payment_method
).pre 'save', utils.update_timestamp
