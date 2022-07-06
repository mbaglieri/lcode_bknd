Promise       = require 'bluebird'
exit          = require 'exit'
os            = require 'os'
exec          = require('child_process').exec
cluster       = require 'cluster'
app           = require '../express/server'
config        = require '../config/config'
log           = require('../tools/log').create 'App'
mongo         = require '../dbs/mongoose'
mongo_rep     = require '../dbs/mongoose/replica'
agenda_sver   = require './agenda.server'
sockets_sve   = require './socket.server'
sequelize_sve = require './sequelize.server'

getIpAddresses = ->
  interfaces = os.networkInterfaces()
  addresses = []
  for k,v of interfaces
    for k2,v2 of interfaces[k]
      address = interfaces[k][k2]
      if address.family is 'IPv4'
        addresses.push(address.address)
  return addresses


startAll = ->
  if cluster.isMaster
    worker = cluster.fork().process
    cluster.on 'exit',(worker) ->
      log.e 'worker %s died. restart...', worker.process.pid
      log.e "Worker died, IP was #{JSON.stringify getIpAddresses()}"
      cluster.fork()

      if config.send_mail
        # mailTail()
        log.i 'test'

  else
    log.i "runing  instance"
    Promise.try ->
      log.i "Connecting to MongoDB"
      mongo.connect()
    .then ->
      sequelize_sve.start()
    .then ->
      agenda_sver.start()
    .then ->
      log.i "Starting express application"
      app.start()
    .then ->
      sockets_sve.start()
    .then ->
      log.i "Startup successful"

    .catch (err) ->
      log.e "Error starting server, #{err.stack}"

stopAll = ->
  Promise.try ->
    log.d "Disconnecting from MongoDB"
    mongo.disconnect()
  .then ->
    mongo_rep.disconnect()
  .then ->
    log.d "Stopping express application"
    app.stop()
  .then ->
    sockets_sve.stop()
  .then ->
    agenda_sver.stop()
  .then ->
    log.d "Shutdown successful"

  .catch (err) ->
    log.d err.stack
    log.d "Shutdown error #{err}"

  .finally ->
    exit()

process.on 'SIGTERM', stopAll
process.on 'SIGINT' , stopAll

process.on 'warning', (err) -> 
  log.e(err.stack)
#Agregar ENVIO DE MAIL CUANDO HAY EXEPCION
process.on 'uncaughtException', (err) ->
  log.d "FATAL ERROR! Uncaught exception: #{err.message}"
  log.d "FATAL ERROR! Uncaught exception: #{err.stack}"
  process.exit(1)

startAll()