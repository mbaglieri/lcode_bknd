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
 
@pub_sub = (req,res) ->
  Promise.try ->
    parms    = req.body
    parms.id = req.params.id
    service.topology.environment.pub_sub(parms, req.user)
  .then (environment_user_h) ->

    returnset = {
      data  : environment_user_h || {}
      status: 200
    }
    res.send JSON.stringify returnset

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json) 

# Create endpoint /api/environment/:id for PUT
@invite = (req,res) ->
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
@block = (req,res) ->
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
    