Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../config/config'
mongo   = require '../../../../dbs/mongoose'
service = require '../../../../service'
utils   = require '../../../../tools/utils'
data_adapter = require '../../../../adapters'

# Create endpoint /api/qtask_action for GET
@get_all = (req, res) ->
  perPage = 10
  page    = req.query.page || 0
  qury    = {}
  if req.query.action
    qury.ac_type = { '$regex' : req.query.action, '$options' : 'i' }
  Promise.try ->
    mongo.qtask_action.countDocuments qury
  .then (count_qt_u_exec) ->
    @count_qt_u_exec = count_qt_u_exec
    mongo.qtask_action.find qury
    .limit(perPage)
    .skip(perPage * page)
    .select(["-__v","-created_at"])
    .sort( created_at: 'asc', is_disabled: 'asc')
    .exec()
  .then (qt_users_exec) ->
    r = 
      count: @count_qt_u_exec
      data : qt_users_exec
    res.send JSON.stringify r

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

# Create endpoint /api/qtask_action/:id for GET
@get_one = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->

    mongo.qtask_action.findOne
      _id    : req.params.id
    .select(["-__v","-created_at"])
    .exec()
  .then (qtask_action) ->
    res.send JSON.stringify qtask_action

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

# Create endpoint /api/qtask_action/:id for PUT
@modify = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.qtask_action.findOne 
      _id    : req.params.id
    .exec()
  .then (qtask_action) ->
    if not qtask_action
      throw new Error("NOT_FOUND")

    qtask_action.is_disabled   = req.body.is_disabled

    qtask_action.saveAsync()
  .then (qtask_action) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

# Create endpoint /api/qtask_action/:id for DELETE
@delete = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.qtask_action.findOne 
      _id    : req.params.id
    .exec()
  .then (q_u) ->
    if not q_u
      throw new Error("NOT_FOUND")

    q_u.is_disabled   = true
    q_u.saveAsync()
  .then (qtask_action) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@disable_all = (req,res) ->
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

    mongo.qtask_action.updateMany( { is_disabled: false },
      { is_disabled: true}
    )
  .then (qtask) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@enable_all = (req,res) ->
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

    mongo.qtask_action.updateMany( { is_disabled: true },
      { is_disabled: false}
    )
  .then (qtask) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)