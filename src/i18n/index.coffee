{ I18n } = require('i18n')
path     = require 'path'
elasticAgent = require "../dbs/apm"
# env    = require '../env'
config = require '../config/config'
log    = require('../tools/log').create 'i18n'

@i18n = new I18n
  locales: [
    "es",
    "en-US",
  ],
  fallbacks: {
    pt: "es",
    en: "en-US",
  },
  defaultLocale: "en-US",
  directory: path.join(__dirname, "locales"),
  directoryPermissions: "755",
  register: global,
  autoReload: config.env is "test",
  extension: ".json",
  queryParameter: "lang",
  header: "accept-language",
  logErrorFn: (msg) ->
    if(elasticAgent)
      elasticAgent.captureError(msg)
    log.e msg
