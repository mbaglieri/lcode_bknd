Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../config/config'
mongo   = require '../../../../dbs/mongoose'
service = require '../../../../service'
utils   = require '../../../../tools/utils'
data_adapter = require '../../../../adapters'


# Create endpoint /api/subscription_tx for GET
@get_all = (req, res) ->
  perPage = 10
  page    = req.query.page || 0


  where = {}
  Promise.try ->
    if req.user
      where.user  = req.user
    # if req.query.id_subscription
    #   where.id_subscription = req.query.id_subscription
    if req.query.id_offer
      where.offer._id = req.query.id_offer
    if req.query.type
      if req.query.type is 'ALL'
        where.type = 
          $in:  ['SYSTEM','MERCHANT','COMMUNITY','ENVIRONMENT']
      else
        where.type =  
          $in: req.query.type.split ","
    else
      where.type =   
          $in: ['SYSTEM']
    if not req.query.status
     where.status =  
          $in: ['PENDING', 'ACTIVE',  'OVERQUOTA', 'LIMITED']
    else 
      where.status = 
          $in:  req.query.status.split ","

    mongo.user_subscription.countDocuments where
  .then (count_qt_u_exec) ->
    @count_qt_u_exec = count_qt_u_exec

    mongo.user_subscription.find where
    .select(["-__v","-created_at"])
    .populate('subscription tx')
    .limit(perPage)
    .skip(perPage * page)
    .sort( created_at: 'asc')
    .exec()
  .then (qt_users_exec) ->
    r = 
      count: @count_qt_u_exec
      data : qt_users_exec
    res.send JSON.stringify r

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

# Create endpoint /api/subscription_tx/:id for GET
@get_one = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->

    mongo.user_subscription.findOne
      _id     : req.params.id
      user    : req.user
    .select(["-__v","-created_at"])
    .exec()
  .then (subscr_tx) ->
    res.send JSON.stringify subscr_tx

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

# Create endpoint /api/subscription_tx/:id for PUT
@modify = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.user_subscription.findOne
      _id     : req.params.id
      user    : req.user
    .select(["-__v","-created_at"])
    .exec()
  .then (subscription_tx) ->
    if not subscription_tx
      throw new Error("NOT_FOUND")
    subscription_tx.status   = req.body.status
    subscription_tx.saveAsync()
  .then (subscription_tx) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

# Create endpoint /api/subscription_tx/:id for DELETE
@disable = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.user_subscription.findOne
      _id     : req.params.id
      user    : req.user
    .select(["-__v","-created_at"])
    .exec()
  .then (subscription_tx) ->
    if not subscription_tx
      throw new Error("NOT_FOUND")

    subscription_tx.status   = 'DEACTIVATED'
    subscription_tx.saveAsync()
  .then (subscription_tx) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
