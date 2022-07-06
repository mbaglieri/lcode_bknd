Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../config/config'
{env}   = require '../../../../config/env'
mongo   = require '../../../../dbs/mongoose'
service = require '../../../../service'
utils   = require '../../../../tools/utils'

@get_network_categories = (req, res) ->
  Promise.try ->
    service.topology.network.get_network_categories(req.query)
  .then (r) ->
    res.send JSON.stringify r

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
    
@get_networks = (req, res) ->
  Promise.try ->
    service.topology.network.get_networks(req.query, true)
  .then (r) ->
    res.send JSON.stringify r

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

     
@get_best_ranked_networks = (req, res) ->
  Promise.try ->
    service.topology.network.get_best_ranked_networks(req.query)
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
  

@my_networks = (req, res) ->
  Promise.try ->
    console.log "my_networks"
    service.topology.network.my_networks(req.query, req.user)
  .then (r) ->
    res.send JSON.stringify r

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
# Create endpoint /api/networks for GET

@public_user_data = (req, res) ->
  Promise.try ->
    service.topology.network.public_user_data(req.query)
  .then (r) ->
    res.send JSON.stringify r

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
    
@get_all = (req, res) ->
  Promise.try ->
    service.topology.network.get_networks(req.query, false)
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
    if req.query.id
      where._id =req.query.id

    where.creator = req.user

    mongo.network.findOne where
    .exec()
  .then (qt_users_exec) ->
    if not network
      throw new Error("NO_NETOWKR_FOUND")
    returnset = {
      data  : data_adapter.network.to_user network || {}
      status: 200
    }
    res.send JSON.stringify returnset
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
