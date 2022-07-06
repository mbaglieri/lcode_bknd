Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../config/config'
mongo   = require '../../../../dbs/mongoose'
service = require '../../../../service'
utils   = require '../../../../tools/utils'
data_adapter = require '../../../../adapters'
log          = require('../../../../tools/log').create 'controller.system.topology.community'
@get_communities = (req, res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    service.topology.community.get_communities(req.query, req.user)
  .then (r) ->
    res.send JSON.stringify r

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@my_communities = (req, res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    service.topology.community.my_communities(req.query, req.user)
  .then (r) ->
    res.send JSON.stringify r

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@pub_sub = (req,res) ->
  d_json = {
    status: 200
  }
  Promise.try ->
    parms = req.body
    parms.id = req.params.id
    service.topology.community.pub_sub(req.body, req.user, true)
  .then (network_user_h_) ->
    returnset = {
      status: 200  
    }
    res.status(returnset.status).send JSON.stringify returnset

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@upload_photos =  (req, res) ->
  d_json = {
    status: 404
  }
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
    mongo.community.findOne
      key  :  req.body.key
    .populate('network')
    .exec()
  .then (c) ->
    if not c
      throw new Error("NO_NETOWKR_FOUND")
    if c.network.creator is not req.user
      throw new Error("USER_CANT_EDIT")
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
      status: 200
    }
    res.json returnset
  .catch (err) ->
    if err.message in ['NO_USER']
      d_json.status = 406001
    log.e "Not upload photo: #{err}"
    res.status(d_json.status).json(d_json)

 
@by_network = (req, res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    service.topology.community.by_network(req.query, req.user, true)
  .then (r) ->
    res.send JSON.stringify r 

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

    
# Create endpoint /api/networks for GET
@get = (req, res) ->
  d_json = {
    status: 404
  }
  perPage = 10
  page    = req.query.page || 0

  where = {}
  Promise.try ->
    if req.query.key
      where.key = { '$regex' : req.query.key, '$options' : 'i' }
    if req.params.id
      where._id =req.params.id


    mongo.community.findOne where
    .exec()
  .then (community) ->
    if not community
      throw new Error("NO_NETOWKR_FOUND")
    
    returnset = {
      data  : data_adapter.api.community.to_user_admin community 
      status: 200
    }
    res.send JSON.stringify returnset
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
    
# Create endpoint /api/community/:id for PUT
@add = (req,res) ->
  d_json = {
    status: 404
  }
  cat_key = req.body.cfg.category_type  
  Promise.try ->
    service.topology.community.add(req.body, req.user, true)
  .then (r) ->
    res.send JSON.stringify r
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

# Create endpoint /api/community/:id for PUT
@modify = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    parms    = req.body
    parms.id = req.params.id
    service.topology.community.modify(parms, req.user, true)
  .then (r) ->
    res.send JSON.stringify r
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
  

# Create endpoint /api/community/:id for DELETE
@delete = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.community.findOne 
      _id    : req.params.id
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
