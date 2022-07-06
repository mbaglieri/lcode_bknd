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

    mongo.system_validation.find  
      user:user
    .select(["-__v","-created_at"])
    .limit(perPage)
    .skip(perPage * page)
    .sort( created_at: 'asc')
    .exec()
  .then (f_tokens) ->
    f_tokens_l = []
    for r in f_tokens
      f_tokens_l.push r 
    _data = {}
    if @user
      _data = @user

    returnset = {
      user  : _data
      data  : f_tokens_l
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

    mongo.system_validation.findById req.query.id_validation
  .then (system_validation) ->
    if not system_validation
      throw new Error('NOT_FOUND')
    system_validation.removeAsync()
  .then (num) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)