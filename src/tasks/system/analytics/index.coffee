Promise      = require 'bluebird'
mongo        = require '../../../dbs/mongoose'
config       = require '../../../config/config'
log          = require('../../../tools/log').create 'analytics_task'
task_tools   = require '../../tools'
utils        = require '../../../tools/utils'
@system_save_history = (worker_id, data) ->
  Promise.try ->
    task_tools.qtasks.pre_execute worker_id, data
  .then (worker) ->
    
    task_tools.qtasks.post_execute worker_id, data
  .then (lg) ->
    log.i lg

  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND','NOT_WORKER_FOUND','QTASK_NO_DEPURATION_NEEDED']
      log.i "contempled catchs"
    else
      log.e "#{err.stack}"

@ml_exec = (worker_id, data) ->
  Promise.try ->
    task_tools.qtasks.pre_execute worker_id, data
  .then (worker) ->
    
    task_tools.qtasks.post_execute worker_id, data
  .then (lg) ->
    log.i lg

  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND','NOT_WORKER_FOUND','QTASK_NO_DEPURATION_NEEDED']
      log.i "contempled catchs"
    else
      log.e "#{err.stack}"
  