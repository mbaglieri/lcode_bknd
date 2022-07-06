Promise           = require 'bluebird'
mongo             = require '../../../dbs/mongoose'
log               = require('../../../tools/log').create 'subscription_task'
task_tools        = require '../../tools'
credit            = require './subscription_credit'
one_time          = require './subscription_one_time'
recurrent         = require './subscription_recurrent'
reservation       = require './subscription_reservation'
@batch_one_time_exec = (worker_id, data) ->
  Promise.try ->
    task_tools.qtasks.pre_execute worker_id, data
  .then (worker) ->
    
    one_time.one_time_deactivate(worker,worker_id) 
  .then (dep) ->
    task_tools.qtasks.post_execute worker_id, data
  .then (lg) ->
    log.i lg

  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND','NOT_WORKER_FOUND','QTASK_NO_DEPURATION_NEEDED']
      log.i "contempled catchs"
    else
      log.e "#{err.stack}"
  

@batch_reservation_exec = (worker_id, data) ->
  Promise.try ->
    task_tools.qtasks.pre_execute worker_id, data
  .then (worker) ->
    
    reservation.reservation_buy(worker,worker_id) 
  .then (dep) ->
    task_tools.qtasks.post_execute worker_id, data
  .then (lg) ->
    log.i lg

  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND','NOT_WORKER_FOUND','QTASK_NO_DEPURATION_NEEDED']
      log.i "contempled catchs"
    else
      log.e "#{err.stack}"
  
@batch_monthly_exec = (worker_id, data) ->
  Promise.try ->
    task_tools.qtasks.pre_execute worker_id, data
  .then (worker) ->
    
    recurrent.renew(worker,worker_id) 
  .then (dep) ->
    task_tools.qtasks.post_execute worker_id, data
  .then (lg) ->
    log.i lg

  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND','NOT_WORKER_FOUND','QTASK_NO_DEPURATION_NEEDED']
      log.i "contempled catchs"
    else
      log.e "#{err.stack}"
  
  
  
@batch_yearly_exec = (worker_id, data) ->
  Promise.try ->
    task_tools.qtasks.pre_execute worker_id, data
  .then (worker) ->
    
    recurrent.renew(worker,worker_id) 
  .then (dep) ->
    task_tools.qtasks.post_execute worker_id, data
  .then (lg) ->
    log.i lg

  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND','NOT_WORKER_FOUND','QTASK_NO_DEPURATION_NEEDED']
      log.i "contempled catchs"
    else
      log.e "#{err.stack}"

@batch_one_time_deactivate_exec = (worker_id, data) ->
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

@batch_reservation_deactivate_exec = (worker_id, data) ->
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

@batch_monthly_renewal_exec = (worker_id, data) ->
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

@batch_yearly_renewal_exec = (worker_id, data) ->
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



@limit_exceeded_exec = (worker_id, data) ->
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
  

@offers_promotions_exec = (worker_id, data) ->
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
  