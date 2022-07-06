mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

requestmap = mongoose.Schema


  path:
    type     : String
    required : true

  methd:
    type     : String
    enum     : ['GET','POST','PUT','DELETE','*']
    default  : '*'
    required : true
    
  description:
    type     : String
    required : true
 
  created_at    : Date
  updated_at    : Date


module.exports = mongoose.model "requestmap", (requestmap
).pre 'save', utils.update_timestamp
