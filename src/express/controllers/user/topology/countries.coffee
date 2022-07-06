Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../config/config'
{env}   = require '../../../../config/env'
mongo   = require '../../../../dbs/mongoose'
service = require '../../../../service'
utils   = require '../../../../tools/utils'

@get_all = (req, res) ->
  Promise.try ->
    service.topology.countries.get_all(req.query)
  .then (r) ->
    res.send JSON.stringify r

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
    