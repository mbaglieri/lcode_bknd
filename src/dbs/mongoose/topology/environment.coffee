mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

EnvironmentSchema = mongoose.Schema

  key:
    type   : String
    default: ''
    required: true

  name:
    type   : mongoose.Schema.Types.Mixed
    default: {}
    required: true

  location:
    type :  [Number]
    index: '2dsphere'
    default: [0,0]

  polygon_delimiter:
    type: { type: String }
    coordinates: Array
  # {'type':1,'monolyth':false,'store_chat':00,'store_type':'min'}
  #type      : 0 slack,1 whatsapp, 2 snapchat
  #monolyth  : only one chat if its true all the people share the same chat
  #store_chat: time to store (00 infinite)
  #store_type: type of storage min, hours, days
  algorithm:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  enabled:
    type   : Boolean
    default: true

  default_ai:
    type    : mongoose.Schema.ObjectId
    ref     : 'hai_robot_catalog'
    default : null

  community:
    type: mongoose.Schema.ObjectId
    ref: 'community'
    required:true

  created_at    : Date
  updated_at    : Date

EnvironmentSchema.index({key: 1,community: 1}, {unique: true})
EnvironmentSchema.index({ 'polygon_delimiter': '2dsphere' })


module.exports = mongoose.model "environment", (EnvironmentSchema
).pre 'save', utils.update_timestamp
