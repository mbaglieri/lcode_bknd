Promise             = require 'bluebird'
mongo               = require '../../../dbs/mongoose'
config              = require '../../../config/config'
log                 = require('../../../tools/log').create 'db_depuration'
task_tools          = require '../../tools'
dp_server_off       = require './dp_offline_server'
dp_server_analytics = require './dp_server_analytics'
dp_server_users     = require './dp_server_users'

@execute_job = (worker_id, data) ->
  Promise.try ->
    task_tools.qtasks.pre_execute worker_id, data
  .then (worker) ->
    dp_server_off.validate_server_state() 
  .then (dep) ->
    dp_server_analytics.server_hits_analytics() 
  .then (dep) ->
    task_tools.qtasks.post_execute worker_id, data
  .then (lg) ->
    log.i lg

  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND','NOT_WORKER_FOUND','QTASK_NO_DEPURATION_NEEDED']
      log.i "contempled catchs"
    else
      log.e "#{err.stack}"
  

@users_server_job_execute = (worker_id, data) ->
  Promise.try ->
    task_tools.qtasks.pre_execute worker_id, data
  .then (qtask) ->
    @qtask = qtask
    await dp_server_users.reset_users_server() 
  .then (dep) ->
    await dp_server_users.server_asign_users() 
  .then (dep) ->
    await dp_server_users.users_qtask_worker_timeout(@qtask,worker_id) 
  .then (dep) ->
    await task_tools.qtasks.post_execute worker_id, data
  .then (lg) ->
    log.i lg

  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND','NOT_WORKER_FOUND','QTASK_NO_DEPURATION_NEEDED']
      log.i "contempled catchs"
    else
      log.e "#{err.stack}"
  

@depurate_user_history_execute = (worker_id, data) ->
  Promise.try ->
    task_tools.qtasks.pre_execute worker_id, data
  .then (qtask) ->
    @qtask = qtask
    dp_server_users.depurate_user_history(@qtask,worker_id) 
  .then (dep) ->
    task_tools.qtasks.post_execute worker_id, data
  .then (lg) ->
    log.i lg

  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND','NOT_WORKER_FOUND','QTASK_NO_DEPURATION_NEEDED']
      log.i "contempled catchs"
    else
      log.e "#{err.stack}"