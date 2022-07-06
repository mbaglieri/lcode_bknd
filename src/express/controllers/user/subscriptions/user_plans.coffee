Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../config/config'
mongo   = require '../../../../dbs/mongoose'
service = require '../../../../service'
utils   = require '../../../../tools/utils'

 
# Create endpoint /api/subscriptions for GET
@get_all = (req, res) ->
  perPage = 10
  page    = req.query.page || 0


  where = {}
  Promise.try ->
    if req.query.key
      where.key = { '$regex' : req.query.key, '$options' : 'i' }
    if req.query.status
      where.status =  req.query.status
    else 
      where.status =  "ACTIVE"
    if req.query.type
      where.type =  req.query.type
    else 
      where.type =  "SYSTEM"
    mongo.subscription.countDocuments where
  .then (count_qt_u_exec) ->
    @count_qt_u_exec = count_qt_u_exec

    mongo.subscription.find where
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

# Create endpoint /api/roles/:id for PUT
@buy_cart = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    if not req.body.id_subscription
      throw new Error('NOT_FOUND')
    mongo.subscription.findOne
      _id    : req.body.id_subscription
      status: "ACTIVE"
    .exec()
  .then (subsc) ->
    if subsc
      throw new Error('DUPLICATE_ITEM')
    @subsc = subsc

    mongo.user_subscription_tx.findOne
      user           : req.user
      subscription   : subsc
      status         : "PENDING"
      type           : "SYSTEM"
    .exec()
  .then (subscr_tx) ->
    if not subscr_tx
      throw new Error("NOT_FOUND")

    subscr_tx.status ="PENDING"
    subscr_tx.saveAsync()
  .then (subscr_tx) ->
    @subscr_tx = subscr_tx
    res.json
      status: 200
      data  : @subscr_tx
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

# Create endpoint /api/roles/:id for PUT
@add_cart = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    service.subscriptions.txs.add_item_to_cart(req.query.id,req.user)
  .then (subscr_tx) ->
    res.json
      status: 200
      data  : subscr_tx
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)


@remove_to_cart = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.qtask.updateMany( { 
     type: "SYSTEM", user   : req.user, status:"PENDING" },
      { status: 'DEACTIVATED' }
    )
  .then (r) ->
    res.json
      message: r + ' updated'
      status : 200
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)


# Create endpoint /api/subscriptions/:id for GET
@get_cart = (req,res) ->
  d_json = {
    status: 404
  }
  perPage = 10
  page    = req.query.page || 0
  Promise.try ->
    mongo.user_subscription_tx.find
      user   : req.user
      type: "SYSTEM"
      status: ['PENDING','ACTIVE', 'OVERQUOTA', 'LIMITED']
    .populate('subscription')
    .select(["-__v","-created_at"])
    .limit(perPage)
    .skip(perPage * page)
    .sort( created_at: 'asc')
    .exec()
  .then (subscription_item) ->
    if not subscription_item
      throw new Error("NOT_FOUND")
    @subscription_item = subscription_item

    res.send JSON.stringify subscription_item

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

