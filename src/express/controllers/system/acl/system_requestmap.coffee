Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../config/config'
mongo   = require '../../../../dbs/mongoose'
service = require '../../../../service'
utils   = require '../../../../tools/utils'
data_adapter = require '../../../../adapters'
Sequelize    = require 'sequelize'
Op           = Sequelize.Op
# Create endpoint /api/requestmaps for GET
@get_all = (req, res) ->
  perPage = 10
  page    = req.query.page || 0

  qury = {}
  Promise.try ->
    if req.query.path
      qury = 
        path: { '$regex' : req.query.path, '$options' : 'i' }

    mongo.requestmap.find  qury
    .select(["-__v","-created_at"])
    .limit(perPage)
    .skip(perPage * page)
    .sort( created_at: 'asc')
    .exec()
  .then (requestmap_list) ->
    @requestmap_list = requestmap_list
    mongo.requestmap.countDocuments qury
  .then (count_requestmap) ->
    returnset = {
      data        : @requestmap_list
      count       : count_requestmap
      current_page: page
      status      : 200
    }
    res.send JSON.stringify returnset

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@get_one = (req,res) ->
  d_json = {
    status: 404
  }
  r_data = {}
  Promise.try ->
    mongo.requestmap.findOne
      _id: req.params.id
    .exec()
  .then (requestmap_item) ->
    if not requestmap_item
      throw new Error("NOT_FOUND")
    @requestmap_item = requestmap_item

    mongo.requestmap_role.find
      requestmap : @requestmap_item
    .populate('role')
    .exec()
  .then (requestmap_roles) ->
    r = []
    r.push rr.role for rr in requestmap_roles
    if @requestmap_item
      r_data = @requestmap_item
      r_data.roles = r

    returnset = {
      data  : r_data
      status: 200
    }
    res.send JSON.stringify returnset

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@post = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.requestmap.findOne
      path : req.body.path
      methd: req.body.methd
    .exec()
  .then (requestmap_item) ->
    if requestmap_item
      throw new Error('DUPLICATE_ITEM')

    mongo.requestmap
      path       : req.body.path
      methd      : req.body.methd
      description: req.body.description
    .saveAsync()
  .then (requestmap) ->
    res.json
      status: 200
      data  : requestmap
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

# Create endpoint /api/requestmaps/:id for PUT
@modify = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.requestmap.findOne
      _id: req.params.id 
    .exec()
  .then (requestmap_item) ->
    if not requestmap_item
      throw new Error("NOT_FOUND")
    if req.body.path
      requestmap_item.path   = req.body.path
    if req.body.methd
      requestmap_item.methd   = req.body.methd
    if req.body.description
      requestmap_item.description   = req.body.description

    requestmap_item.saveAsync()
  .then (requestmap_item) ->

    res.json
      status : 200
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

# Create endpoint /api/requestmaps/:id for DELETE
@delete = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.requestmap.findOne
      _id: req.params.id
    .exec()
  .then (requestmap_item) ->
    if not requestmap_item
      throw new Error('NOT_FOUND')
    @requestmap_item = requestmap_item
    mongo.requestmap_role.find
      requestmap: @requestmap_item
    .exec()
  .then (rq_requestmaps) ->
    Promise.all(_remove r for r in rq_requestmaps)
  .then (usr_requestmaps) ->
    @requestmap_item.removeAsync()
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
