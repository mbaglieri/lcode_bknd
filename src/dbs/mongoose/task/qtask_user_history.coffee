mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

###
QTaskUser is the asignation for the worker, giving to each user an space to execute tasks 
in the workers available
###
module.exports =  mongoose.model "qtask_user_history", (mongoose.Schema


  user:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: true
 
  status:
    type    : String
    enum    : ['INACTIVE', 'CONNECTED','ACTIVE', 'INTRO','IN_WORKOUT', 'DISCONNECTED', 'PING','PING_1', 'PING_2', 'PING_3']
    default : "INACTIVE"
    required: true

  connection_retry:
    type   : Number
    default: 0

  #state of this robot
  enabled:
    type   : Boolean
    default: true
    
  #server where this ia work
  worker:
    type: mongoose.Schema.ObjectId
    ref: 'server_ownership'
    default:null
    
  environment:
    type: mongoose.Schema.ObjectId
    ref : 'environment'
    default: null

  config_json:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  created_at: Date
  updated_at: Date
  pong_date : Date
).pre( 'save', utils.update_timestamp)