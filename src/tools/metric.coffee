{ register, Counter, Summary, collectDefaultMetrics} = require "prom-client"
{ StatusCodes } = require "http-status-codes"
ResponseTime    = require "response-time"
log             = require('../tools/log').create 'Tasks'

excludeUrl = [
  "/",
  "/favicon.ico",
  "/system/metrics",
  "/system/healthcheck",
  "/static/uploads/system/default.png"
]

@numOfRequests = numOfRequests = new Counter
  name      : "numOfRequests",
  help      : "Numero de requesições",
  labelNames: ["method"]

@pathsTaken = pathsTaken = new Counter
  name      : "pathsTaken",
  help      : "Caminhos percorridos na aplicação",
  labelNames: ["path"]

@responses = responses = new Summary
  name      : "responses",
  help      : "Tempo de resposta em milis",
  labelNames: ["method", "path", "statusCode"]

@responseCounters = ResponseTime (req, res, time) ->
  if(!excludeUrl.includes(req.path))
    responses.labels(req.method, req.url, res.statusCode).observe(time)

@requestCounters = (req, res, next) ->
  if(!excludeUrl.includes(req.path)) 
    numOfRequests.inc({ method: req.method })
    pathsTaken.inc({ path: req.path })
  next()

@startCollection = () ->
  collectDefaultMetrics()
  log.i "Registered service collect METRICS is ON"

@injectMetricsRoute = (app) ->
  app.get "/system/metrics", (req, res, next) -> 
    res.set("Content-Type", register.contentType)
    register.metrics()
    .then (metrics)->
      res.send(metrics)
    .catch(next)
