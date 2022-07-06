mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

###
QTaskHistory save all the history of qtasks, providing data to be analized in the time
###
qtask_history = mongoose.Schema
  config_json:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  worker:
    type    : mongoose.Schema.ObjectId
    ref     : 'server_ownership'
    required: true


  action:
    type   : mongoose.Schema.ObjectId
    ref    : 'qtask_action'
    required: true

  #ACTIVE|INACTIVE
  status:
    type    : String
    enum    : ['COMPLETED','ERROR', 'ACTIVE', 'IN_PROGRESS']
    default : "IN_PROGRESS"
    required: true

  #number of process executed
  hits:
    type   : Number
    default: 0
  log:
    type   : mongoose.Schema.Types.Mixed
    default: {}


  created_at: Date
  updated_at: Date


module.exports = mongoose.model "qtask_history", (qtask_history
).pre('save', utils.update_with_hit)