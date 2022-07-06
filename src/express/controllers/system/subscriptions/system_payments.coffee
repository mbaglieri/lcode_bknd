Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../config/config'
mongo   = require '../../../../dbs/mongoose'
service = require '../../../../service'
utils   = require '../../../../tools/utils'
data_adapter = require '../../../../adapters'

@get_carts = (req, res) ->
  perPage = 10
  page    = req.query.page || 0

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
          $in: ['SYSTEM','MERCHANT','COMMUNITY','ENVIRONMENT']
      else
        where.type = 
          $in: req.query.type.split ","
    else
      where.type =  'SYSTEM'
    if not req.query.status
     where.status = 
      $in: ['PENDING','ACTIVE', 'DEACTIVATED', 'REMOVED', 'OVERQUOTA', 'LIMITED']
    else 
      where.status = 
        $in: req.query.status.split ","
    mongo.user_subscription_tx.countDocuments
  .then (count_qt_u_exec) ->
    @count_qt_u_exec = count_qt_u_exec
    if req.query.action
      qury = mongo.user_subscription_tx.find
        action:
          ac_type: { '$regex' : req.query.action, '$options' : 'i' }
        status : $in: ['COMPLETED','ERROR', 'ACTIVE', 'IN_PROGRESS']
    else 
      qury = mongo.user_subscription_tx.find
        status : $in: ['COMPLETED','ERROR', 'ACTIVE', 'IN_PROGRESS']

    mongo.user_subscription_tx where
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
    if not req.body.id_user
      throw new Error('NOT_FOUND')
    mongo.user.findOne
      _id    : req.body.id_user
    .exec()
  .then (user) ->
    if user
      throw new Error('DUPLICATE_ITEM')
    @user = user
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

    _only_one req.params.id, @user
  .then (is_noly_one) ->
    mongo.user_subscription_tx.findOne
      user  : @user
      status: "PENDING"
      type  : "SYSTEM"
    .exec()
  .then (subscr_tx) ->
    if not subscr_tx
      subscr_tx = mongo.user_subscription_tx
        user           : @user
        subscription   : @subsc
        status         : "ACTIVE"
        currency       :  @subsc.currency
        price          :  @subsc.price
        type           :  @subsc.type
    subscr_tx.saveAsync()
  .then ([subscr_tx]) ->
    @subscr_tx = subscr_tx
    res.json
      status: 200
      data  : @subscr_tx
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)


_only_one = (id, user) ->
  if not config.subscription.only_one
    return 

  Promise.try ->
    q = 
      _id     : id
      user    : user
    mongo.user_subscription_tx.findOne q
    .exec()
  .then (subsc) ->
    subsc.status = "REMOVED"
    subsc.saveAsync()
  .then (subsc) ->
    return true

# Create endpoint /api/roles/:id for PUT
@add_cart = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    service.subscriptions.txs.add_item_to_cart(req.query.id,req.user)
  .then (subscr_tx) -> 
    @subscr_tx = subscr_tx
    res.json
      status: 200
      data  : @subscr_tx
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)


@empty_user_cart = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->

    if not req.body.id_user
      throw new Error('NOT_FOUND')
    mongo.user.findOne
      _id    : req.body.id_user
    .exec()
  .then (user) ->
    if user
      throw new Error('DUPLICATE_ITEM')
    @user = user
    mongo.user_subscription_tx.updateMany( { 
      type: "SYSTEM",  status:"PENDING",user:@user},
      { status: 'REMOVED' }
    )
  .then (num, raw) ->
    res.json
      message: num + ' updated'
      status : 200
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)


