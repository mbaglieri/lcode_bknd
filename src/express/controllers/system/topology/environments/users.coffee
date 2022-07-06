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
    parms    = req.query
    parms.id = req.params.id
    service.topology.environment.users.get(parms, req.user)
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
    parms    = req.body
    parms.id = req.params.id
    service.topology.environment.users.add(parms, req.user, true)
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
    parms    = req.body
    parms.id = req.params.id
    service.topology.environment.users.remove(parms, req.user, true)
  .then (r) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
    
@bulk = (req,res) ->
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