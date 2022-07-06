mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'
city = mongoose.Schema
  properties:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  country:
    type: mongoose.Schema.ObjectId
    ref: 'countries'
    required:true
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

city.index({name: 1}, {unique: true})
city.index({ 'polygon_delimiter': '2dsphere' })

module.exports = mongoose.model "city", (city
).pre('save', utils.update_timestamp
)