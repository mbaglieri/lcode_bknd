mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

notification_center  = mongoose.Schema
 
  user:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: false

  qtask_user:
    type: mongoose.Schema.ObjectId
    ref: 'qtask_user'
    default:null

  status:
    type   : String
    default: "PENDING"
  #PENDING<APROVED<ARCHIVED
  
  is_readed:
    type   : Boolean
    default: false

  network:
    type: mongoose.Schema.ObjectId
    ref: 'network'
    default:null

  json_data:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  json_status:
    type   : mongoose.Schema.Types.Mixed
    default: {}
    
  created_at: Date
  updated_at: Date

# notification_center.index({ac_type: 1}, {unique: true})

module.exports = mongoose.model "notification_center", (notification_center
).pre('save', utils.update_timestamp)