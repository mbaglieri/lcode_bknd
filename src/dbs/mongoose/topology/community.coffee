mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

CommunitySchema = mongoose.Schema

  network:
    type: mongoose.Schema.ObjectId
    ref: 'network'
    required: true
    
  key:
    type   : String
    default: ''
    required: true

  location:
    type :  [Number]
    index: '2dsphere'
    default: [0,0]
    required: true

  polygon_delimiter:
    type: { type: String }
    coordinates: Array
    
  radius:
    type   :  Number
    default: null

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

CommunitySchema.index({key: 1}, {unique: true})

CommunitySchema.index({ 'polygon_delimiter': '2dsphere' })

module.exports = mongoose.model "community", (CommunitySchema
).pre 'save', utils.update_timestamp
