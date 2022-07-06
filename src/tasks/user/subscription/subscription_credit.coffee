Promise           = require 'bluebird'
mongo             = require '../../../dbs/mongoose'
log               = require('../../../tools/log').create 'subscription_task'
task_tools        = require '../../tools'
moment            = require 'moment'

@credit_deactivate = (qtask, worker_id) ->
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
      plan              : 'ONE_TIME'
      user              : $nin: q_us_exec_l
      status            : $in: ['PENDING','ACTIVE', 'OVERQUOTA', 'LIMITED']
    .exec()
  .then (user_subscription) ->
    Promise.all(_deactivate_subsc user, qtask, @worker for user in user_subscription)
  .then (user_subscription_deactivated) ->
    for q_u_exec in user_subscription_deactivated
      us_sub_exec_l.push q_u_exec.user

    mongo.qtask_user.find
      user     : $in: us_sub_exec_l
    .exec()
  .then (qtask_users) ->
    @qtask_users = qtask_users

    Promise.all(_set_qtask_subscription_deactivate q_user, qtask, @worker for q_user in qtask_users)
  .then (worker_s) ->
    #TODO: ADD NOTIFICATION AARRR
    return worker_s
  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND']
      log.i "contempled catchs"
    else
      log.e "#{err.stack}" 

_set_qtask_subscription_deactivate = (qtask_user, qtask, worker) ->
  Promise.try ->
    que = new mongo.qtask_user_exec
      user       : qtask_user.user
      worker     : worker
      qtask_user : qtask_user
      environment: qtask_user.environment
      action     : qtask.action
      qtask      : qtask
      status     : "COMPLETED"
      log        ; {"interal_exc":"_subscription_credit_deactivate"}
    que.saveAsync()
  .then (que_) ->
    return qtask_user

_deactivate_subsc = (user_subscr, qtask, worker) ->
  Promise.try ->
    user_subscr.status = 'DEACTIVATED'
    user_subscr.saveAsync()
  .then (usr) ->
    return usr