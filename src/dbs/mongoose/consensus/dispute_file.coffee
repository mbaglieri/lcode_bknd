mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

dispute_file = mongoose.Schema

  user:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: true
  log:
    type: mongoose.Schema.ObjectId
    ref: 'dispute_log'
    required: true
    
  name:
    type: String
    
  status:
    type    : String
    enum    : ['ACTIVE', 'DEACTIVATED', 'REMOVED','UPLOADING']
    default : "ACTIVE"

  location:
    type     : String
    required: true
  size:
    type     : Number
    required: true
  type_content:
    type   :  Number
    default: 1

  bytes:
    type: String

  duration:
    type     : Number
    required: false
  json_data:
    type   : mongoose.Schema.Types.Mixed
    default: {}
  created_at    : Date
  updated_at    : Date


module.exports = mongoose.model "dispute_file", (dispute_file
).pre 'save', utils.update_timestamp
