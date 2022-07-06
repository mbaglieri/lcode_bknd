Promise      = require 'bluebird'
mongo        = require '../../../dbs/mongoose'
config       = require '../../../config/config'
log          = require('../../../tools/log').create 'setup.acl'
utils        = require '../../../tools/utils'
task_tools   = require '../../tools'
fs           = require 'fs'

@subscription = () ->
  Promise.try ->
    file = fs.readFileSync('./db/subscription/subscription.geojson', "utf8");
    @subscription_json = JSON.parse(file);
    @subscription_json1 = JSON.parse(file);
    mongo.subscription.countDocuments()
  .then (users_c) ->
    if users_c > 10
      throw new Error('SUBSCRIPTION_ADDEDED')
    Promise.all(
      await subscription_add obj_json for obj_json in @subscription_json
    )
  .then (us_r) ->
    Promise.all(
      await subscription_downgrade_upgrade obj_json for obj_json in @subscription_json1
    )
  .then (us_r) ->
    log.i "finish users"
  .catch (err) ->
    if err.message not in ['SUBSCRIPTION_ADDEDED']
      log.d "JobAddUsers:users : #{err.stack}"
    return
    
subscription_add = (obj_json) ->
  Promise.try ->
    mongo.subscription.findOne
      key: obj_json.key
    .exec()
  .then (subsc) ->
    if subsc
      throw new Error('SUBSCRIPTION_ADDEDED')
    j = obj_json
    j.downgrade = []
    j.upgrade   = []
    mongo.subscription j
    .saveAsync()
  .then (subsc_s) ->
    return subsc_s
  .catch (err) ->
    return obj_json

subscription_downgrade_upgrade = (subscription_json) ->
  Promise.try ->
    mongo.subscription.findOne
      key: subscription_json.key
    .exec()
  .then (subsc) ->

    if not subsc
      throw new Error('SUBSCRIPTION_ADDEDED')
    @subsc = subsc

    Promise.all(
      await _get_subscription obj_json for obj_json in subscription_json.downgrade
    )
  .then (downgrade_l) ->
    @downgrade_l = downgrade_l
    Promise.all(
      await _get_subscription obj_json for obj_json in subscription_json.upgrade
    )
  .then (upgrade_l) ->
    @subsc.downgrade = @downgrade_l
    @subsc.upgrade   = upgrade_l
    @subsc.saveAsync()
  .then (subsc_s) ->
    return subsc_s
  .catch (err) ->
    return subscription_json

_get_subscription = (json_) ->
  Promise.try ->
    mongo.subscription.findOne
      key: json_
    .exec()
  .then (result) ->
    return result

@spells = () ->
  Promise.try ->

    mongo.subscription_spells.countDocuments()
  .then (users_c) ->
    if users_c > 1
      throw new Error('SPELLS_ADDEDED')
    file = fs.readFileSync('./db/subscription/spells.geojson', "utf8");
    subscription_json = JSON.parse(file);
    Promise.all(
      await subscription_spells_add obj_json for obj_json in subscription_json
    )
  .then (us_r) ->
    log.i "finish users"
  .catch (err) ->
    if err.message not in ['SPELLS_ADDEDED','SUBSCRIPTION_NOT_EXIST']
      log.d "JobAddUsers:users : #{err.stack}"
    return
    
subscription_spells_add = (obj_json) ->
  Promise.try ->
    mongo.subscription.findOne
      key: obj_json.subscription
    .exec()
  .then (subscription) ->
    if not subscription
      throw new Error('SUBSCRIPTION_NOT_EXIST')
    @subscription = subscription
    mongo.subscription_spells.findOne
      key            : obj_json.key
      subscription   : subscription
    .exec()
  .then (subsc) ->
    if subsc
      throw new Error('SPELLS_ADDEDED')

    subsc = mongo.subscription_spells
      subscription   : @subscription
      key            : obj_json.key
      description    : obj_json.description
      type_operation : obj_json.type_operation
      currency       : obj_json.currency
      price          : obj_json.price
      config         : obj_json.config
    subsc.saveAsync()
  .then (subsc_s) ->
    return subsc_s
  .catch (err) ->
    return obj_json