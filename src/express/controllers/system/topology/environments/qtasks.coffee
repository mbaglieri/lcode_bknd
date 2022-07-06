Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../../config/config'
mongo   = require '../../../../../dbs/mongoose'
service = require '../../../../../service'
utils   = require '../../../../../tools/utils'
data_adapter = require '../../../../../adapters'

# TODO: CREATE ALGORITHMS

@get = (req, res) ->
  Promise.try ->
    service.topology.environment.get(req.query, req.user)
  .then (r) ->
    res.send JSON.stringify r

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json) 
 

# Create endpoint /api/environment/:id for PUT
@add = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    service.topology.environment.add(req.body, req.user, true)
  .then (r) ->
    res.send JSON.stringify r
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
  
