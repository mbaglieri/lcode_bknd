Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../config/config'
mongo   = require '../../../../dbs/mongoose'
service = require '../../../../service'
utils   = require '../../../../tools/utils'
data_adapter = require '../../../../adapters'
Sequelize    = require 'sequelize'
Op           = Sequelize.Op
# Create endpoint /api/users/:id/firebase for GET
@get_all = (req,res) ->
  d_json = {
    status: 404
  }
  perPage = 10
  page    = req.query.page || 0
  Promise.try ->
    mongo.user.findOne
      _id: req.params.id
    .exec()
  .then (user_item) ->
    if not user_item
      throw new Error("NOT_FOUND")
    @user_item = user_item

    mongo.token.countDocuments
      user : user_item
  .then (count_) ->
    @count_ = count_
    mongo.token.find
      user : @user_item
    .populate("")
    .limit(perPage)
    .skip(perPage * page)
    .exec()
  .then (f_tokens) ->
    r_data = {}
    if @user_item
      r_data = @user_item

    returnset = {
      user  : r_data
      data  : f_tokens
      count : @count_
      status: 200
    }
    res.send JSON.stringify returnset

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)


# Create endpoint /api/users/:id/firebase for DELETE
@delete = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    
    mongo.token.findById req.query.id_token
  .then (validation) ->
    if not validation
      throw new Error("NOT_FOUND")
    validation.removeAsync()
  .then (v_) ->
    res.json
      message: v_ + ' deleted'
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@delete_all = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    
    mongo.user.findOne
      _id: req.params.id
    .exec()
  .then (user_item) ->
    if not user_item
      throw new Error("NOT_FOUND")
    mongo.token.deleteManyAsync
      user: user_item
  .then (pst) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
