# `log` exports the d (debug), v (verbose), i (info), w (warning) and e (error)
# functions.

# Each of these functions takes the form f(message, [metadata]), where message
# is the string to log and metadata an arbitrary object to attach.

winston         = require 'winston'
os              = require 'os'
moment          = require 'moment'
# mail          = require './mail/mailer'
config          = require '../config/config'
{env}           = require '../config/env'
DailyRotateFile = require 'winston-daily-rotate-file'

getIpAddresses = ->
  interfaces = os.networkInterfaces()
  addresses = []
  for k,v of interfaces
    for k2,v2 of interfaces[k]
      address = interfaces[k][k2]
      if address.family is 'IPv4'
        addresses.push(address.address)
  return addresses

class Log
  constructor: (@tag = '', {level} = {}) ->
    @logger = winston.createLogger
      exitOnError: config.logging.exitOnError
      transports: [
        new winston.transports.Console
          level    : level ? 'debug'
          colorize : true
          timestamp: true
        #   handleExceptions:config.logging.handleExceptions #commented cause limit handlers warning
        new winston.transports.File
          level    : level ? 'debug'
          timestamp: true
          # handleExceptions:config.logging.handleExceptions #commented cause limit handlers warning
          filename : config.log_directory
          name:'file.all'
        new DailyRotateFile 
          filename: config.log_directory
          dirname: config.log_dir
          timestamp: true
          maxsize: 2097152
          maxFiles: 25
      ]

      @ip = getIpAddresses()
    @logger.setMaxListeners(@logger.getMaxListeners() - 1)


  log: (level, message, meta) ->
    date_format = moment().tz(env.timezone).format 'MMMM Do YYYY, h:mm:ss a'
    message = date_format + " " + message
    if config.logging.log
      @logger.log level, @format(message), meta ? {}


  format: (message) ->
    "#{@tag}: #{message}".trim()


  create: (tag, options) ->
    new Log tag, options


  ignoreEpipe: (err) ->
    false
    #return err.code isnt 'EPIPE'


  d: (message, meta) ->
    if config.logging.log_d
      @log 'debug'  , message, meta
  v: (message, meta) ->
    if config.logging.log_v
      @log 'verbose', message, meta
  i: (message, meta) ->
    if config.logging.log_i
      @log 'info'   , message, meta
  w: (message, meta) ->
    if config.logging.log_w
      @log 'warn'   , message, meta
  e: (message, meta) ->
    @log 'error'  , message, meta
    if config.send_mail
      date_format = moment().format 'MMMM Do YYYY, h:mm:ss a'
      message = date_format + " " + message
      # mail.sendMail 'error: ' + message + " ips: " + @ip


log = new Log

module.exports = log
