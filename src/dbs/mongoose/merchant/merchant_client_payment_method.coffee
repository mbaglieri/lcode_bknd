mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

merchant_client_payment_method = mongoose.Schema
 
  client:
    type: mongoose.Schema.ObjectId
    ref: 'merchant_client'
    required: true

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


module.exports = mongoose.model "merchant_client_payment_method", (merchant_client_payment_method
).pre 'save', utils.update_timestamp
