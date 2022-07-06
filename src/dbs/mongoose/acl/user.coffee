mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'
{env}         = require '../../../config/env'
bcrypt        = require 'bcrypt'
user = mongoose.Schema

  username:
    type: String

  password:
    type    : String
    required: true

  account_expired:
    type        : Boolean
    required   : true
    default    : false

  account_locked:
    type        : Boolean
    required   : true
    default    : false

  email:
    type     : String
    required : true

  first_name:
    type     : String
    required: false

  last_name:
    type     : String
    required: false

  password_expired:
    type        : Boolean
    required   : true
    default    : false

  phone:
    type: String
    required   : false

  phone1:
    type        : String
    required   : false
    default    : ''

  status:
    type     : String
    enum: ['INACTIVE','ACTIVE', 'DISABLED', 'REMOVED', 'BLOCKED']
    default    : 'INACTIVE'

  validation:
    type     : String
    enum    : ['NOT_VALIDATED','PHONE', 'EMAIL', 'PHONE_EMAIL']
    default : 'NOT_VALIDATED'
    
  description:
    type        : String
    required   : false
    default    : ''

  avatar:
    type        : String
    required   : false
    default    : env.spaces.img_avatars

  background_img:
    type        : String
    required   : false
    default    : env.spaces.img_profile_back

  job:
    type        : String
    required   : false
    default    : ''

  education:
    type        : String
    required   : false
    default    : ''

  relationship:
    type        : String
    required   : false
    default    : ''

  lang:
    type        : String
    required   : true
    default    : 'en'

  is_profile_editable:
    type        : Boolean
    required   : true
    default    : true

  birthday:
    type: Date
    required: false

  facebook:
    type: String
    required: false

  instagram:
    type: String
    required: false

  twitter:
    type: String
    required: false

  linkedin:
    type: String
    required: false
  created_at    : Date
  updated_at    : Date

user.index({username: 1}, {unique: true})
user.index({email   : 1}, {unique: true})
user.index({phone   : 1}, {unique: true})

module.exports = mongoose.model "user", (user
).pre 'save', utils.update_timestamp_user

