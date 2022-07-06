Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../config/config'
mongo   = require '../../../../dbs/mongoose'
service = require '../../../../service'
utils   = require '../../../../tools/utils'
data_adapter = require '../../../../adapters'
@get_cart = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.user_subscription_tx.find
      user: req.user
      type: "SYSTEM"
      status: 'PENDING'
    .populate('subscription')
    .exec()
  .then (subscription_item) ->
    if not subscription_item
      throw new Error("NOT_FOUND")
    @subscription_item = subscription_item

    res.send JSON.stringify subscription_item

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@get_all = (req, res) ->
  perPage = 10
  page    = req.query.page || 0
  qury = 
    limit : perPage,
    offset: (perPage * page)

  where = {}
  Promise.try ->
    if req.query.id_user
      where.user._id = id_user
    if req.query.id_subscription
      where.subscription._id = req.query.id_subscriptions
    if req.query.id_offer
      where.offer._id = req.query.id_offer
    if req.query.type
      if req.query.type is 'ALL'
        where.type =
          $in:  ['SYSTEM','MERCHANT','COMMUNITY','ENVIRONMENT']
      else
        where.type = req.query.type.split ","
    else
      where.type =  'SYSTEM'
    if not req.query.status
     where.status = 
      $in:  ['PENDING', 'ACTIVE',  'OVERQUOTA', 'LIMITED']
    else 
      where.status = 
        $in:  req.query.status.split ","

    mongo.user_subscription_tx.countDocuments where
  .then (count_qt_u_exec) ->
    @count_qt_u_exec = count_qt_u_exec
    mongo.user_subscription_tx.find where
    .select(["-__v","-created_at"])
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
 
@get_one = (req,res) ->
  d_json = {
    status: 404
  }
  log.i "get_one.subscription"
  Promise.try ->
    mongo.user_subscription_tx.findOne
      _id    : req.params.id
      user   : req.user
    .populate('subscription', {_id:0})
    .select(["-__v","-created_at"])
    .exec()
  .then (user_subscription_tx) ->
    res.send JSON.stringify user_subscription_tx

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
    

@pay = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    service.payments.process.payment(req.body,req.user)
  .then (subscr_tx) ->
    res.json
      status: 200
      data  : subscr_tx
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)


@delete = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.user_subscription_tx.findOne 
      _id    : req.params.id
      user   : req.user
    .exec()
  .then (q_u) ->
    if not q_u
      throw new Error("NOT_FOUND")

    q_u.status   = 'REMOVED'
    q_u.saveAsync()
  .then (user_subscription_tx) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
