Agenda  = require 'agenda'
Promise = require 'bluebird'
config  = require '../config/config'
tasks   = require '../config/tasks'
{env}   = require '../config/env'
service = require '../service'
path    = require('path')
mongo   = require '../dbs/mongoose'
mongodb = require '../dbs/mongodb'
log     = require('../tools/log').create 'Tasks'
utils   = require '../tools/utils'
fs      = Promise.promisifyAll(require("fs"))
ip      = require 'ip'
agenda = new Agenda
  db: 
    address   : "mongodb://#{config.mongo.host}:#{config.mongo.port}/#{config.mongo.task}?directConnection=true"
    collection: "#{env.id_server}"
    options   :
      # keepAlive: 1
      minPoolSize: 5
      maxPoolSize: 10
      useNewUrlParser: true
      useUnifiedTopology: false
      serverSelectionTimeoutMS: 45000
      socketTimeoutMS: 45000
      family: 4 
      useNewUrlParser: true
      directConnection:true

Promise.promisifyAll agenda

agenda.on 'start', (job) ->
  log.i "Launched task '#{job.attrs.name}'" # len 'launched' = 'finished'

agenda.on 'success', (job) ->
  log.i "Finished task '#{job.attrs.name}'"

agenda.on 'fail', (err, job) ->
  log.e "Error during task '#{job.attrs.name}': #{err}"


@start = ->
  # Remove all previous jobs:
  if not tasks.enable_jobs
    log.i "Jobs disabled"
    return
  Promise.try ->
    mongodb.task.fix_agenda_node()
  .then (fix_worker) ->
    await agenda.jobs()
  .then (jobs) ->
    Promise.all(Promise.join(job, 'remove') for job in jobs)
  .then ->
    for name, task of utils.find_join_jsons(tasks.dir,tasks.files)
      if task.active == 1
        createTask name, (job) ->
          log.d "create_task_definition #{name}"
        await agenda.every(task.timer, name, task)

    await agenda.start()
  .then ->
    log.i "Jobs started"

  .catch (err) ->
    log.e "Failed to start: #{err}"

@stop = ->
  if not config.enable_jobs
    log.i "Jobs disabled"
    return
  Promise.try ->
    agenda.stopAsync()
  .then ->
    log.i "Stopped"

  .catch (err) ->
    log.e "Failed to stop: #{err}"

createTask = (name, f) ->
  log.d "---------------createTask------------------"
  task_json = utils.find_join_jsons(tasks.dir,tasks.files)
  if task_json[name]?.active  and task_json[name]?.active == 1
    agenda.define name, (job, next) ->
      if job?.attrs?.data?.service
        m = require(path.resolve("#{tasks.dir}#{job.attrs.data.service}"))
      # Promise.resolve(f.call(tasks[name], job)).nodeify(next)
        Promise.resolve(m[job.attrs.data.method](env.id_server, job.attrs.data)).nodeify(next)
  else
    log.d "Task: #{name} not defined"
