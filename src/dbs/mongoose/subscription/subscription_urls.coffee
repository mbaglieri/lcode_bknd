mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

AnalyticsSchema = mongoose.Schema
  key:
    type   : String
    default: ''
    required: true

  subscription:
    type: mongoose.Schema.ObjectId
    ref: 'subscription'
    required: true

  urls:
    type    : [String]
    default : []
    required: true

  status:
    type    : String
    enum    : ['INACTIVE', 'ACTIVE']
    default : "ACTIVE"
    required: true

  created_at    : Date
  updated_at    : Date

AnalyticsSchema.index({key: 1}, {unique: true})

module.exports = mongoose.model "subs_analytics", (AnalyticsSchema
).pre 'save', utils.update_timestamp
