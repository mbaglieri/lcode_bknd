Promise      = require 'bluebird'
mongo        = require '../../../dbs/mongoose'
config       = require '../../../config/config'
log          = require('../../../tools/log').create 'task.history.qtask_user_exec'
task_tools   = require '../../tools'
utils        = require '../../../tools/utils'

###
qtask_history Users qtask find users without activity and restrict the qtasks for that users
###
@send_to_history = (qtask, worker_id) ->
  log.i "qtask_user_exec"
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
      status   : $in: ['COMPLETED','ERROR']
    .limit(10)
    .exec()
  .then (qtask_user_exec) ->
    @qtask_user_exec = qtask_user_exec
    Promise.all(_move_to_history qt for qt in qtask_user_exec)
  .then (worker_s) ->
  #   mongo.qtask_user_exec.deleteManyAsync
  #     worker: @worker 
  #     status: 'REMOVED'
  # .then (pst) ->
    return true
  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND']
      log.i "contempled catchs"
    else
      log.e "#{err.stack}" 

_move_to_history = (qtask_user_exec) ->
  Promise.try ->
    que = new mongo.qtask_user_exec_history
      user       : qtask_user_exec.user
      worker     : qtask_user_exec.worker
      qtask      : qtask_user_exec.qtask
      qtask_user : qtask_user_exec.qtask_user
      environment: qtask_user_exec.environment
      action     : qtask_user_exec.action
      status     : qtask_user_exec.status
      log        : qtask_user_exec.log
      config_json: qtask_user_exec.config_json
      created_at : qtask_user_exec.created_at
      updated_at : qtask_user_exec.updated_at
    que.saveAsync()
  .then (que_) ->
    qtask_user_exec.status = 'REMOVED'
    qtask_user_exec.saveAsync()
  .then (usr) ->
    return usr
