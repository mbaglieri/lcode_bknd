mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'
module.exports = mongoose.model "user_connect", (mongoose.Schema

  connection:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: true
  user:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: true
  #k: user
  status  : 
    type   :  Number
    default: 1

  created_at: Date
  updated_at: Date
).pre 'save', utils.update_timestamp