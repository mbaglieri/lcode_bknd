Promise   = require 'bluebird'
config    = require '../../config/config'
{env}     = require '../../config/env'
mongo     = require '../../dbs/mongoose'
log       = require('../../tools/log').create 'task.tools.qtasks'
utils     = require '../../tools/utils'

@pre_execute = (worker_id, data) ->
  log.i "RUN_JOB execute_db_job #{worker_id}"
  Promise.try ->
    get_worker worker_id
  .then (worker) ->
    if not worker
      throw new Error('NOT_WORKER_FOUND')
    @worker = worker

    get_qtask_action data.qtask_action_key, data.qtask_action
  .then (qtask_action) ->
    @qtask_action = qtask_action
    if not qtask_action
      throw new Error('QTASK_ACTION_NOT_FOUND')
    mongo.qtask.findOne
      worker    : @worker
      action    : qtask_action
      status    : $in:['IN_PROGRESS','ACTIVE']
    .populate('action')
    .exec()
  .then (dep) ->
    @dep  = dep
    if not dep
      throw new Error('QTASK_NO_DEPURATION_NEEDED')
    return @dep

@post_execute = (worker_id, data) ->
  Promise.try ->
    get_worker worker_id
  .then (worker) ->
    if not worker
      throw new Error('NOT_WORKER_FOUND')
    @worker = worker
    get_qtask_action  data.qtask_action_key, data.qtask_action
  .then (qtask_action) ->
    @qtask_action = qtask_action
    if not qtask_action
      throw new Error('QTASK_ACTION_NOT_FOUND')

    mongo.qtask.findOne
      worker    : @worker
      action    : qtask_action
      status    : 'IN_PROGRESS'
    .populate('')
    .exec()
  .then (dep) ->
    @dep  = dep
    if not dep
      throw new Error('QTASK_NO_DEPURATION_NEEDED')
    @dep.status = 'COMPLETED'
    @dep.log    = JSON.stringify {}
    @dep.saveAsync()
  .then (lg) ->
    log.i lg
  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND','NOT_WORKER_FOUND','QTASK_NO_DEPURATION_NEEDED']
      log.i "contempled catchs"
    else
      log.e "#{err.stack}"



@new_qtask = (worker_id, data) ->
  log.d "RUN_JOB new_finder #{worker_id}"
  Promise.try ->
    log.d "get_worker worker_id"
    get_worker worker_id
  .then (worker) ->
    if not worker
      throw new Error('NOT_WORKER_FOUND')
    @worker = worker

    get_qtask_action  data.qtask_action_key, data.qtask_action
  .then (qtask_action) ->
    if not qtask_action
      throw new Error('QTASK_ACTION_NOT_FOUND')
    @qtask_action = qtask_action
    find_create_job qtask_action, data, @worker
  .then (n_qtask) ->
    log.d "-------finished #{qtask_action}----- added ----"
  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND','NOT_WORKER_FOUND','SYSTEM_JOB_EXECUTED',
      'QTASK_ACTION_NOT_FOUND','QTASK_NOT_NETOWORK_NEEDS_DEPURATION']
      log.i "contempled catchs"
    else
      log.e "#{err.stack}" 
 

@find_create_job = find_create_job = (qtask_action, data, worker) ->
  log.i "find_create_job #{qtask_action} #{cfg_job}"
  cfg_job = data.qtask_action
  Promise.try ->
    upd = qtask_action.config_json.timer || 10
    #system queue
    if(cfg_job.system)
      #setup queues
      if(cfg_job.on_init_only)
        qry = 
          action    : qtask_action
          status    : $in: ['IN_PROGRESS','COMPLETED','REMOVED']
      else
        qry =
          action    : qtask_action
          status    : ['IN_PROGRESS','REMOVED']
          created_at: utils.getFromMinutes(upd)
    else
      qry =
        action    : qtask_action
        worker    : worker
        status    : ['IN_PROGRESS','REMOVED']
        created_at: utils.getFromMinutes(upd)
    mongo.qtask.findOne qry
    .exec()
  .then (dep) ->
    if dep and cfg_job.on_init_only
      throw new Error('SYSTEM_JOB_EXECUTED')
    if not dep  
      dep = new mongo.qtask
        action     : qtask_action
        worker     : worker
        status     : 'IN_PROGRESS'
        config_json: cfg_job
    dep.saveAsync()
  .then (n_qtask) ->
    return n_qtask

