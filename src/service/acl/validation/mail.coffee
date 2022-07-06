Promise       = require 'bluebird'
tool_mail     = require "../../../tools/mail";
config        = require '../../../config/config'
log           = require('../../../tools/log').create 'email.service'
emails_trans  = require '../../../i18n/acl/emails'

@send_verification_code = send_verification_code =  (system_validation, user) ->
  subject   = emails_trans[system_validation.cfg.translation]["#{user.lang}"].subject
  title     = emails_trans[system_validation.cfg.translation]["#{user.lang}"].title
  subtitle  = emails_trans[system_validation.cfg.translation]["#{user.lang}"].subtitle
  subject   = subject.replace  "#code", system_validation.number_code
  title     = title.replace    "#code", system_validation.number_code
  subtitle  = subtitle.replace "#code", system_validation.number_code
  subject   = subject.replace  "#code", system_validation.number_code
  title     = title.replace    "#name", system_validation.first_name
  subtitle  = subtitle.replace "#name", system_validation.first_name
  subtitle  = subtitle.replace "#name", user.first_name

  Promise.try ->
    data               = {}
    data.to            = user.email
    data.subject       = subject
    data.template      = system_validation.cfg.template
    data.data          = config.mail_templates
    data.data.title    = title
    data.data.subtitle = subtitle
    data.data.code     = system_validation.number_code
    data.attachments   = []
    data.lang          = user.lang
    tool_mail.send_system(data)
  .then ->
    log.i "email sent"
  .catch (err) ->
    defaultMessage = "Failed to get quote brapi";
    log.e err.stack
    message = R.pathOr(
      defaultMessage,
      ["response", "data", "error"],
      err,
    );