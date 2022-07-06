mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

community_user_schema = mongoose.Schema

  key:
    type   : String
    default: ''
    required: true

  user:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: true
    
  community:
    type: mongoose.Schema.ObjectId
    ref: 'community'
    required: true

  cfg:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  status:
    type    : String
    enum    : ['UNSUBSCRIBED', 'SUBSCRIBED','DENIED','WRONG_URL','BANNED']
    default : "SUBSCRIBED"
    required: true

  network:
    type: mongoose.Schema.ObjectId
    ref: 'network'
  created_at    : Date
  updated_at    : Date

community_user_schema.index({key: 1, user: 1}, {unique: true})

module.exports =  mongoose.model "community_user", (community_user_schema
).pre 'save', utils.update_timestamp
