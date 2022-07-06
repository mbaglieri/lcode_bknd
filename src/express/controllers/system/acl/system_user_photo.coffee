Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../config/config'
mongo   = require '../../../../dbs/mongoose'
service = require '../../../../service'
utils   = require '../../../../tools/utils'
data_adapter = require '../../../../adapters'

@get_all = (req,res) ->
  d_json = {
    status: 404
  }
  perPage = 10
  page    = req.query.page || 0
  Promise.try ->
    mongo.user.findOne
      _id: req.params.id
    .select(["-__v","-created_at","-password"])
    .exec()
  .then (user) ->
    if not user
      throw new Error("NOT_FOUND")
    @user = user

    mongo.user_photo.find  
      user:user
    .select(["-__v","-created_at"])
    .limit(perPage)
    .skip(perPage * page)
    .sort( created_at: 'asc')
    .exec()
  .then (photos) ->
    phts = []
    for r in photos
      phts.push r 
    _data = {}
    if @user
      _data = @user

    returnset = {
      user  : _data
      data  : phts
      status: 200
    }
    res.send JSON.stringify returnset

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)



@delete = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.user.findOne
      _id: req.params.id
    .select(["-__v","-created_at","-password"])
    .exec()
  .then (user) ->

    mongo.user_photo.findOne
      user   : user
      _id     : req.query.id_photo
    .exec()
  .then (user_photo) ->
    if not user_photo
      throw new Error('NOT_FOUND')
    user_photo.removeAsync()
  .then (num) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)