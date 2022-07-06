mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

hai_robot = mongoose.Schema
  config_json:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  qtask_user:
    type    : mongoose.Schema.ObjectId
    ref     : 'qtask_user'
    required: true

  environment:
    type: mongoose.Schema.ObjectId
    ref : 'environment'
    default: null

  hai_robot_catalog:
    type: mongoose.Schema.ObjectId
    ref : 'hai_robot_catalog'
    required: true


  created_at: Date
  updated_at: Date

hai_robot.index({hai: 1, environment: 1}, {unique: true})

# hai_robot.index({ 'coordinates': '2dsphere' })

module.exports = mongoose.model "hai_robot", (hai_robot
).pre 'save', utils.update_timestamp