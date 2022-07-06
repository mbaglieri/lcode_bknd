Promise  = require 'bluebird'
async    = require 'async'

request       = Promise.promisifyAll require 'request'
fs            = Promise.promisifyAll require 'fs'
mongo         = require '../../dbs/mongoose'
config        = require '../../config/config'
{env}         = require '../../config/env'
log           = require('../../tools/log').create 'service.center.general'
jwt           = require 'jsonwebtoken'
randtoken     = require 'rand-token'
data_adapter  = require '../../adapters'
utils         = require '../../tools/utils'
###
###
@get_all = get_all = (parms, required_categories) ->
  perPage = 10
  page    = parms.page || 0

  where = {}
  Promise.try ->
    if parms.q
      where.name = { '$regex' : parms.q, '$options' : 'i' }

    if not parms.status
      where.status = 
        $in: ['ACTIVE','INACTIVE']
    else 
      where.status =
        $in: parms.status.split ","
    mongo.countries.countDocuments where
  .then (count_) ->
    @count_ = count_
    
    mongo.countries.find where
    .select(["-__v","-created_at"])
    .limit(perPage)
    .skip(perPage * page)
    .sort( created_at: 'asc')
    .exec()
  .then (qt_users_exec) ->
    l_env_data = []
    for category_type in qt_users_exec 
       l_env_data.push data_adapter.api.countries.to_user category_type
    r = 
      count: @count_
      data : l_env_data
    return r
