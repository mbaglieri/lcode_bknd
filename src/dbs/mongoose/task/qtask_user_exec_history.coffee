mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

###
QTaskUserExecHistory save each process execution history to analize after the execution
###
qtask_user_exec_history     = mongoose.Schema


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
    enum    : ['COMPLETED','ERROR', 'ACTIVE', 'IN_PROGRESS']
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


module.exports = mongoose.model "qtask_user_exec_history", (qtask_user_exec_history
).pre('save', utils.update_timestamp)