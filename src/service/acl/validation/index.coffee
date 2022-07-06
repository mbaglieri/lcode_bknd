Promise  = require 'bluebird'
async    = require 'async'
request       = Promise.promisifyAll require 'request'
fs            = Promise.promisifyAll require 'fs'
log           = require('../../../tools/log').create 'AclValidation'
mongo         = require '../../../dbs/mongoose'
{env}         = require '../../../config/env'
config        = require '../../../config/config'
jwt           = require 'jsonwebtoken'
randtoken     = require 'rand-token'
twilio        = require 'twilio'
service_util  = require '../../../tools/utils'
data_adapter  = require '../../../adapters'
@sms          = sms  = require './sms'
@mail         = mail = require './mail'

@send = send = (user, validation_type) ->
  val_type = config?.verification[validation_type]?.type || "PHONE"
  Promise.try ->
    if not user
      throw new Error('NOT_USER')
    mongo.system_validation.findOne
      user           : user
      validation_type: val_type
      clazz          : validation_type
    .exec()
  .then (candid) ->
    if not candid
      candid = new mongo.system_validation
        user           : user
        validation_type: val_type
        number_code    : Math.floor(Math.random()*(999999-100000+1)+100000)
        cfg            : config?.verification[validation_type] || {}
        clazz          : validation_type
    else
      endDate = new Date();
      seconds = (endDate.getTime() - candid.updated_at.getTime()) / 1000;
      if seconds > 300
        candid.number_code    = Math.floor(Math.random()*(999999-100000+1)+100000)
      candid.connection_retry = candid.connection_retry + 1

    candid.saveAsync()
  .then (system_validation) ->
    @system_validation = system_validation
    _mail_or_sms(user, validation_type, system_validation)
  .then ( verification  ) ->
    return @system_validation

_mail_or_sms = (user, validation_type, system_validation) ->
  if not config?.verification[validation_type]?.type
    log.e "VALIDATION_TYPE_NOT_CONFIGURED #{validation_type}"
    throw new Error('VALIDATION_TYPE_NOT_CONFIGURED')

  if system_validation.connection_retry > config?.verification[validation_type]?.block_limit
    log.e "VALIDATION_SENT_EXEDED #{validation_type}"
    throw new Error('VALIDATION_SENT_EXEDED')
    
  if(config.verification[validation_type].type is 'PHONE')
    Promise.try ->
      sms.phone_validation_twillio_acl(user, system_validation)
    .then ( verification  ) ->
      return verification
    .catch (err) ->
      return system_validation
  else
    Promise.try ->
      mail.send_verification_code system_validation, user
    .then ( verification  ) ->
      return verification

@exists = (new_value,typo) ->
  if not config?.verification?.unique
    return
    
  Promise.try ->
    if(typo is "PHONE")
      new_value = new_value.split(/\s/).join('');
      new_value = new_value.split("-").join('');
      new_value = new_value.split("+").join('');
      q =
        phone: new_value
    else
      q =
        email: new_value
    mongo.user.findOne q
    .exec()
  .then (u_v) ->
    if(u_v)
      throw new Error("DUPLICATED_ITEM")
