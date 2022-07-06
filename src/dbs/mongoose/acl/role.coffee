mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

role = mongoose.Schema

  authority:
    type     : String
    enum     : ['GUEST','USER', 'ADMIN', 'SYS', 'DBA','BUSINESS_OWNER','BUSINESS_ADMINISTRATOR','BUSINESS_MONITOR']
    default  : 'GUEST'
    required : true
    
 
  created_at    : Date
  updated_at    : Date


module.exports = mongoose.model "role", (role
).pre 'save', utils.update_timestamp
