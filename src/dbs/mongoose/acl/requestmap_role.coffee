mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

requestmap_role = mongoose.Schema


  requestmap:
    type: mongoose.Schema.ObjectId
    ref: 'requestmap'
    required: true
  role:
    type: mongoose.Schema.ObjectId
    ref: 'role'
    required: true
 
  created_at    : Date
  updated_at    : Date


requestmap_role.index({requestmap: 1,role:1}, {unique: true})
module.exports = mongoose.model "requestmap_role", (requestmap_role
).pre 'save', utils.update_timestamp
