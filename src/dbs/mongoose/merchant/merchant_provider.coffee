mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

merchant_provider = mongoose.Schema

  merchant:
    type: mongoose.Schema.ObjectId
    ref: 'merchant'
    required: true

  #'ACTIVE' #INACTIVE; #REJECTED; #ACCEPTED; 
  status:
    type    : String
    enum    : ['ACTIVE','INACTIVE', 'REJECTED']
    default : "ACTIVE"
    required: true

  provider:
    type        : String
    required    : true
    enum        : ['STRIPE','MELI', 'PAYPAL']
    default     : 'STRIPE' 
    
  json_data:
    type   : mongoose.Schema.Types.Mixed
    default: {}
 
  created_at    : Date
  updated_at    : Date


module.exports = mongoose.model "merchant_provider", (merchant_provider
).pre 'save', utils.update_timestamp
