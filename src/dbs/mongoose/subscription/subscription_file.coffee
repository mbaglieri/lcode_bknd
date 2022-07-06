mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

subscription_file = mongoose.Schema

  id_clazz:
    type: mongoose.Schema.ObjectId
    default:null

  clazz:
    type    : String
    enum    : ['SUBSCRIPTION','SUBSCRIPTION_SPELLS']
    default : "SUBSCRIPTION"
    required: true
    
  name:
    type   : String
    default: ''
    required: true
    
  #where we storage the file bucket
  location:
    type    : String
    enum    : ['LOCAL','CLOUD_AWS', 'CLOUD_DIGITALOCEAN']
    default : 'CLOUD_DIGITALOCEAN'
    required: true

  # 0  4MB
  size:
    type    : Number
    default : 0

  # 0  audio, 1 img, 2 doc
  type_content:
    type    : Number
    default : 0
  # bytes
  bytes:
    type   : String
    default: ''

  #PENDING:0 1:UPLOADED 2:STORAGED
  duration:
    type    : Number
    default : 0
    
  json_data:
    type   : mongoose.Schema.Types.Mixed
    default: {}
 

  created_at    : Date
  updated_at    : Date


module.exports = mongoose.model "subscription_file", (subscription_file
).pre 'save', utils.update_timestamp
