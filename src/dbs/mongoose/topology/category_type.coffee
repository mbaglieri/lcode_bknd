mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

CategoryTypeSchema = mongoose.Schema
  key:
    type   : String
    default: ''
    required: true

  cfg:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  status:
    type    : String
    enum    : ['INACTIVE', 'ACTIVE']
    default : "ACTIVE"
    required: true

  created_at    : Date
  updated_at    : Date

CategoryTypeSchema.index({key: 1}, {unique: true})

module.exports = mongoose.model "category_type", (CategoryTypeSchema
).pre 'save', utils.update_timestamp
