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
  

# Create endpoint /api/environment/:id for DELETE
@remove = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.environment.findOne 
      _id    : req.params.id
    .exec()
  .then (q_u) ->
    if not q_u
      throw new Error("NOT_FOUND")

    q_u.enabled   = false
    q_u.saveAsync()
  .then (network) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
    