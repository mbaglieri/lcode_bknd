Promise = require 'bluebird'
moment  = require 'moment'
config  = require '../../../../config/config'
mongo   = require '../../../../dbs/mongoose'
service = require '../../../../service'
utils   = require '../../../../tools/utils'
data_adapter = require '../../../../adapters'
Sequelize    = require 'sequelize'
Op           = Sequelize.Op

@get_cards = (req, res) ->
  perPage = 10
  page    = req.query.page || 0

  where = {}
  Promise.try ->
    if req.user
      where.user = req.user
    if not req.query.status
     where.status = 
      $in: ['PENDING','ACTIVE']
    else 
      where.status = 
        $in: req.query.status.split ","
    mongo.user_payment_method.countDocuments where
  .then (count_qt_u_exec) ->
    @count_qt_u_exec = count_qt_u_exec

    mongo.user_payment_method.find where
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

@add_card = (req,res) ->
  d_json = {
    status: 404
  }
  is_primary = req.body.is_primary || false
  Promise.try ->
    
    service.payments.process.card.add_card(req.body, is_primary, req.user)
  .then (subscr_tx) ->
    @subscr_tx = subscr_tx
    res.json
      status: 200
      data  : @subscr_tx
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@edit_card = (req,res) ->
  d_json = {
    status: 404
  }
  is_primary = req.query.is_primary || false
  Promise.try ->
    service.payments.process.card.edit_card(req.query, is_primary, req.user)
  .then (payment_method) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)
