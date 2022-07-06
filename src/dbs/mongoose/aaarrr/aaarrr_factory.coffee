mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

aaarrr_factory = mongoose.Schema

  status:
    type   : String
    enum: ['INACTIVE', 'ACTIVE']
    default: "ACTIVE"

  #TODO change to initial_question
  msg_template:
    type: mongoose.Schema.ObjectId
    ref: 'aaarrr_msg'
    default:null

  name :
    type    : String
    required: true

  execution_rules:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  priority:
    type   : Number
    default: 60

  max_depth:
    type   : Number
    default: 3

  min_depth:
    type   : Number
    default: 1

  strategy:
    type   : String
    enum: ['SOCKET', 'PUSH', 'EMAIl','CONTEXT']
    default: "SOCKET"

  state:
    type    : String
    enum    : ['AWARENESS','ADQUISITION','ACTIVATION','RETENTION','REVENUE','REFERRAL']
    default : "AWARENESS"
    required: true
    
  ctx_clazz:
    type    : String
    enum    : ['SYSTEM','MERCHANT','COMMUNITY','ENVIRONMENT']
    default : "SYSTEM"
    required: true
  parent:
    type: mongoose.Schema.ObjectId
    ref : 'aaarrr_factory'
    default: null


  created_at: Date
  updated_at: Date

# aaarrr_factory.index({ 'coordinates': '2dsphere' })

module.exports = mongoose.model "aaarrr_factory", (aaarrr_factory
).pre 'save', utils.update_timestamp

