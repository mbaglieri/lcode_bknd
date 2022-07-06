Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../config/config'
mongo   = require '../../../../dbs/mongoose'
service = require '../../../../service'
utils   = require '../../../../tools/utils'
data_adapter = require '../../../../adapters'

# Create endpoint /api/qtask_user_exec_history for GET
@get_all = (req, res) ->
  perPage = 10
  page    = req.query.page || 0

  qury = 
    status : $in: ['INACTIVE', 'CONNECTED','ACTIVE', 'INTRO','IN_WORKOUT', 'DISCONNECTED']
  if req.query.action
    qury.action = { '$regex' : req.query.action, '$options' : 'i' }
  Promise.try ->

    mongo.qtask_user_exec_history.countDocuments qury
  .then (count_qt_u_exec) ->
    @count_qt_u_exec = count_qt_u_exec

    mongo.qtask_user_exec_history.find qury
    .populate('worker', {_id:0,id_server:1,status:1,hits:1})
    .populate('environment', {_id:0,key:1,name:1})
    .select(["-__v","-created_at"])
    .limit(perPage)
    .skip(perPage * page)
    .sort( created_at: 'asc')
    .exec()
  .then (qt_users_exec) ->
    r = 
      count: @count_qt_u_exec
      data : qt_users_exec
    res.send JSON.stringify r

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

# Create endpoint /api/qtask_user_exec_history/:id for GET
@get_one = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->

    mongo.qtask_user_exec_history.findOne
      _id    : req.params.id
      status : $in: ['INACTIVE', 'CONNECTED','ACTIVE', 'INTRO','IN_WORKOUT', 'DISCONNECTED']
    .populate('worker', {_id:0,id_server:1,status:1,hits:1})
    .populate('environment', {_id:0,key:1,name:1})
    .select(["-__v","-created_at"])
    .exec()
  .then (qtask_user_exec_history) ->
    res.send JSON.stringify qtask_user_exec_history

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@remove_from_server = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.server_ownership.findOne
      id_server: req.query.id_server
    .exec()
  .then (server) ->
    if not server
      throw new Error("NOT_FOUND")

    mongo.qtask_user_exec_history.deleteManyAsync
      worker: server 
  .then (pst) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
