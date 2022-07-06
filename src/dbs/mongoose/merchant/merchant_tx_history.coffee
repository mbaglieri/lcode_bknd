mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

merchant_tx_history = mongoose.Schema
      
  merchant:
    type: mongoose.Schema.ObjectId
    ref: 'merchant'
    required: true

  provider:
    type: mongoose.Schema.ObjectId
    ref: 'merchant_provider'
    required: true

  product:
    type: mongoose.Schema.ObjectId
    ref: 'merchant_product'
    required: true

  client:
    type: mongoose.Schema.ObjectId
    ref: 'merchant_client'
    required: true

  pm:
    type: mongoose.Schema.ObjectId
    ref: 'merchant_client_payment_method'
    required: true

  offer:
    type: mongoose.Schema.ObjectId
    ref: 'offer'
    required: false
    
  cupon:
    type: mongoose.Schema.ObjectId
    ref: 'cupon'
    required: false
 

  status:
    type    : String
    enum    : ['PENDING','ACTIVE',  'REMOVED', 'PAID', 'CANCELED', 'REJECTED']
    default : "PENDING"
    required: true

  currency:
    type   : String
    default: 'USD'
    required: true
      
  use_conversion:
    type   : Boolean
    default: false
      
  retry:
    type   : Number
    default: true
    default : 0
  price:
    type    : Number
    default : 0
    required: true

  json_data:
    type   : mongoose.Schema.Types.Mixed
    default: {}
 

  created_at    : Date
  updated_at    : Date


module.exports = mongoose.model "merchant_tx_history", (merchant_tx_history
).pre 'save', utils.update_timestamp
