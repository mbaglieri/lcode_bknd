mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'
#ex fcm_queue
module.exports = mongoose.model "firebase_msg", (mongoose.Schema

  worker:
    type: mongoose.Schema.ObjectId
    ref: 'server_ownership'
    default:null

  qtask_user:
    type: mongoose.Schema.ObjectId
    ref: 'qtask_user'
    default:null

  status:
    type   : String
    default: "PENDING"

  registration_ids:
    type: [
      type: String
      default:""
    ]
    default: []

  priority:
    type   : String
    default: "high"

  device_type:
    type   : String
    default: "ANDROID"
  collapse_key:
    type   : String
    default: "chat/message"

  data:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  notification:
    type   : mongoose.Schema.Types.Mixed
    default: {}
  created_at: Date
  updated_at: Date
).pre( 'save', utils.update_timestamp)