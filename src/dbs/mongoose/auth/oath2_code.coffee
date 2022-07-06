mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'
module.exports = mongoose.model "oath2_code", (mongoose.Schema
  value:
    type    : String
    required: true
  redirectUri:
    type    : String
    required: true

  client:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: true

  user:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: true

  created_at: Date
  updated_at: Date
).pre 'save', utils.update_timestamp