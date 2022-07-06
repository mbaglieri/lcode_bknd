Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../config/config'
mongo   = require '../../../../dbs/mongoose'
service = require '../../../../service'
utils   = require '../../../../tools/utils'
data_adapter = require '../../../../adapters'

# Create endpoint /api/subscriptions for GET
@get_all = (req, res) ->
  perPage = 10
  page    = req.query.page || 0

  where = {}
  Promise.try ->
    if req.query.key
      where.key = { '$regex' : req.query.key, '$options' : 'i' }

    if req.query.type_operation
      if req.query.type_operation is 'ALL'
        where.type_operation =  
          $in: ['ONE_TIME','RESERVATION', 'MONTHLY', 'CREDITS']
      else
        where.type_operation = 
          $in: req.query.type_operation.split ","
    else
      where.type_operation =  
        $in: ['ONE_TIME','RESERVATION', 'MONTHLY', 'CREDITS']
      
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
        $in: ['ACTIVE','INACTIVE']
    else 
      where.status =
        $in: req.query.status.split ","
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

# Create endpoint /api/subscription/:id for PUT
@add_plan = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.subscription.findOne
      key: req.body.key
    .exec()
  .then (subsc_item) ->
    if subsc_item
      throw new Error('DUPLICATE_ITEM')

    mongo.subscription req.body
    .saveAsync()
  .then (subsc) ->
    res.json
      status: 200
      data  : subsc
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

# Create endpoint /api/subscription/:id for PUT
@modify_plan = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.subscription.findOne 
      _id    : req.body.id
    .exec()
  .then (subscription) ->
    if not subscription
      throw new Error("NOT_FOUND")
    if req.body.status
      subscription.status   = req.body.status
    if req.body.price
      subscription.price    = parseFloat(req.body.price)
    if req.body.currency
      subscription.currency    = req.body.currency
    if req.body.key
      subscription.key    = req.body.key
    if req.body.description
      subscription.description    = req.body.description
    if req.body.type_operation
      subscription.type_operation    = req.body.type_operation

    subscription.saveAsync()
  .then (subscription) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

# Create endpoint /api/subscription/:id for DELETE
@delete_plan = (req,res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    mongo.subscription.findOne 
      _id    : req.query.id
    .exec()
  .then (q_u) ->
    if not q_u
      throw new Error("NOT_FOUND")

    q_u.status   = 'INACTIVE'
    q_u.saveAsync()
  .then (subscription) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
    