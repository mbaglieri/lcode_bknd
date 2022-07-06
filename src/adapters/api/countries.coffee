config   = require '../../config/config'
mongo    = require '../../dbs/mongoose'
{env}    = require '../../config/env'
Promise  = require 'bluebird'

@to_user = to_user = (val) ->
  countries = {}

  countries.id   = val._id
  countries.name = val.name
  countries.cfg  =  val.properties
 
  countries.status = val.status
  return countries
    