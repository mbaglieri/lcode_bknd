Promise  = require 'bluebird'
async    = require 'async'

request       = Promise.promisifyAll require 'request'
fs            = Promise.promisifyAll require 'fs'
mongo         = require '../../../dbs/mongoose'
config        = require '../../../config/config'
{env}         = require '../../../config/env'
log           = require('../../../tools/log').create 'FirebaseService'
jwt           = require 'jsonwebtoken'
randtoken     = require 'rand-token'
tools         = require '../../tools/utils'
task_tools    = require '../../tools'
# data_adapter  = require '../../dbs/data_adapter'

@run_job_firebase = (worker_id) ->
  log.i "RUN_JOB #{worker_id}"
  Promise.try ->
    task_tools.qtasks.get_worker worker_id
  .then (worker) =>
    if not worker
      throw new Error('NOT_WORKER_FOUND')

    @execute_hai_firebase worker
  .then (hai_results) =>
    log.i hai_results

  .catch (err) ->
    log.e "#{err.stack}"

###
Add more hai to this worker
###
@execute_hai_firebase = (worker) ->
  Promise.try ->
    log.d " execute_hai_firebase: :-)   -> #{worker}"

    mongo.fcm_queue.find
      hai_worker: null
      status    : "PENDING"
    .limit(10)
    .exec()
  .then (fcm_queue) =>
    # log.i "COUNT_HAI_TO_PROESS: #{hai_results.length}"
    Promise.all(
      for bm in fcm_queue
        await execute_individual_push(bm, worker, 1)
    )
  .then (fcm_queue) =>
    execute_verifying_messages(worker)
  .then (fcm_queue) =>
    return fcm_queue


execute_individual_push = (fcm_queue, worker,  status = 0) ->

  Promise.try ->
    fcm_queue.hai_worker = worker
    fcm_queue.status     = "VERIFYING"
    fcm_queue.saveAsync()
  .then (mg_chats) =>
    return mg_chats
