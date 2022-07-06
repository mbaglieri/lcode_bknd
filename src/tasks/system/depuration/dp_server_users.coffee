Promise      = require 'bluebird'
mongo        = require '../../../dbs/mongoose'
config       = require '../../../config/config'
log          = require('../../../tools/log').create 'db_depuration_server_ownership'
task_tools   = require '../../tools'
utils        = require '../../../tools/utils'

###
reset_users_server recount users from each active instance
with that
###
@reset_users_server = () ->
  Promise.try ->
    mongo.server_ownership.find
      status: "ACTIVE"
    .exec()
  .then (workers) ->
    Promise.all(_reset_users workr for workr in workers)
  .then (worker_s) ->
    return worker_s
  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND',]
      log.i "contempled catchs"
    else
      log.e "#{err.stack}" 

_reset_users = (workr) ->
  Promise.try ->
    mongo.qtask_user.countDocuments
      worker : workr
      status : $in : [ 'CONNECTED','ACTIVE' ]
  .then (count_usrs) ->
    workr.users = count_usrs
  .then (worker_s) ->
    return worker_s

###
server_hits_analytics Find hits from the last 24 hours of each active server and storage it. 
with that
###
@server_asign_users = () ->
  Promise.try ->
    mongo.qtask_user.find
      worker: null 
    .limit(30)
    .exec()
  .then (qtask_users) ->
    @qtask_users = qtask_users
    mongo.server_ownership.findOne
      status    : "ACTIVE"
    .sort({'users':-1})
    .exec()
  .then (worker) ->
    @worker = worker
    await Promise.all( _set_user_worker user, worker for user in @qtask_users)
  .then (worker_s) ->
    @worker.users = @worker.users + @qtask_users.length
    await @worker.saveAsync()
  .then (worker_s) ->
    return worker_s
  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND',]
      log.i "contempled catchs"
    else
      log.e "#{err.stack}" 

_set_user_worker = (user, workr) ->
  Promise.try ->
    user.worker = workr
    user.saveAsync()
  .then (usr) ->
    return usr
###
users_qtask_worker_timeout Users qtask find users without activity and restrict the qtasks for that users
###
@users_qtask_worker_timeout = (qtask, worker_id) ->
  log.i "users_qtask_worker_timeout"
  Promise.try ->
    mongo.server_ownership.findOne
      status    : "ACTIVE"
      id_server : worker_id
    .exec()
  .then (worker) ->
    @worker = worker
    if not worker
      throw new Error("NOT_WORKER_ACTIVE")
    mongo.qtask_user.find
      worker   : worker
      pong_date: utils.get_from_yesterday()
      status   : $in: ['CONNECTED','ACTIVE', 'INTRO','IN_WORKOUT']
    .limit(10)
    .exec()
  .then (qtask_users) ->
    @qtask_users = qtask_users
    Promise.all(_set_qtask_inactive user, qtask, @worker for user in qtask_users)
  .then (worker_s) ->
    return worker_s
  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND']
      log.i "contempled catchs"
    else
      log.e "#{err.stack}" 

_set_qtask_inactive = (qtask_user, qtask, worker) ->
  Promise.try ->
    que = new mongo.qtask_user_exec
      user       : qtask_user.user
      worker     : worker
      qtask_user : qtask_user
      environment: qtask_user.environment
      action     : qtask.action
      qtask      : qtask
      status     : "COMPLETED"
      log        ; {"interal_exc":"_set_qtask_inactive"}
    que.saveAsync()
  .then (que_) ->
    qtask_user.status = 'DISCONNECTED'
    qtask_user.saveAsync()
  .then (usr) ->
    return usr

@depurate_user_history = (qtask, worker_id) ->
  log.i "depurate_user_history"
  Promise.try ->
    mongo.server_ownership.findOne
      status    : "ACTIVE"
      id_server : worker_id
    .exec()
  .then (worker) ->
    @worker = worker
    if not worker
      throw new Error("NOT_WORKER_ACTIVE")
    mongo.system_validation.deleteManyAsync
      created_at: utils.getFromPastDays(config.verification.clean_history)
  .then (stris) ->
    return stris
  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND']
      log.i "contempled catchs"
    else
      log.e "#{err.stack}" 

