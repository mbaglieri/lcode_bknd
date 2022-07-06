mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

###
QTaskUserExec save each process execution. 
###
qtask_user_exec     = mongoose.Schema

  user:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: true
  worker:
    type    : mongoose.Schema.ObjectId
    ref     : 'server_ownership'
    required: true

  qtask:
    type    : mongoose.Schema.ObjectId
    ref     : 'qtask'
    required: true

  qtask_user:
    type    : mongoose.Schema.ObjectId
    ref     : 'qtask_user'
    required: true

  environment:
    type: mongoose.Schema.ObjectId
    ref : 'environment'
    default: null

  action:
    type   : mongoose.Schema.ObjectId
    ref    : 'qtask_action'
    required: true

  status:
    type    : String
    enum    : ['COMPLETED','ERROR', 'ACTIVE', 'IN_PROGRESS','REMOVED']
    default : "IN_PROGRESS"
    required: true

  log:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  config_json:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  created_at: Date
  updated_at: Date


module.exports = mongoose.model "qtask_user_exec", (qtask_user_exec
).pre('save', utils.update_timestamp)