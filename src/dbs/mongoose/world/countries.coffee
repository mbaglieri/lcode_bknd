mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'
countries = mongoose.Schema
  properties:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  #ACTIVE|INACTIVE
  status:
    type    : String
    enum    : ['INACTIVE', 'ACTIVE']
    default : "ACTIVE"
    required: true

  polygon_delimiter:
    type: { type: String }
    coordinates: Array

  name:
    type    : String
    default : ""
    required: true

  type:
    type    : String
    default : ""
    required: true


  created_at: Date
  updated_at: Date

countries.index({name: 1}, {unique: true})
countries.index({ 'polygon_delimiter': '2dsphere' })

module.exports = mongoose.model "countries", (countries
).pre('save', utils.update_timestamp
)