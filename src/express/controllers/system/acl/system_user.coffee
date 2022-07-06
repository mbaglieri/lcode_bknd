Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../config/config'
mongo   = require '../../../../dbs/mongoose'
service = require '../../../../service'
utils   = require '../../../../tools/utils'
data_adapter = require '../../../../adapters'

# Create endpoint /api/users for GET
@get_all = (req, res) ->
  perPage = 10
  page    = req.query.page || 0

  qury = {}
  Promise.try ->
    if req.query.email
      qury = 
        authority: { '$regex' : req.query.email, '$options' : 'i' }
    else if req.query.status
      qury = 
        status: req.params.status
    mongo.user.find  qury
    .select(["-__v","-created_at"])
    .limit(perPage)
    .skip(perPage * page)
    .sort( created_at: 'asc')
    .exec()
  .then (user_list) ->
    @user_list = user_list
    mongo.user.countDocuments qury
  .then (count_user) ->
    returnset = {
      data        : @user_list
      count       : count_user
      current_page: page
      status      : 200
    }
    res.send JSON.stringify returnset

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@get_one = (req, res) ->
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
    @user_item = user_item

    mongo.user_role.find
      user : user_item
    .populate('role')
    .exec()
  .then (user_roles) ->    
    roles = []
    roles.push r for r in user_roles
      
    role_data = {}
    if @user_item
      role_data = @user_item
      role_data.roles = roles

    returnset = {
      data  : role_data
      status: 200
    }
    res.send JSON.stringify returnset

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

  d_json = {
    status: 404
  }

@modify = (req, res) ->
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
    if req.body.first_name
      user_item.first_name  = req.body.first_name
    if req.body.last_name
      user_item.last_name   = req.body.last_name
    if req.body.phone
      user_item.phone       = req.body.phone
    if req.body.phone1
      user_item.phone1      = req.body.phone1
    if req.body.status
      user_item.status      = req.body.status
    if req.body.validation
      user_item.validation  = req.body.validation
    if req.body.description
      user_item.description = req.body.description
    if req.body.avatar
      user_item.avatar      = req.body.avatar
    if req.body.background_img
      user_item.background_img   = req.body.background_img
    if req.body.job
      user_item.job          = req.body.job
    if req.body.education
      user_item.education    = req.body.education
    if req.body.relationship
      user_item.relationship = req.body.relationship
    if req.body.birthday
      user_item.birthday  = req.body.birthday
    if req.body.facebook
      user_item.facebook  = req.body.facebook
    if req.body.instagram
      user_item.instagram = req.body.instagram
    if req.body.twitter
      user_item.twitter   = req.body.twitter
    if req.body.linkedin
      user_item.linkedin  = req.body.linkedin
    user_item.saveAsync()
  .then (user_item) ->

    res.json
      status : 200
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

# Create endpoint /api/users/:id for DELETE
@delete = (req,res) ->
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
    user_item.status =   'REMOVED' 
    user_item.saveAsync()
  .then (num) ->
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
    mongo.user.findOne
      _id: req.params.id
    .exec()
  .then (user_item) ->
    if not user_item
      throw new Error('NOT_FOUND')
    @user_item = user_item
    mongo.user_role.find
      user: @user_item
    .exec()
  .then (rq_roles) ->
    Promise.all(_remove r for r in rq_roles)
  .then (usr_roles) ->
    @user_item.removeAsync()
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

