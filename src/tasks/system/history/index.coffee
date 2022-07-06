Promise      = require 'bluebird'
mongo        = require '../../../dbs/mongoose'
config       = require '../../../config/config'
log          = require('../../../tools/log').create 'setup_task'
utils        = require '../../../tools/utils'
task_tools   = require '../../tools'
qtask_service           = require './qtask'
qtask_user_service      = require './qtask_user'
qtask_user_exec_service = require './qtask_user_exec'
fs              = require 'fs'

@execute_job = (worker_id, data) ->
  Promise.try ->
    task_tools.qtasks.pre_execute worker_id, data
  .then (qtask) ->
    @qtask = qtask
    qtask_service.send_to_history(qtask, worker_id)
  .then (dep) ->
    qtask_user_service.send_to_history(@qtask, worker_id)
  .then (dep) ->
    qtask_user_exec_service.send_to_history(@qtask, worker_id)
  .then (dep) ->
    
    task_tools.qtasks.post_execute worker_id, data
  .then (lg) ->
    log.i lg

  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND','NOT_WORKER_FOUND','QTASK_NO_DEPURATION_NEEDED']
      log.i "contempled catchs"
    else
      log.e "#{err.stack}"
