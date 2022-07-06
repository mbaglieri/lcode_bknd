mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'


NetworkUserSchema = mongoose.Schema

  key:
    type   : String
    default: ''
    required: true

  user:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: true

  network:
    type: mongoose.Schema.ObjectId
    ref: 'network'
    required: true
  cfg:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  status:
    type    : String
    enum    : ['SUBSCRIBED', 'UNSUBSCRIBED']
    default : "SUBSCRIBED"
    required: true

  created_at    : Date
  updated_at    : Date

NetworkUserSchema.index({key: 1, user: 1}, {unique: true})


module.exports = mongoose.model "network_user", (NetworkUserSchema
).pre 'save', utils.update_timestamp
