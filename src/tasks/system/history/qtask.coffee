Promise      = require 'bluebird'
mongo        = require '../../../dbs/mongoose'
config       = require '../../../config/config'
log          = require('../../../tools/log').create 'task.history.qtask'
task_tools   = require '../../tools'
utils        = require '../../../tools/utils'

###
qtask_history Users qtask find users without activity and restrict the qtasks for that users
###
@send_to_history = (qtask, worker_id) ->
  log.i "qtask_history"
  Promise.try ->
    mongo.server_ownership.findOne
      status    : "ACTIVE"
      id_server : worker_id
    .exec()
  .then (worker) ->
    @worker = worker
    if not worker
      throw new Error("NOT_WORKER_ACTIVE")
    mongo.qtask.find
      worker   : worker
      status   : $in: ['COMPLETED','ERROR', 'ACTIVE']
    .limit(10)
    .exec()
  .then (qtasks) ->
    @qtasks = qtasks
    Promise.all(_move_to_history qt for qt in qtasks)
  .then (worker_s) ->
    mongo.qtask_user.deleteManyAsync
      worker: @worker 
      status: 'REMOVED'
  .then (pst) ->
    return pst
  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND']
      log.i "contempled catchs"
    else
      log.e "#{err.stack}" 

_move_to_history = (qtask) ->
  Promise.try ->
    que = new mongo.qtask_history
      config_json: qtask.config_json
      worker     : qtask.worker
      action     : qtask.action
      status     : qtask.status
      hits       : qtask.hits
      log        : qtask.log
      created_at : qtask.created_at
      updated_at : qtask.updated_at
    que.saveAsync()
  .then (que_) ->
    qtask.status = 'REMOVED'
    qtask.saveAsync()
  .then (usr) ->
    return usr