@modify_job = (worker, action, status, new_status, log) ->
  Promise.try ->
    mongo.qtask.findOne
      worker    : worker
      action    : action
      status    : status
    .populate('')
    .exec()
  .then (dep) ->
    @dep  = dep
    if not dep
      throw new Error('QTASK_NO_DEPURATION_NEEDED')
    @dep.status = new_status
    @dep.log    = log
    @dep.saveAsync()
  .then (lg) ->
    return lg

@get_worker = get_worker =  (id_server) ->
  log.i "get_worker #{id_server}"
  Promise.try ->
    mongo.server_ownership.findOne
      id_server: id_server
    .exec()
  .then (worker) ->
    @worker = worker
    if not @worker
      @worker = new mongo.server_ownership
        id_server: id_server
        status   : 'ACTIVE'

    if @worker.status not in [ 'ACTIVE' ]
      @worker.status = 'ACTIVE'

    @worker.saveAsync()
  .then (worker_s) ->
    if worker_s.length > 0
      return worker_s[0]
    else
      return worker_s

  .catch (err) ->
    log.e "#{err.stack}"
    return null

@get_qtask_action = get_qtask_action = (name, json_data) ->
  Promise.try ->
    mongo.qtask_action.findOne
      ac_type  : name
    .exec()
  .then (qtask_ac) ->
    @qtask_ac = qtask_ac

    if not @qtask_ac
      @qtask_ac = new mongo.qtask_action
        ac_type    : name
        is_disabled: false
        config_json: json_data
    if @qtask_ac.is_disabled
      throw new Error('ACTION_DISABLED')
    @qtask_ac.saveAsync()
  .then (worker_s) ->
    if worker_s.length > 0
      return worker_s[0]
    else
      return worker_s

  .catch (err) ->
    log.e "#{err.stack}"
    return null
###
Check the priority to take new workrs
the priroity need to be checked with the less server_ownership hitted
###
@check_my_priority = (id_server) ->
  log.i "check my priority"
  Promise.try ->
    mongo.server_ownership.find()
    .sort({hits: 1})
    .limit(1)
    .exec()
  .then ([worker]) ->
    return worker.id_server is id_server

  .catch (err) ->
    log.e "#{err.stack}"
    return false

@active_task = (worker_id, data) ->
  log.d "RUN_JOB new_finder #{worker_id}"
  Promise.try ->
    log.d "get_worker worker_id"
    get_worker worker_id
  .then (worker) ->
    if not worker
      throw new Error('NOT_WORKER_FOUND')
    @worker = worker

    get_qtask_action  data.qtask_action_key, data.qtask_action
  .then (qtask_action) ->
    if not qtask_action
      throw new Error('QTASK_ACTION_NOT_FOUND')
    @qtask_action = qtask_action
    find_create_active_job qtask_action, data, @worker
  .then (n_qtask) ->
    log.d "-------finished #{n_qtask.log}----- added ----"
  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND','NOT_WORKER_FOUND','SYSTEM_JOB_EXECUTED',
      'QTASK_ACTION_NOT_FOUND','QTASK_NOT_NETOWORK_NEEDS_DEPURATION']
      log.i "contempled catchs"
    else
      log.e "#{err.stack}" 

@find_create_active_job = find_create_active_job = (qtask_action, data, worker) ->
  log.i "find_create_active_job #{qtask_action} #{cfg_job}"
  cfg_job = data.qtask_action
  Promise.try ->
    upd = qtask_action.config_json.timer || 10
    #system queue
    if(cfg_job.system)
      #setup queues
      if(cfg_job?.on_init_only)
        qry = mongo.qtask.findOne
          action    : qtask_action
          status    : $in: ['ACTIVE','COMPLETED','REMOVED']
          updated_at: utils.getFromMinutes(upd)
      else
        qry = mongo.qtask.findOne
          action    : qtask_action
          status    : ['ACTIVE','REMOVED']
          updated_at: utils.getFromMinutes(upd)
    else
      qry = mongo.qtask.findOne
        action    : qtask_action
        worker    : worker
        status    : ['ACTIVE','REMOVED']
        updated_at: utils.getFromMinutes(upd)
        
    qry.exec()
  .then (dep) ->
    if dep and cfg_job?.on_init_only
      throw new Error('SYSTEM_JOB_EXECUTED')
    if not dep  
      dep = new mongo.qtask
        action     : qtask_action
        worker     : worker
        status     : 'ACTIVE'
        config_json: cfg_job
    dep.saveAsync()
  .then (n_qtask) ->
    return n_qtask
    
