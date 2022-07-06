mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

user_photo = mongoose.Schema

  user:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: true

  type_content:
    type   :  Number
    default: 1
    
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


user_photo.index({filename: 1}, {unique: true})
module.exports = mongoose.model "user_photo", (user_photo
).pre 'save', utils.update_timestamp
