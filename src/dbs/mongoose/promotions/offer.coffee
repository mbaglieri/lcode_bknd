mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

offer = mongoose.Schema

  merchant:
    type: mongoose.Schema.ObjectId
    ref: 'merchant'
    required: false

  creator:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: false

  name:
    type    : String
    required: true

  amount:
    type    : Number
    default : 0
    required: true

  currency:
    type    : String
    default : "USD"
    required: true

  type_operation:
    type    : String
    enum    : ['PORCENTAGE','AMOUNT']
    default : "PORCENTAGE"
    required: true
  #
  status:
    type    : String
    enum    : ['AVAILABLE','PENDING', 'INACTIVE', 'DISABLED','DELETED']
    default : "AVAILABLE"
    required: true
  limit:
    type    : Number
    default : 10
    required: true
    
  type:
    type    : String
    enum    : ['SYSTEM','MERCHANT','COMMUNITY','ENVIRONMENT']
    default : "SYSTEM"
    required: true

  start_date:
    type    : Date

  end_date:
    type    : Date

  clazz:
    type    : String
    enum    : ['SUBSCRIPTION','PRODUCTS', 'AUCTION']
    default : "SUBSCRIPTION"
    required: true
    
  json_data:
    type   : mongoose.Schema.Types.Mixed
    default: {}
 
  created_at    : Date
  updated_at    : Date

    

module.exports = mongoose.model "offer", (offer
).pre 'save', utils.update_timestamp
