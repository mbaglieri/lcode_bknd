mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'


EnvironmentUserSchema = mongoose.Schema

  environment:
    type: mongoose.Schema.ObjectId
    ref: 'environment'
    required:true

  community:
    type: mongoose.Schema.ObjectId
    ref: 'community'
    required:true

  status:
    type    : String
    enum    : ['UNSUB', 'SUB','DENIED','WRONG_URL','BANNED']
    default : "SUB"
    required: true
  key:
    type   : String
    default: ''
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

EnvironmentUserSchema.index({community:1, key: 1, user: 1}, {unique: true})


module.exports = mongoose.model "environment_user", (EnvironmentUserSchema
).pre 'save', utils.update_timestamp
