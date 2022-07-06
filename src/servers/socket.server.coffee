express = require 'express'
ws      = require 'ws'
config  = require '../config/config'
url     = require 'url'
https   = require 'https'
fs      = require 'fs'
express = require 'express'
Promise = require 'bluebird'
bcast   = require '../dbs/redis/broadcast'
log     = require('../tools/log').create 'Sockets'
user    = require '../sockets/user'
realIp  = require '../sockets/socket.middleware'
servers = []

@start = ->
  log.i "started:ws_server"
  for sk in config.sockets
    servers.push new ws.WebSocketServer sk
  # servers.push new ws.WebSocketServer config.sockets[0]
  # servers.push new ws.WebSocketServer config.sockets[1]
  # for sk in config.sockets
  #   servers.push sk
  if config.ssl.wss_enabled
    options =
      key : fs.readFileSync(config.ssl.privkey)
      cert: fs.readFileSync(config.ssl.cert)
      ca  : fs.readFileSync(config.ssl.ca)

    Application = express()
    Application.use (req, res, next) ->
      res.header('Access-Control-Allow-Origin', '*')
      res.header('Access-Control-Allow-Methods', 'PUT, GET, POST, DELETE, OPTIONS')
      res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
      next();
    Application.use realIp
    Application.get '/', (req, res, next) ->
      res.send {'status':200}

    Server = https.createServer(options, Application).listen(config.ssl.wss)

    WebSocketServer = new ws.WebSocketServer
      server               : Server
      autoAcceptConnections: true

    servers.push WebSocketServer

  for server in servers
    server.on 'connection', (ws) ->
      req = ws.upgradeReq
      log.d req.url
      {pathname} = url.parse req.url, true
      socket.on 'error', (reason, code) ->
        log.d "socket error: reason  #{reason} , code  #{code}"
 
      Handler = switch pathname
        when '/user'   then user.UserHandler
        when '/guest'     then user.UserHandler
        when '/employee' then user.UserHandler
        when '/analytics' then user.UserHandler
        when '/operator' then user.UserHandler
        when '/admin' then user.UserHandler
        else user.UserHandler

      if Handler?
        handler = new Handler(socket, req)

      else
        console.error 'No handler for', req.url
        socket.close(4000,"4000")
      return

  log.i "Started"


@stop = ->
  log.i "Stopping sockets"
  return Promise.all(
    for server in servers
      server.clients.forEach (sk) -> 
        sk.close();
        process.nextTick () ->
          if([socket.OPEN, socket.CLOSING].includes(socket.readyState))
            socket.terminate()
      if servers?
        server.close() 
      else
        log.i "stopServer() called, but server is not running"
  )
