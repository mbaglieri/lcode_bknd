Promise       = require 'bluebird'
twilio        = require 'twilio'
log           = require('../../../tools/log').create 'SmsService'
mongo         = require '../../../dbs/mongoose'
{env}         = require '../../../config/env'
config        = require '../../../config/config'
utils         = require '../../../tools/utils'
sms_trans     = require '../../../i18n/acl/sms'

@phone_validation_twillio_acl =  phone_validation_twillio_acl = (user,system_validation) ->
  twilio = require('twilio');
  client = new twilio(env.twilio.sid, env.twilio.token);
  Promise.try ->
    phone = user.phone.split(/\s/).join('');
    phone = phone.split("-").join('');
    phone = phone.split("+").join('');
    phone = phone.split(" ").join('');
    phone = "+" + phone
    from_sms  = env.twilio.international
    if utils.startsWith phone, "1"
      from_sms =  env.twilio.usa
      
    message  = sms_trans[system_validation.cfg.translation]["#{user.lang}"].subject
    message  = message.replace "#code",system_validation.number_code

    client.messages.create({
        body: message,
        to: phone,
        from: from_sms 
    })
  .then (message) ->
    return message

@phoneValidation =  phoneValidation = (user, system_validation) ->
  if system_validation.connection_retry > 100
    throw new Error('connection_retry_limit')

  new Promise((resolve, reject) ->
    phone = user.phone.split(/\s/).join('');
    phone = phone.split("-").join('');
    phone = phone.split("+").join('');
    phone = phone.split(" ").join('');
    TeleSignSDK   = require('telesignsdk')
    # 10 secs
    client = new TeleSignSDK(env.telesign.customerId, env.telesign.apiKey, env.telesign.rest_endpoint, env.telesign.timeout)
    
    message  = sms_trans[system_validation.cfg.translation]["#{user.lang}"].subject
    message  = message.replace "#code",system_validation.number_code
    messageType = 'ARN'
    messageCallback = (error, responseBody) ->
      if error == null
        resolve(responseBody)
      else
        reject(error)
      return

    client.sms.message messageCallback, phone, message, messageType
  )

@phoneValidationTwilio =  phoneValidationTwilio = (user,system_validation) ->
  if system_validation.connection_retry > 100
    throw new Error('connection_retry_limit')
  twilio = require('twilio');
  client = new twilio(env.twilio.sid, env.twilio.token);
  Promise.try ->
    phone = user.phone.split(/\s/).join('');
    phone = phone.split("-").join('');
    phone = phone.split("+").join('');
    phone = phone.split(" ").join('');
    phone = "+" + phone
    from_sms  = env.twilio.international
    if utils.startsWith phone, "1"
      from_sms =  env.twilio.usa
      
    message  = sms_trans[system_validation.cfg.translation]["#{user.lang}"].subject
    message  = message.replace "#code",system_validation.number_code

    client.messages.create({
        body: message,
        to: phone,
        from: from_sms 
    })
  .then (message) ->
    return message
  
@phoneValidationTwilioNet =  phoneValidationTwilioNet = (user, system_validation, network) ->
  title  = sms_trans[system_validation.cfg.translation]["#{user.lang}"].subject
  title  = title.replace "#code",system_validation.number_code
  if network
    title = network.cfg.translation.en + ': Your code is:' 
  if system_validation.connection_retry > 100
    throw new Error('connection_retry_limit')

  twilio = require('twilio');
  client = new twilio(env.twilio.sid, env.twilio.token);
  Promise.try ->
    phone = user.phone.split(/\s/).join('');
    phone = phone.split("-").join('');
    phone = phone.split("+").join('');
    phone = phone.split(" ").join('');
    phone = "+" + phone
    from_sms  = env.twilio.international
    if utils.startsWith phone, "1"
      from_sms =  env.twilio.usa
    message = title + system_validation.number_code
    client.messages.create({
        body: message,
        to: phone,
        from: from_sms
    })
  .then (message) ->
    return message

  
@twilio_test =  twilio_test = (phone) ->
  title = 'Your code is:' 
  twilio = require('twilio');
  client = new twilio(env.twilio.sid, env.twilio.token);
  Promise.try ->
    phone = phone.split(/\s/).join('');
    phone = phone.split("-").join('');
    phone = phone.split("+").join('');
    phone = phone.split(" ").join('');
    phone = "+" + phone
    from_sms  = env.twilio.international
    if utils.startsWith phone, "1"
      from_sms =  env.twilio.usa
    message = title + "0068"
    sms_parms =
      body: message,
      to: phone,
      from: from_sms
    log.d sms_parms
    log.d env.twilio
    client.messages.create sms_parms
  .then (message) ->
    return message
    

