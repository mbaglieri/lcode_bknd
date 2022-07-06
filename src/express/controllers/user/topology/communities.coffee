Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../config/config'
mongo   = require '../../../../dbs/mongoose'
service = require '../../../../service'
utils   = require '../../../../tools/utils'

@get_communities = (req, res) ->
  Promise.try ->
    service.topology.community.get_communities(req.query, req.user)
  .then (r) ->
    res.send JSON.stringify r

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@my_communities = (req, res) ->
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

    service.topology.community.pub_sub(req.body, req.user, false)
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
    mongo.community.findOne
      key  :  req.body.key
    .populate('network')
    .exec()
  .then (c) ->
    if not c
      throw new Error("NO_NETOWKR_FOUND")
    if c.network.creator != req.user
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