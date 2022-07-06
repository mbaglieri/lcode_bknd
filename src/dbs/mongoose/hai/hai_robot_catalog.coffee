mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

hai_robot_catalog = mongoose.Schema
  config_json:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  style:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  status:
    type   : String
    enum: ['INACTIVE', 'ACTIVE']
    default: "ACTIVE"

  name :
    type    : String
    required: true

  price:
    type   : Number
    default: 0

  environment:
    type: mongoose.Schema.ObjectId
    ref : 'environment'
    default: null

  created_at: Date
  updated_at: Date

hai_robot_catalog.index({name: 1, environment: 1}, {unique: true})


module.exports = mongoose.model "hai_robot_catalog", (hai_robot_catalog
).pre 'save', utils.update_timestamp
