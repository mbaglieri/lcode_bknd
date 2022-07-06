mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'
{env}          = require '../../../config/env'
 
user_guest = mongoose.Schema
 
  respawn_hai:
    type   : Date
    default: false
    
  lang:
    type        : String
    required    : true
    default: 'en'

  network:
    type        : String
    required    : true
    default: env.network

  username:
    type        : String
    required    : true
    default: '0.0.0.0'


  status:
    type    : String
    enum    : ['WITHOUT_DATA','PROCECING', 'RETRY1', 'RETRY2', 'RETRY3', 'REJECTED']
    default : "WITHOUT_DATA"
    required: true

  json_data:
    type   : mongoose.Schema.Types.Mixed
    default: {}

module.exports = mongoose.model "user_guest", (user_guest
).pre 'save', utils.update_timestamp
