Promise      = require 'bluebird'
mongo        = require '../../../dbs/mongoose'
config       = require '../../../config/config'
log          = require('../../../tools/log').create 'setup_task'
utils        = require '../../../tools/utils'
task_tools   = require '../../tools'
sv_countries = require './countries'
sv_net       = require './networks'
sv_acl       = require './acl'
sv_subscript = require './subscription'
fs           = require 'fs'

@execute_db_job = (worker_id, data) ->
  Promise.try ->
    task_tools.qtasks.pre_execute worker_id, data
  .then (worker) ->
    sv_countries.countries()
  .then (dep) ->
    sv_countries.currencies()
  .then (dep) ->
    sv_net.categories()
  .then (dep) ->
    sv_net.networks()
  .then (dep) ->
    sv_net.communities()
  .then (dep) ->
    sv_net.environments()
  .then (dep) ->
    sv_acl.users()
  .then (dep) ->
    sv_acl.roles()
  .then (dep) ->
    sv_acl.user_role()
  .then (dep) ->
    sv_acl.requestmaps()
  .then (dep) ->
    sv_acl.requestmap_role()
  .then (dep) ->
    sv_subscript.subscription()
  .then (dep) ->
    sv_subscript.spells()
  .then (dep) ->
    
    task_tools.qtasks.post_execute worker_id, data
  .then (lg) ->
    log.i lg

  .catch (err) ->
    if err.message in ['NOT_CONFIG_FOUND','NOT_WORKER_FOUND','QTASK_NO_DEPURATION_NEEDED']
      log.i "contempled catchs"
    else
      log.e "#{err.stack}"
