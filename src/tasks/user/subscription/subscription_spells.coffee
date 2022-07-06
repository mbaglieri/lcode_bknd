Promise           = require 'bluebird'
mongo             = require '../../../dbs/mongoose'
log               = require('../../../tools/log').create 'subscription_spells'
task_tools        = require '../../tools'

@one_time_deactivate = (qtask, worker_id) ->
  log.d "users_qtask_worker_timeout"
  q_us_exec_l = []
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
      worker   : worker
      qtask    : qtask
      status   : "COMPLETED"
    .exec()
  .then (q_u_exec_li) ->
    for q_u_exec in q_u_exec_li
      q_us_exec_l.push q_u_exec.user

    mongo.qtask_user.find
      worker   : worker
      user     : $nin: q_us_exec_l
    .limit(100)
    .exec()
  .then (qtask_users) ->
    @qtask_users = qtask_users
  #   Promise.all(_deactivate_plan user, qtask, @worker for user in qtask_users)
  # .then (worker_s) ->
    return qtask_users
  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND']
      log.i "contempled catchs"
    else
      log.e "#{err.stack}" 

_deactivate_plan = (qtask_user, qtask, worker) ->
  Promise.try ->
    log.d qtask
  #   que = new mongo.qtask_user_exec
  #     user    : qtask_user.user
  #     worker     : worker
  #     qtask_user : qtask_user
  #     environment: qtask_user.environment
  #     action     : qtask.action
  #     qtask      : qtask
  #     status     : "COMPLETED"
  #     log        ; {"interal_exc":"_deactivate_plan"}
  #   que.saveAsync()
  # .then (que_) ->
  #   qtask_user.status = 'DISCONNECTED'
    qtask_user.saveAsync()
  .then (usr) ->
    return usr