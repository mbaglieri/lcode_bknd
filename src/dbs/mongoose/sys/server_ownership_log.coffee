mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'
server_ownership_log = mongoose.Schema
  config_json:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  #id server creted (multi server)
  id_server:
    type   : String
    default: 0

  #ACTIVE|INACTIVE
  status:
    type    : String
    enum    : ['CONNECTED', 'DISCONNECTED','MOVED_QUEUE', 'ADQUIRED_QUEUE', 'SYSTEM_SHUTDOWN']
    default : "CONNECTED"
    required: true

  #number of process executed
  hits:
    type   : Number
    default: 0


  created_at: Date
  updated_at: Date


module.exports = mongoose.model "server_ownership_log", (server_ownership_log
).pre('save', utils.update_with_hit)