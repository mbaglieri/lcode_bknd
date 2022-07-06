mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

user_subscription_tx = mongoose.Schema
 
      
  subscription:
    type: mongoose.Schema.ObjectId
    ref: 'subscription'
    required: true

  user_subscription:
    type    : mongoose.Schema.ObjectId
    ref     : 'user_subscription'
    default : null
    required: false

  card:
    type    : mongoose.Schema.ObjectId
    ref     : 'user_payment_method'
    default : null
    required: false
    
  user:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: false

  seller:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: false
    
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
      
  price:
    type    : Number
    default : 0
    required: true

  json_data:
    type   : mongoose.Schema.Types.Mixed
    default: {}
 
  created_at    : Date
  updated_at    : Date


module.exports = mongoose.model "user_subscription_tx", (user_subscription_tx
).pre 'save', utils.update_timestamp
