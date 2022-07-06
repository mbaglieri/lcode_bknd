Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../config/config'
mongo   = require '../../../../dbs/mongoose'
service = require '../../../../service'
utils   = require '../../../../tools/utils'
data_adapter = require '../../../../adapters'


@get_all = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.token.find
      user: req.user
  .then (tokens) ->
    res.json data_adapter.api.user.get_devices(tokens)
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@remove = (req,res) ->
  d_json = {
    status: 404
  }
  id  = req.body.id or req.query.id
  Promise.try ->
    mongo.token.deleteOneAsync
      user: req.user
      _id   : id
  .then (dev) ->
    
    res.json dev
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)