mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

CommunityUserHistorySchema = mongoose.Schema

  key:
    type   : String
    default: ''
    required: true

  status:
    type    : String
    enum    : ['UNSUBSCRIBED', 'SUBSCRIBED','DENIED','WRONG_URL','BANNED']
    default : "SUB"
    required: true

  community:
    type: mongoose.Schema.ObjectId
    ref: 'community'
    required: true

  user:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: true

  cfg:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  created_at    : Date
  updated_at    : Date


module.exports = mongoose.model "community_user_history", (CommunityUserHistorySchema
).pre 'save', utils.update_timestamp

