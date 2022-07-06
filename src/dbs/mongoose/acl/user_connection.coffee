mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'
module.exports = mongoose.model "connection", (mongoose.Schema

  user:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: true
  #k: user
  kind  : String
  # t: CONNECTED t: DISCONNECTED
  type  : String

  created_at: Date
  updated_at: Date
).pre 'save', utils.update_timestamp