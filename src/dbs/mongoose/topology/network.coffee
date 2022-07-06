mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

NetworkSchema = mongoose.Schema

  key:
    type   : String
    default: ''
    required: true

  location:
    type :  [Number]
    index: '2dsphere'
    default: [0,0]

  radius:
    type   :  Number
    default: null

  cfg:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  status:
    type    : String
    enum    : ['INACTIVE', 'VERIFYING','ACTIVE']
    default : "VERIFYING"
    required: true

  polygon_delimiter:
    type: { type: String }
    coordinates: Array

  categories: [{
    type: mongoose.Schema.ObjectId,
    ref: 'category_type' }]

  creator:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: true
    
  counter:
    type   : Number
    default: 0
  created_at    : Date
  updated_at    : Date

NetworkSchema.index({key: 1}, {unique: true})
NetworkSchema.index({ 'polygon_delimiter': '2dsphere' })


module.exports =  mongoose.model "network", (NetworkSchema
).pre 'save', utils.update_timestamp
