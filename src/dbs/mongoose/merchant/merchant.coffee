mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

merchant = mongoose.Schema


  user:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: true

  status:
    type    : String
    enum    : ['PENDING','ACTIVE', 'INACTIVE', 'DISABLED', 'BANNED', 'DELETED']
    default : "PENDING"
    required: true
    
  network:
    type: mongoose.Schema.ObjectId
    ref: 'network'
    required: true

  json_data:
    type   : mongoose.Schema.Types.Mixed
    default: {}
 
  created_at    : Date
  updated_at    : Date


module.exports = mongoose.model "merchant", (merchant
).pre 'save', utils.update_timestamp
