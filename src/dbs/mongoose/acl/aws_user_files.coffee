mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

aws_user_files = mongoose.Schema

  user:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: true
    
  status:
    type      : Number
    required : false
    default: 0

  tag:
    type: String

  filename:
    type: String

  originalname:
    type     : String
    required: true

  size:
    type     : Number
    required: true

  mimetype:
    type     : String
    required: true
  encoding:
    type     : String
    required: true
  fieldname:
    type     : String
    required: true
  location:
    type     : String
    required: true
  created_at    : Date
  updated_at    : Date


aws_user_files.index({filename: 1}, {unique: true})
module.exports = mongoose.model "aws_user_files", (aws_user_files
).pre 'save', utils.update_timestamp
