mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

user_address = mongoose.Schema


  user:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: true

  name: 
    type: String
    required   : true
    defaultValue: ''

  address: 
    type: String
    required   : true
    defaultValue: ''

  reference: 
    type: String
    required   : false
    defaultValue: ''

  notes: 
    type: String
    required   : false
    defaultValue: ''

  geometry:
    type :  [Number]
    index: '2dsphere'
    default: [0,0]
    
  status:
    type: String
    required   : false
    enum    : ['AVAILABLE', 'DISABLED']
    default : "AVAILABLE"
    
  json_params:
    type   : mongoose.Schema.Types.Mixed
    default: {}
    
  created_at    : Date
  updated_at    : Date



module.exports =  mongoose.model "user_address", (user_address
).pre 'save', utils.update_timestamp
