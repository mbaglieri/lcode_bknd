Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../config/config'
{env}   = require '../../../../config/env'
mongo   = require '../../../../dbs/mongoose'
service = require '../../../../service'
data_adapter = require '../../../../adapters'
utils   = require '../../../../tools/utils'

@get_network_categories = (req, res) ->
  Promise.try ->
    service.topology.network.get_network_categories(req.query)
  .then (r) ->
    res.send JSON.stringify r

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
    
@get_detail_network = (req, res) ->
  Promise.try ->
    service.topology.network.get_detail_network(req.query.id)
  .then (r) ->
    res.send JSON.stringify r

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
  
 
@owner_networks = (req, res) ->
  Promise.try ->
    console.log "owner_networks"
    service.topology.network.owner_networks(req.query, req.user)
  .then (r) ->
    res.send JSON.stringify r 

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

    
# Create endpoint /api/networks for GET
@get = (req, res) ->
  perPage = 10
  page    = req.query.page || 0

  where = {}
  Promise.try ->
    if req.query.key
      where.key = { '$regex' : req.query.key, '$options' : 'i' }
    if req.params.id
      where._id =req.params.id

    where.creator = req.user

    mongo.network.findOne where
    .exec()
  .then (network) ->
    if not network
      throw new Error("NO_NETOWKR_FOUND")
    console.log data_adapter
    returnset = {
      data  : data_adapter.api.network.to_user network || {}
      status: 200
    }
    res.send JSON.stringify returnset
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
    
# Create endpoint /api/network/:id for PUT
@add = (req,res) ->
  d_json = {
    status: 404
  }
  cat_key = req.body.cfg.category_type  
  Promise.try ->
    service.topology.network.add(req.body,req.user,true)
  .then (r) ->
    res.send JSON.stringify r
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

# Create endpoint /api/network/:id for PUT
@modify = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    parms    = req.body
    parms.id = req.params.id
    service.topology.network.modify(parms,req.user, true)
  .then (r) ->
    res.send JSON.stringify r
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
  
# Create endpoint /api/network/:id for DELETE
@delete = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.network.findOne 
      _id    : req.query.id
      creator: network.creator
    .exec()
  .then (q_u) ->
    if not q_u
      throw new Error("NOT_FOUND")

    q_u.status   = 'INACTIVE'
    q_u.saveAsync()
  .then (network) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@pub_sub = (req,res) ->
  d_json = {
    status: 200
  }
  Promise.try ->

    service.topology.network.pub_sub(req.body, req.user)
  .then (network_user_h_) ->
    returnset = {
      status: 200
    }
    res.status(returnset.status).send JSON.stringify returnset

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@change_owner = (req,res) ->
  d_json = {
    status: 400 
  }
  network_id = req.body.network_id || req.query.network_id
  new_owner  = req.body.new_owner || req.query.new_owner
  
  Promise.try ->
    mongo.network.findOne
      _id    : network_id
      creator: req.user
    .exec()
  .then (network) ->
    if not network
      throw new Error("NO_NETOWKR_FOUND")

    @network = network
    
    mongo.user.findOne
      email: new_owner
    .exec()
  .then (user) ->
    if not user
      throw new Error("NO_USER_FOUND")

    if(new_owner)
      @network.creator = user
      
    @network.saveAsync()
  .then (network) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@upload_photos =  (req, res) ->
  utils.set_req_res_upload(req,res)
  upload_type = req.body.upload_type or req.query.upload_type
  f = 0
  if not req.files or not req.user
    res.json
      status: 200
      files : 0
      data   : []
    return;

  Promise.try ->
    mongo.network.findOne
      key    : req.body.key
      creator: req.user
    .exec()
  .then (c) ->
    if not c
      throw new Error("NO_NETOWKR_FOUND")
    @c = c
    # if not('image' in req.files[0].mimetype.split '/')
    #   throw new Error("NOT_IMAGE")
    if(req.body.is_icon == 'true')
      @c.cfg.icon  = req.files[0].location
    else
      @c.cfg.image = req.files[0].location

    @c.markModified('cfg');
    @c.saveAsync()
  .then (network) ->
    returnset = {
      data  :network
      status: 200,
    }
    res.json returnset
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
