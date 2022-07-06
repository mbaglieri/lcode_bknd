mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'
refresh_token = mongoose.Schema
  value:
    type    : String
    required: true


  user:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: true

  network:
    type    : String
    required: true
  community:
    type    : String
    required: true
  environment:
    type    : String
    required: true

  created_at: Date
  updated_at: Date

refresh_token.index({user: 1, network: 1}, {unique: true})
module.exports =   mongoose.model "refresh_token", (refresh_token
).pre 'save', utils.update_timestamp