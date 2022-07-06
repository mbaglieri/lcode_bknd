mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'
server_ownership_analytics = mongoose.Schema
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
    enum    : ['HISTORY', 'ACTIVE']
    default : "ACTIVE"
    required: true

  #number of process executed
  hits:
    type   : Number
    default: 0


  created_at: Date
  updated_at: Date

module.exports = mongoose.model "server_ownership_analytics", (server_ownership_analytics
).pre('save', utils.update_with_hit)