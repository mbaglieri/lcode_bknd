mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'
module.exports = mongoose.model "oauth2_client", (mongoose.Schema
  name:
    type    : String
    unique  : true
    required: true
  id:
    type    : String
    required: true
  secret:
    type    : String
    required: true

  user:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: true

  created_at: Date
  updated_at: Date
).pre 'save', utils.update_timestamp
