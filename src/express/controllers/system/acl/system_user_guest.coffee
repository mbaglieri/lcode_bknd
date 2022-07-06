Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../config/config'
mongo   = require '../../../../dbs/mongoose'
service = require '../../../../service'
utils   = require '../../../../tools/utils'
data_adapter = require '../../../../adapters'

@get_all = (req, res) ->
  perPage = 10
  page    = req.query.page || 0

  qury = {}
  Promise.try ->
    if req.query.status
      qury = 
        status: { '$regex' : req.query.status, '$options' : 'i' }

    mongo.user_guest.find  qury
    .select(["-__v","-created_at"])
    .limit(perPage)
    .skip(perPage * page)
    .sort( created_at: 'asc')
    .exec()
  .then (user_guest_list) ->
    @user_guest_list = user_guest_list
    qury = {}
    mongo.user_guest.countDocuments qury
  .then (count_user_guest) ->

    returnset = {
      data        : @user_guest_list
      count       : count_user_guest
      current_page: page
      status      : 200
    }
    res.send JSON.stringify returnset

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)


@modify = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.user_guest.findOne
      _id: req.params.id 
    .exec()
  .then (user_guest_item) ->
    if not user_guest_item
      throw new Error("NOT_FOUND")
    if req.body.username
      user_guest_item.username   = req.body.username
    if req.body.status
      user_guest_item.status   = req.body.status
    if req.body.json_data
      user_guest_item.json_data   = req.body.json_data
      user_guest_item.markModified('json_data')
    user_guest_item.saveAsync()
  .then (user_guest_item) ->

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
    mongo.user_guest.findOne
      _id: req.query.id
    .exec()
  .then (user_guest_item) ->
    if not user_guest_item
      throw new Error('NOT_FOUND')
    @user_guest_item.removeAsync()
  .then (num) ->
    res.json
      message: num + ' deleted'
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@delete_all = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.user_guest.deleteManyAsync()
  .then (pst) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
