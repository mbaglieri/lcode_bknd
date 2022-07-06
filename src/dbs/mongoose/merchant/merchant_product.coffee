mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

merchant_product = mongoose.Schema

  merchant:
    type: mongoose.Schema.ObjectId
    ref: 'merchant'
    required: true

  provider:
    type: mongoose.Schema.ObjectId
    ref: 'merchant_provider'
    required: true

  name:
    type    : String
    required: true

  status:
    type    : String
    enum    : ['ACTIVE','INACTIVE', 'REJECTED']
    default : "ACTIVE"
    required: true

    
  offers: [{
    type: mongoose.Schema.ObjectId,
    ref: 'offer' }]
  cupons: [{
    type: mongoose.Schema.ObjectId,
    ref: 'cupon' }]
 
  json_params:
    type   : mongoose.Schema.Types.Mixed
    default: {}
  json_data_product:
    type   : mongoose.Schema.Types.Mixed
    default: {}
  json_data_price:
    type   : mongoose.Schema.Types.Mixed
    default: {}
 
  created_at    : Date
  updated_at    : Date


module.exports = mongoose.model "merchant_product", (merchant_product
).pre 'save', utils.update_timestamp
