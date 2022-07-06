mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

currencies = mongoose.Schema

  #ACTIVE|INACTIVE
  status:
    type    : String
    enum    : ['INACTIVE', 'ACTIVE']
    default : "ACTIVE"
    required: true

  country:
    type: mongoose.Schema.ObjectId
    ref: 'countries'
    required:true

  currency:
    type    : String
    default : ""
    required: true
  code:
    type    : String
    default : ""
    required: true
  minor_unit:
    type    : String
    default : ""
    required: true
  symbol:
    type    : String
    default : "$"


  created_at: Date
  updated_at: Date

module.exports = mongoose.model "currencies", (currencies
).pre('save', utils.update_timestamp
)