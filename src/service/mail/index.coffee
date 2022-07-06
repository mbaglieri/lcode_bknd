Promise  = require 'bluebird'
R          = require "ramda";
{ GMail }  = require "../../tools/error.code";
mail       = require "../../tools/mail";
{env}      = require '../../config/env'
config     = require '../../config/config'
log           = require('../../tools/log').create 'email.service'
emails_trans  = require '../../i18n/acl/emails'
@test_send_email = (tpl,email) ->
  Promise.try ->
    data = 
      to: email
      subject: "test"
      template: "#{tpl}"
      data: 
        variable1:"test"
        variable2:"test"
      attachments: []
    mail.send(data)
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
    # throw new GMail({statusCode: err?.response?.status, message});

@send_verification_code = (code, email_to, name, lang="en") ->
  subject   = emails_trans["send_new_code"]["#{lang}"].subject
  title     = emails_trans["send_new_code"]["#{lang}"].title
  subtitle  = emails_trans["send_new_code"]["#{lang}"].subtitle
  subject   = subject.replace "#code", code
  title     = title.replace "#code", code
  subtitle  = subtitle.replace "#name", name
  subtitle  = subtitle.replace "#code", code

  Promise.try ->
    data          = {}
    data.to       = email_to
    data.subject  = subject
    data.template = "send_code"
    data.data     = config.mail_templates
    data.data.title    = title
    data.data.subtitle = subtitle
    data.data.code     = code
    data.attachments   = []
    data.lang          = lang
    mail.send_system(data)
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