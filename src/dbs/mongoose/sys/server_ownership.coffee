mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'
server_ownership = mongoose.Schema
  config_json:
    type   : mongoose.Schema.Types.Mixed
    default: {}

  #id server creted (multi server)
  id_server:
    type   : String
    default: 0
    unique : true 
    required : true 
    dropDups: true 
 
  #ACTIVE|INACTIVE
  status:
    type    : String
    enum    : ['INACTIVE', 'ACTIVE']
    default : "INACTIVE"
    required: true

  #number of process executed
  hits:
    type   : Number
    default: 0

  users:
    type   : Number
    default: 0

  created_at: Date
  updated_at: Date

server_ownership.index({id_server: 1}, {unique: true})

module.exports = mongoose.model "server_ownership", (server_ownership
).pre('save', utils.update_with_hit)