Promise      = require 'bluebird'
mongo        = require '../../../dbs/mongoose'
config       = require '../../../config/config'
log          = require('../../../tools/log').create 'db_depuration_server_ownership'
task_tools   = require '../../tools'
utils        = require '../../../tools/utils'

###
server_hits_analytics Find hits from the last 24 hours of each active server and storage it. 
with that
###
@server_hits_analytics = () ->
  Promise.try ->
    mongo.server_ownership.find
      status    : "ACTIVE"
    .exec()
  .then (workers) ->
    Promise.all(_set_hits_analytics workr for workr in workers)
  .then (worker_s) ->
    mongo.server_ownership.find
      status    : "INACTIVE"
      updated_at: utils.getFromYesterday()
    .exec()
  .then (workers) ->
    Promise.all(_set_disable_analytics workr for workr in workers)
  .then (worker_s) ->
    return worker_s
  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND',]
      log.i "contempled catchs"
    else
      log.e "#{err.stack}" 

_set_hits_analytics = (workr) ->
  Promise.try ->
    mongo.server_ownership_analytics.find
      status    : "ACTIVE"
      id_server : workr.id_server
      created_at: utils.getFromPastDay()
    .exec()
  .then (workers) ->
    Promise.all(_move_worker_analytics_to_history workr_an for workr_an in workers)
  .then (workers) ->
    mongo.server_ownership_analytics.findOne
      status    : "ACTIVE"
      id_server : workr.id_server
      created_at: utils.getFromYesterday()
    .exec()
  .then (analytcs) ->
    if not analytcs
      analytcs = new mongo.server_ownership_analytics
        id_server: workr.id_server
        status   : 'ACTIVE'
        hits     : workr.hits
    else
      analytcs.hits = analytcs.hits + workr.hits

    analytcs.saveAsync()
  .then (workers) ->
    workr.hits   = 0
    workr.saveAsync()
  .then (worker_s) ->
    return worker_s
  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND',]
      log.i "contempled catchs"
    else
      log.e "#{err.stack}" 

_set_disable_analytics = (workr) ->
  Promise.try ->
    mongo.server_ownership_analytics.find
      status    : "ACTIVE"
      id_server : workr.id_server
    .exec()
  .then (workers) ->
    Promise.all(_move_worker_analytics_to_history workr_an for workr_an in workers)
  .then (workers) ->
    return workers
  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND',]
      log.i "contempled catchs"
    else
      log.e "#{err.stack}" 
      
_move_worker_analytics_to_history = (worker) ->
  Promise.try ->
    worker.status = 'HISTORY'
    worker.saveAsync()
  .then (workers) ->
    return workers
