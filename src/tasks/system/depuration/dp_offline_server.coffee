Promise      = require 'bluebird'
mongo        = require '../../../dbs/mongoose'
config       = require '../../../config/config'
log          = require('../../../tools/log').create 'db_depuration_server_ownership'
task_tools   = require '../../tools'
utils        = require '../../../tools/utils'

###
validate_server_state Find Offline Servers and activate protocol of rebalance active users queues
###
@validate_server_state = () ->
  Promise.try ->
    mongo.server_ownership.find
      status    : "ACTIVE"
      updated_at: utils.getFromPastMinutes(3)
    .exec()
  .then (workers) ->
    Promise.all(_set_offline_servers workr for workr in workers)
  .then (worker_s) ->
    return worker_s
  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND',]
      log.i "contempled catchs"
    else
      log.e "#{err.stack}" 

_set_offline_servers = (workr) ->
  Promise.try ->
    @worker = new mongo.server_ownership_log
      id_server: workr.id_server
      status   : 'SYSTEM_SHUTDOWN'
      hits     : workr.hits

    @worker.saveAsync()
  .then (workers) ->
    workr.status = 'INACTIVE'
    workr.hits   = 0
    workr.saveAsync()
  .then (worker_s) ->
    return worker_s
  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND',]
      log.i "contempled catchs"
    else
      log.e "#{err.stack}" 
