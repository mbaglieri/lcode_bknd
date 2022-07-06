{env}      = require "../config/env"
nodemailer = require "nodemailer";
{ google } = require "googleapis";
ejs        = require "ejs";
path       = require "path";
log        = require('../tools/log').create 'Mail'
Promise    = require 'bluebird'
_transport = () ->
  if(env.email.type is not "OAuth2")
    return nodemailer.createTransport
      host: env.email.host
      port: env.email.port
      auth:
        user: env.email.notificator
        pass: env.email.pass 
      secure: env.email.secure
  else
    oauth2Client = new google.auth.OAuth2(
      env.email.OAuth2.clientId,
      env.email.OAuth2.clientSecret,
      env.email.OAuth2.redirectUri
    );
 
    oauth2Client.setCredentials
      refresh_token: env.email.OAuth2.refreshToken
    accessToken = oauth2Client.getAccessToken();

    return nodemailer.createTransport
      service: "gmail"
      auth:
        type: "OAuth2"
        user: env.email.notificator
        clientId: env.email.OAuth2.clientId
        clientSecret: env.email.OAuth2.clientSecret
        refreshToken: env.email.OAuth2.refreshToken
        accessToken: accessToken

@send = ({to, subject, template, data = {}, attachments}) -> 
  return new Promise (resolve, reject) ->
    ejs.renderFile path.join(__dirname, "../views/mail/generic/multimail_#{template}.ejs"), data, (err, html) =>
      if(err)
        reject(new Error(err));

      _transport().sendMail({
        to,
        from: env.email.notificator,
        subject,
        html,
        attachments
      }).then(resolve).catch (err) ->
        reject(new Error(err));

@send_system = ({to, subject, template, data = {}, attachments, lang = 'en'}) -> 
  return new Promise (resolve, reject) ->
    ejs.renderFile path.join(__dirname, "../views/mail/system/#{lang}/#{template}.ejs"), data, (err, html) =>
      if(err)
        reject(new Error(err));

      _transport().sendMail({
        to,
        from: env.email.notificator,
        subject,
        html,
        attachments
      }).then(resolve).catch (err) ->
        reject(new Error(err));
