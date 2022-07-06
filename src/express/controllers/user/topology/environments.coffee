Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../config/config'
mongo   = require '../../../../dbs/mongoose'
data_adapter = require '../../../../adapters'
service = require '../../../../service'
utils   = require '../../../../tools/utils'

@get_environments = (req, res) ->
  Promise.try ->
    service.topology.environment.get_environments(req.query, req.user)
  .then (r) ->
    res.send JSON.stringify r

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json) 

@get_environments_v1 = (req, res) ->
  Promise.try ->
    service.topology.environment.get_environments_v1(req.query, req.user)
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

@get_environment_by_id_parsed = (req, res) ->
  d_json = {
    status: 200
  }
  Promise.try ->
    service.topology.environment.get_environment(req.query.id)
  .then (env_) ->
    if not env_
      throw new Error("NO_ENVIRONMENT_FOUND")
    @env_ = env_
    mongo.community.findOne
      _id     : env_.community._id
      creator : req.user
    .populate('network')
    .exec()
  .then (community) ->
    if not env_
      throw new Error("NO_ENVIRONMENT_FOUND")
    d_json = data_adapter.api.environment.to_user_id_parsed @env_, community.key
    d_json.status = 200
    res.send JSON.stringify d_json

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json) 

@pub_sub = (req,res) ->
  Promise.try ->
    service.topology.environment.pub_sub(req.body, req.user)
  .then (environment_user_h) ->

    returnset = {
      data  : environment_user_h || {}
      status: 200
    }
    res.send JSON.stringify returnset

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

