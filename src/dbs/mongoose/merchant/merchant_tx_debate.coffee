mongoose      = require 'mongoose'
utils         = require '../../../tools/utils'

merchant_tx_debate = mongoose.Schema
 
      
  tx:
    type: mongoose.Schema.ObjectId
    ref: 'merchant_tx'
    required: true

  status:
    type    : String
    enum    : ['PENDING','INIT',  'PROCESSED', 'CANCELED', 'REPAID', 'REJECTED']
    default : "PENDING"
    required: true

  json_data:
    type   : mongoose.Schema.Types.Mixed
    default: {}
 

  created_at    : Date
  updated_at    : Date


module.exports = mongoose.model "merchant_tx_debate", (merchant_tx_debate
).pre 'save', utils.update_timestamp
