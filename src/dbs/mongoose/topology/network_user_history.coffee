mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

NetworkUserHistorySchema = mongoose.Schema

  key:
    type   : String
    default: ''
    required: true

  status:
    type    : String
    enum    : ['UNSUBSCRIBED', 'SUBSCRIBED','DENIED','WRONG_URL','BANNED']
    default : "SUB"
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

  created_at    : Date
  updated_at    : Date


module.exports =  mongoose.model "network_user_history", (NetworkUserHistorySchema
).pre 'save', utils.update_timestamp
