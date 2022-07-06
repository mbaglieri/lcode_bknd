Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../config/config'
mongo   = require '../../../../dbs/mongoose'
service = require '../../../../service'
utils   = require '../../../../tools/utils'
data_adapter = require '../../../../adapters'

# TODO: CREATE CRUD
@get_all = (req, res) ->
  perPage = 10
  page    = req.query.page || 0

  if req.query.action
    qury = 
      action:
        ac_type: { '$regex' : req.query.action, '$options' : 'i' }
      status : $in: ['COMPLETED','ERROR', 'ACTIVE', 'IN_PROGRESS']
  else 
    qury =
      status : $in: ['COMPLETED','ERROR', 'ACTIVE', 'IN_PROGRESS']
  Promise.try ->
    mongo.qtask.countDocuments qury
  .then (count_qt_u_exec) ->
    @count_qt_u_exec = count_qt_u_exec

    mongo.qtask.find qury
    .populate('action', {_id:0,ac_type:1})
    .populate('worker', {_id:0,id_server:1,status:1})
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

# Create endpoint /api/qtask/:id for GET
@get_one = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->

    mongo.qtask.findOne
      _id    : req.params.id
      status : $in: ['COMPLETED','ERROR', 'ACTIVE', 'IN_PROGRESS']
    .populate('action', {_id:0,ac_type:1})
    .populate('worker', {_id:0,id_server:1,status:1})
    .select(["-__v","-created_at"])
    .exec()
  .then (qtask) ->
    res.send JSON.stringify qtask

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

# Create endpoint /api/qtask/:id for PUT
@modify = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.qtask.findOne 
      _id    : req.params.id
      status : $in: ['COMPLETED','ERROR', 'ACTIVE', 'IN_PROGRESS']
    .exec()
  .then (qtask) ->
    if not qtask
      throw new Error("NOT_FOUND")
    qtask.status   = req.body.status

    qtask.saveAsync()
  .then (qtask) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

# Create endpoint /api/qtask/:id for DELETE
@delete = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.qtask.findOne 
      _id    : req.params.id
      user   : req.user
    .exec()
  .then (q_u) ->
    if not q_u
      throw new Error("NOT_FOUND")

    q_u.status   = 'REMOVED'
    q_u.saveAsync()
  .then (qtask) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@disable_from_server = (req,res) ->
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

    mongo.qtask.updateMany( { 
      worker: server ,status:$in:['IN_PROGRESS','ACTIVE']},
      { status: 'REMOVED' }
    )
  .then (qtask) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
