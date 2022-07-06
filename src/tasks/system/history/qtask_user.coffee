Promise      = require 'bluebird'
mongo        = require '../../../dbs/mongoose'
config       = require '../../../config/config'
tasks_cfg    = require '../../../config/tasks'
log          = require('../../../tools/log').create 'task.history.qtask_user'
task_tools   = require '../../tools'
utils        = require '../../../tools/utils'

###
qtask_history Users qtask find users without activity and restrict the qtasks for that users
###
@send_to_history = (qtask, worker_id) ->
  log.i "qtask_user_history"
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
      status   : $in: ['INACTIVE']
      updated_at: utils.getQueryDayBeforeXDays(tasks_cfg.days_before_user_removed)
    .limit(10)
    .exec()
  .then (qtask_users) ->
    @qtask_users = qtask_users
    Promise.all(_move_to_history qt for qt in qtask_users)
  .then (worker_s) ->
    mongo.qtask_user.deleteManyAsync
      worker: @worker 
      status: 'REMOVED'
  .then (pst) ->
    return true
  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND']
      log.i "contempled catchs"
    else
      log.e "#{err.stack}" 

_move_to_history = (qtask_user) ->
  set_removed = false
  Promise.try ->
    mongo.qtask_user_history.findOne
      user      : qtask_user.user
      created_at: utils.getQueryDayBeforeXDays(tasks_cfg.days_before_user_removed)
    .exec()
  .then (que) ->
    if not que
      set_removed = true
      que = new mongo.qtask_user_history  
        user            : qtask_user.user
        status          : qtask_user.status
        connection_retry: qtask_user.connection_retry
        enabled         : qtask_user.enabled
        worker          : qtask_user.worker
        environment     : qtask_user.environment
        config_json     : qtask_user.config_json
        created_at      : qtask_user.created_at
        updated_at      : qtask_user.updated_at
        pong_date       : qtask_user.pong_date
    que.saveAsync()
  .then (que_) ->
    if set_removed
      qtask_user.status = 'REMOVED'
    qtask_user.saveAsync()
  .then (usr) ->
    return usr
