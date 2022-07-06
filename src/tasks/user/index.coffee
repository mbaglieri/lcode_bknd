Promise      = require 'bluebird'
mongo        = require '../../dbs/mongoose'
config       = require '../../config/config'
utils        = require '../../tools/utils'
log          = require('../../tools/log').create 'user_tasks'
task_tools   = require '../tools'
 

#each 1 hour ( means 24 networks per node)
@job_execute_depuration = (worker_id, data) ->
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
      
@job_execute_migration_qtask_users = (worker_id, data) ->
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
