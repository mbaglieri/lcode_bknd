mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

dispute = mongoose.Schema
 
  client:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: true
  
  seller:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: false
      
  tx:
    type: mongoose.Schema.ObjectId
    required: true

  open_by_buyer:
    type   : Boolean
    default: false

  win_buyer:
    type   : Boolean
    default: false
    
  clazz:
    type    : String
    enum    : ['SUBSCRIPTION','PRODUCTS', 'AUCTION']
    default : "SUBSCRIPTION"
    required: true

  status:
    type    : String
    enum    : ['ACTIVE', 'DEACTIVATED', 'REMOVED','CLOSE','INPROCESS','CANCELED']
    default : "ACTIVE"
    required: true

  json_data:
    type   : mongoose.Schema.Types.Mixed
    default: {}
 

  created_at    : Date
  updated_at    : Date


module.exports = mongoose.model "dispute", (dispute
).pre 'save', utils.update_timestamp
