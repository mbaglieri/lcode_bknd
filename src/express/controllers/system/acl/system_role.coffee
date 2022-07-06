Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../config/config'
mongo   = require '../../../../dbs/mongoose'
service = require '../../../../service'
utils   = require '../../../../tools/utils'
data_adapter = require '../../../../adapters'
Sequelize    = require 'sequelize'
Op           = Sequelize.Op
# Create endpoint /api/roles for GET
@get_all = (req, res) ->
  perPage = 10
  page    = req.query.page || 0

  qury = {}
  Promise.try ->
    if req.query.path
      qury = 
        authority: { '$regex' : req.query.authority, '$options' : 'i' }

    mongo.role.find  qury
    .select(["-__v","-created_at"])
    .limit(perPage)
    .skip(perPage * page)
    .sort( created_at: 'asc')
    .exec()
  .then (role_list) ->
    @role_list = role_list
    mongo.role.countDocuments qury
  .then (count_role) ->
    returnset = {
      data        : @role_list
      count       : count_role
      current_page: page
      status      : 200
    }
    res.send JSON.stringify returnset

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

# Create endpoint /api/roles/:id for GET
@get_one = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.role.findOne
      _id: req.params.id
    .exec()
  .then (role_item) ->
    if not role_item
      throw new Error("NOT_FOUND")
    @role_item = role_item

    mongo.requestmap_role.find
      role : role_item
    .populate('requestmap')
    .exec()
  .then (requestmap_roles) ->    
    requestmaps = []
    requestmaps.push r for r in requestmap_roles
      
    role_data = {}
    if @role_item
      role_data = @role_item
      role_data.requestmaps = requestmaps

    returnset = {
      data  : role_data
      status: 200
    }
    res.send JSON.stringify returnset

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

# Create endpoint /api/roles/:id for PUT
@post = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.role.findOne
      authority: req.body.authority
    .exec()
  .then (role_item) ->
    if role_item
      throw new Error('DUPLICATE_ITEM')

    mongo.role
      authority: req.body.authority
    .saveAsync()
  .then (role) ->
    res.json
      status: 200
      data  : role
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@modify = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.role.findOne
      _id: req.params.id 
    .exec()
  .then (role_item) ->
    if not role_item
      throw new Error("NOT_FOUND")
    if req.body.authority
      role_item.authority   = req.body.authority
    role_item.saveAsync()
  .then (role_item) ->

    res.json
      status : 200
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@delete = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.role.findOne
      _id: req.params.id
    .exec()
  .then (role_item) ->
    if not role_item
      throw new Error('NOT_FOUND')
    @role_item = role_item
    mongo.requestmap_role.find
      role: @role_item
    .exec()
  .then (rq_roles) ->
    Promise.all(_remove r for r in rq_roles)
  .then (usr_roles) ->
    @role_item.removeAsync()
  .then (num) ->
    res.json
      message: num + ' deleted'
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

_remove = (r) ->
  Promise.try ->
    r.removeAsync()
  .then (requestmap_item) ->
    return requestmap_item

@pair_requestmap = (req,res) ->
  d_json = {
    status: 404
  }
  qury = {}
  rq   = {}
  Promise.try ->
    if req.query.path
      qury.authority = { '$regex' : req.query.authority, '$options' : 'i' }
    if req.body.id_role
      qury._id = req.body.id_role

    mongo.role.findOne qury
  .then (role_item) ->
    if not role_item
      throw new Error('NOT_FOUND')
    @role_item = role_item

    if req.body.path
      rq = 
        path : req.body.path
        methd: req.body.methd
    else
      rq._id = req.body.id_requestmap
    mongo.requestmap.findOne rq
  .then (requestmap) ->
    if not requestmap
      throw new Error('NOT_FOUND')
    @requestmap = requestmap
    mongo.requestmap_role.findOne
      where:
        role      : @role_item
        requestmap: @requestmap
  .then (requestmap_role) ->
    if not requestmap_role
      requestmap_role = mongo.requestmap_role
        role      : @role_item
        requestmap: @requestmap
    requestmap_role.saveAsync()
  .then (rqmap_role_s) ->
    res.json
      status: 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

