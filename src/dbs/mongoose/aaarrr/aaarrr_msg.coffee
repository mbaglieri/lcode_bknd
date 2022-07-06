mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

aaarrr_msg = mongoose.Schema
  style  :
    type   : mongoose.Schema.Types.Mixed
    default: {}

  name   :
    type    : String
    unique  : true

  subject   :
    type    : String
    unique  : true

  body   :
    type    : String
    unique  : true
    
  created_at: Date
  updated_at: Date


module.exports = mongoose.model "aaarrr_msg", (aaarrr_msg
).pre 'save', utils.update_timestamp
