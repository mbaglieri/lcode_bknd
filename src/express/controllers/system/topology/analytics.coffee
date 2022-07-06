Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../config/config'
mongo   = require '../../../../dbs/mongoose'
service = require '../../../../service'
utils   = require '../../../../tools/utils'
data_adapter = require '../../../../adapters'

# TODO: CREATE ALGORITHMS