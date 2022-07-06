mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

merchant_client = mongoose.Schema

  merchant:
    type: mongoose.Schema.ObjectId
    ref: 'merchant'
    required: true

  client:
    type: mongoose.Schema.ObjectId
    ref: 'user'
    required: true
  #
  status:
    type    : String
    enum    : ['PENDING','AWARENESS', 'ADQUISITION', 'ACTIVATION', 'REVENUE', 'RETENTION', 'REFERRAL']
    default : "PENDING"
    required: true

  networks: [{
    type: mongoose.Schema.ObjectId,
    ref: 'network' }]

  communities: [{
    type: mongoose.Schema.ObjectId,
    ref: 'community' }]

  environment: [{
    type: mongoose.Schema.ObjectId,
    ref: 'environment' }]

  json_data:
    type   : mongoose.Schema.Types.Mixed
    default: {}
 
  created_at    : Date
  updated_at    : Date


module.exports = mongoose.model "merchant_client", (merchant_client
).pre 'save', utils.update_timestamp
