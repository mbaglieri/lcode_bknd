mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

user_role = mongoose.Schema


  user:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: true
  role:
    type: mongoose.Schema.ObjectId
    ref: 'role'
    required: true
 
  created_at    : Date
  updated_at    : Date


user_role.index({user: 1,role:1}, {unique: true})
module.exports = mongoose.model "user_role", (user_role
).pre 'save', utils.update_timestamp
