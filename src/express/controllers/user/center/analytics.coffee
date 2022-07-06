service = require '../../../../service'
utils   = require '../../../../tools/utils'
adapter = require '../../../../adapters'
Promise = require 'bluebird'

# TODO: CREATE CRUD
@get = (req, res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@post = (req, res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@put = (req, res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@remove = (req, res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)