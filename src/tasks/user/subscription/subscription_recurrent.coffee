Promise           = require 'bluebird'
mongo             = require '../../../dbs/mongoose'
service             = require '../../../service'
log               = require('../../../tools/log').create 'subscription_task'
task_tools        = require '../../tools'
moment            = require 'moment'

@renew = (qtask, worker_id) ->
  q_us_exec_l   = []
  us_sub_exec_l = []
  Promise.try ->
    mongo.server_ownership.findOne
      status    : "ACTIVE"
      id_server : worker_id
    .exec()
  .then (worker) ->
    @worker = worker
    if not worker
      throw new Error("NOT_WORKER_ACTIVE")

    mongo.qtask_user_exec.find
      qtask    : qtask
      status   : "COMPLETED"
    .exec()
  .then (q_u_exec_li) ->
    for q_u_exec in q_u_exec_li
      q_us_exec_l.push q_u_exec.user

    mongo.user_subscription.find
      expiration_date: 
        '$lte': moment(Date.now())
      type              : 'SYSTEM'
      plan              : 'MONTHLY'
      user              : $nin: q_us_exec_l
      status            : $in: ['PENDING','ACTIVE', 'OVERQUOTA', 'LIMITED']
    .populate('tx user')
    .exec()
  .then (user_subscription) ->
    Promise.all(_renew_subsc user, qtask, @worker for user in user_subscription)
  .then (user_subscription_deactivated) ->
    for q_u_exec in user_subscription_deactivated
      us_sub_exec_l.push q_u_exec.user

    mongo.qtask_user.find
      user     : $in: us_sub_exec_l
    .exec()
  .then (qtask_users) ->
    @qtask_users = qtask_users

    Promise.all(_set_qtask_subscription_renw q_user, qtask, @worker for q_user in qtask_users)
  .then (worker_s) ->
    #TODO: ADD NOTIFICATION AARRR
    return worker_s
  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND']
      log.i "contempled catchs"
    else
      log.e "#{err.stack}" 

_set_qtask_subscription_renw = (qtask_user, qtask, worker) ->
  Promise.try ->
    # TODO: PROCESS PAYMENT
    que = new mongo.qtask_user_exec
      user       : qtask_user.user
      worker     : worker
      qtask_user : qtask_user
      environment: qtask_user.environment
      action     : qtask.action
      qtask      : qtask
      status     : "COMPLETED"
      log        ; {"interal_exc":"_subscription_monthly_renw"}
    que.saveAsync()
  .then (que_) ->
    return qtask_user

_renew_subsc = (user_subscr, qtask, worker) ->
  Promise.try ->

    mongo.user_payment_method.findOne 
      user   : user
      status : $in: ['PENDING','ACTIVE']
    .sort( is_primary: 'asc')
    .exec()
  .then (cards) ->
    if not cards or cards.length is 0
      throw new Error("NOT_FOUND")
    mongo.user_subscription_tx
      card             : user_subscr.card || cards[0]
      user_subscription: user_subscr 
      user             : user_subscr.user
      subscription     : user_subscr.subscription
      status           : "PENDING"
      currency         : user_subscr.currency
      price            : user_subscr.price
      type             : user_subscr.type
    .saveAsync()
  .then (subscr_tx) ->
    @subscr_tx = subscr_tx
    user_subscr.tx = subscr_tx
    user_subscr.status = 'PROCECING'
    user_subscr.saveAsync()
  .then (usr_subsc) ->
    service.payments.process.pay(usr_subsc, @subscr_tx )
  .then (tx_) ->
    return tx_

