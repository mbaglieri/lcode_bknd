Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../config/config'
mongo   = require '../../../../dbs/mongoose'
service = require '../../../../service'
utils   = require '../../../../tools/utils'
data_adapter = require '../../../../adapters'

@get_customers = (req, res) ->
  perPage = 10
  page    = req.query.page || 0
  qury = 
    limit : perPage,
    offset: (perPage * page)

  where = {}
  Promise.try ->
  if req.query.id_user
    where.user._id = req.query.id_user
  if req.query.plan
      where.plan = req.query.plan
    if req.query.id_tx
      where.tx._id = req.query.id_tx
    if req.query.type
      if req.query.type is 'ALL'
        where.type =  ['SYSTEM','MERCHANT','COMMUNITY','ENVIRONMENT']
      else
        where.type = req.query.type.split ","
    else
      where.type =  ['SYSTEM']
    if not req.query.status
      where.status = ['PENDING','ACTIVE', 'DEACTIVATED', 'REMOVED', 'OVERQUOTA', 'LIMITED']
    else 
      where.status = req.query.status.split ","

    mongo.user_subscription.find where
    .exec()
  .then (subscription_list) ->
    @subscription_list = subscription_list
    mongo.user_subscription.countDocuments where
  .then (count_subscription) ->
    returnset = {
      data        : subscription_list
      count       : count_subscription
      current_page: page
      status      : 200
    }
    res.send JSON.stringify returnset

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

# Create endpoint /api/users/:id for GET
@get_one = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.user_subscription.findOne
      _id: req.params.id
    .populate('user')
    .exec()
  .then (user_s_item) ->
    if not user_s_item
      throw new Error("NOT_FOUND")
    
    returnset = {
      data  : user_s_item
      status: 200
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
    mongo.user_subscription.findOne 
      _id    : req.body.id
    .exec()
  .then (subscription) ->
    if not subscription
      throw new Error("NOT_FOUND")
    if req.body.status
      subscription.status   = req.body.status
    if req.body.plan
      subscription.plan    = req.body.plan
    if req.body.expiration_date
      subscription.expiration_date = moment(req.body.expiration_date, 'YYYY-MM-DD').toDate()

    subscription.saveAsync()
  .then (subscription) ->
    res.json
      status : 200
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
    
@disable = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.user_subscription.findOne 
      _id    : req.body.id
    .exec()
  .then (subscription) ->
    if not subscription
      throw new Error("NOT_FOUND")
    subscription.status = 'DEACTIVATED'
    subscription.saveAsync()
  .then (num) ->
    res.json
      status : 200
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
