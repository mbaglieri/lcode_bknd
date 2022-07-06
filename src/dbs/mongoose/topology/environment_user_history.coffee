mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

EnvironmentUserHistorySchema = mongoose.Schema

  environment:
    type: mongoose.Schema.ObjectId
    ref: 'environment'
    required:true

  community:
    type: mongoose.Schema.ObjectId
    ref: 'community'
    required:true

  key:
    type   : String
    default: ''
    required: true

  user:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: true

  status:
    type    : String
    enum    : ['UNSUB', 'SUB','DENIED','WRONG_URL','BANNED']
    default : "SUB"
    required: true

  cfg:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  created_at    : Date
  updated_at    : Date


module.exports = mongoose.model "environment_user_history", (EnvironmentUserHistorySchema
).pre 'save', utils.update_timestamp

