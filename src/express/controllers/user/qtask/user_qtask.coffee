Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../config/config'
mongo   = require '../../../../dbs/mongoose'
service = require '../../../../service'
utils   = require '../../../../tools/utils'
data_adapter = require '../../../../adapters'


# Create endpoint /api/qtask_user_exec for GET
@get_all = (req, res) ->
  perPage = 10
  page    = req.query.page || 0
  q = 
    user   : req.user
    status : $in: ['COMPLETED','ERROR', 'ACTIVE', 'IN_PROGRESS']
  Promise.try ->

    mongo.qtask_user_exec.countDocuments q
  .then (count_qt_u_exec) ->
    @count_qt_u_exec = count_qt_u_exec

    mongo.qtask_user_exec.find q
    .populate('action', {_id:0,ac_type:1})
    .populate('worker', {_id:0,id_server:1,status:1})
    .populate('environment', {_id:0,name:1,key:1})
    .populate('qtask_user',{_id:0,status:1,enabled:1,pong_date:1})
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

# Create endpoint /api/qtask_user_exec/:id for GET
@get_one = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->

    mongo.qtask_user_exec.findOne
      _id    : req.params.id
      user   : req.user
      status : $in: ['COMPLETED','ERROR', 'ACTIVE', 'IN_PROGRESS']
    .populate('action', {_id:0,ac_type:1})
    .populate('worker', {_id:0,id_server:1,status:1})
    .populate('environment', {_id:0,name:1,key:1})
    .populate('qtask_user',{_id:0,status:1,enabled:1,pong_date:1})
    .select(["-__v","-created_at"])
    .exec()
  .then (qtask_user_exec) ->
    res.send JSON.stringify qtask_user_exec

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

# Create endpoint /api/qtask_user_exec/:id for PUT
@modify = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.qtask_user_exec.findOne 
      _id    : req.params.id
      user   : req.user
      status : $in: ['COMPLETED','ERROR', 'ACTIVE', 'IN_PROGRESS']
    .exec()
  .then (qtask_user_exec) ->
    if not qtask_user_exec
      throw new Error("NOT_FOUND")
    qtask_user_exec.status   = req.body.status
    qtask_user_exec.saveAsync()
  .then (qtask_user_exec) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

# Create endpoint /api/qtask_user_exec/:id for DELETE
@disable = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.qtask_user_exec.findOne 
      _id    : req.params.id
      user   : req.user
    .exec()
  .then (q_u) ->
    if not q_u
      throw new Error("NOT_FOUND")

    q_u.status   = 'REMOVED'
    q_u.saveAsync()
  .then (qtask_user_exec) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
