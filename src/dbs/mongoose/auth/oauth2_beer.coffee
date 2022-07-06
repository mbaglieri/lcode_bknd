mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'
module.exports = mongoose.model "Beer", (mongoose.Schema
  name: String
  type: String
  quantity: Number

  user:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: true

  created_at: Date
  updated_at: Date

).pre 'save', utils.update_timestamp
