Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../../config/config'
mongo   = require '../../../../../dbs/mongoose'
service = require '../../../../../service'
utils   = require '../../../../../tools/utils'
data_adapter = require '../../../../../adapters'
@aaarrr      = require './aaarrr'
@analytics   = require './analytics'
@ebitda      = require './ebitda'
@integrations= require './integrations'
@merchant    = require './merchant'
@payments    = require './payments'
@promotions  = require './promotions'
@qtasks      = require './qtasks'
@subs        = require './subscriptions'
@users       = require './users'

# TODO: CREATE ALGORITHMS

@get_environments = (req, res) ->
  Promise.try ->
    service.topology.environment.get_environments(req.query, req.user)
  .then (r) ->
    res.send JSON.stringify r

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json) 
 
@get_environments_by_id = (req, res) ->
  d_json = {
    status: 200
  }
  Promise.try ->
    service.topology.environment.get_environments_by_id(req.query, req.user)
  .then (env_) ->
    res.send JSON.stringify env_

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json) 


@post_environments = (req,res) ->
  d_json = {
    status: 200
  }
  Promise.try ->
    service.topology.environment.post_environments req.body, req.user
  .then (env) ->
    res.send JSON.stringify env
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json) 

 
@by_network = (req, res) -> 
  Promise.try ->
    service.topology.environment.by_network(req.query, req.user, true)
  .then (r) ->
    res.send JSON.stringify r 

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

    
# Create endpoint /api/networks for GET
@get = (req, res) ->
  perPage = 10
  page    = req.query.page || 0

  where = {}
  Promise.try ->
    if req.query.key
      where.key = { '$regex' : req.query.key, '$options' : 'i' }
    if req.params.id
      where._id =req.params.id


    mongo.environment.findOne where
    .populate('default_ai')
    .exec()
  .then (environment) ->
    if not environment
      throw new Error("NO_NETOWKR_FOUND")
    returnset = {
      data  : data_adapter.api.environment.to_user_admin environment || {}
      status: 200
    }
    res.send JSON.stringify returnset
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

# Create endpoint /api/environment/:id for PUT
@modify = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    parms    = req.body
    parms.id = req.params.id
    service.topology.environment.modify(parms, req.user, true)
  .then (r) ->
    res.send JSON.stringify r
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
  

# Create endpoint /api/environment/:id for DELETE
@delete = (req,res) ->
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
    