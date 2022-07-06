Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../config/config'
mongo   = require '../../../../dbs/mongoose'
service = require '../../../../service'
utils   = require '../../../../tools/utils'
data_adapter = require '../../../../adapters'

# Create endpoint /api/qtask_user for GET
@get_all = (req, res) ->
  perPage = 10
  page    = req.query.page || 0

  qury = 
    status : $in: ['INACTIVE', 'CONNECTED','ACTIVE', 'INTRO','IN_WORKOUT', 'DISCONNECTED']
  Promise.try ->
    if req.query.id_server
      qury.worker = 
        id_server: { '$regex' : req.query.id_server, '$options' : 'i' }

    mongo.qtask_user.countDocuments qury
  .then (count_qt_u_exec) ->
    @count_qt_u_exec = count_qt_u_exec
    mongo.qtask_user.find qury
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

@get_by_user = (req, res) ->
  perPage = 10
  page    = req.query.page || 0
  qury    = {}

  Promise.try ->
    mongo.user.findOne
      email: req.query.email
    .exec()
  .then (usr) ->
    if not usr
      throw new Error("NOT_FOUND")
    @usr = usr
    if req.query.id_server
      qury.worker =
        id_server: { '$regex' : req.query.id_server, '$options' : 'i' }
    qury.user = usr
    mongo.qtask_user.countDocuments qury
  .then (count_qt_u_exec) ->
    @count_qt_u_exec = count_qt_u_exec
    mongo.qtask_user.find qury
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
# Create endpoint /api/qtask_user/:id for GET
@get_one = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->

    mongo.qtask_user.findOne
      _id    : req.params.id
      status : $in: ['COMPLETED','ERROR', 'ACTIVE', 'IN_PROGRESS']
    .populate('worker', {_id:0,id_server:1,status:1,hits:1})
    .populate('environment', {_id:0,key:1,name:1})
    .select(["-__v","-created_at"])
    .exec()
  .then (qtask_user) ->
    res.send JSON.stringify qtask_user

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

# Create endpoint /api/qtask_user/:id for PUT
@modify = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.qtask_user.findOne 
      _id    : req.params.id
      status : $in: ['INACTIVE', 'CONNECTED','ACTIVE', 'INTRO','IN_WORKOUT', 'DISCONNECTED']
    .exec()
  .then (qtask_user) ->
    if not qtask_user
      throw new Error("NOT_FOUND")
    qtask_user.status   = req.body.status

    qtask_user.saveAsync()
  .then (qtask_user) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

# Create endpoint /api/qtask_user/:id for DELETE
@delete = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.qtask_user.findOne 
      _id    : req.params.id
    .exec()
  .then (q_u) ->
    if not q_u
      throw new Error("NOT_FOUND")

    q_u.status   = 'INACTIVE'
    q_u.saveAsync()
  .then (qtask_user) ->
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

    mongo.qtask_user.updateMany( { 
      worker: server ,status:$in:['CONNECTED','ACTIVE', 'INTRO','IN_WORKOUT','PING','PING_1', 'PING_2', 'PING_3']},
      { status: 'INACTIVE' }
    )
  .then (qtask_user) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@send_to_new_server = (req,res) ->
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
    @server = server
    mongo.server_ownership.findOne
      status    : "ACTIVE"
      id_server : $nin: id_server
    .sort({'users':-1})
    .exec()
  .then (worker) ->
    @worker = worker
    if not worker
      throw new Error("NOT_FOUND")
    mongo.qtask_user.updateMany( { 
      worker: @server },
      { worker: worker }
    )
  .then (qtask_user) ->
    mongo.qtask_user.countDocuments
      worker: @worker
      status: $in:['CONNECTED','ACTIVE', 'INTRO','IN_WORKOUT', 'DISCONNECTED', 'PING','PING_1', 'PING_2', 'PING_3']
  .then (count_qt_u_exec) ->
    @worker.users = count_qt_u_exec
    @worker.saveAsync()
  .then (_wrk) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)