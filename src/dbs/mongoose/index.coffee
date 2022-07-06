'use strict'
fs        = require('fs')
path      = require('path')
Promise       = require 'bluebird'
mongoose      = require 'mongoose'
session       = require('express-session')
MongoStore    = require('connect-mongo')
mongoose.Promise = Promise;
config    = require '../../config/config'
utils     = require '../../tools/utils'
@db       = db = {}
dbs       = {}
log       = require('../../tools/log').create 'mongoose'
url       = "mongodb://#{config.mongo.host}:#{config.mongo.port}/#{config.mongo.db}?directConnection=true"
Promise.promisifyAll mongoose, filter: (name) ->
  name in ['connect', 'disconnect']

@connect = connect = (next = ->) ->
  options =
    # keepAlive: 1
    minPoolSize: 5
    maxPoolSize: 10
    useNewUrlParser: true
    useUnifiedTopology: false
    serverSelectionTimeoutMS: 5000
    socketTimeoutMS: 45000
    family: 4 
    directConnection:true

  mongoose.connectAsync(url, options)


@disconnect = disconnect = ->
  mongoose.disconnectAsync

@sessions = new MongoStore({ mongoUrl: url })

  
utils.getAllFiles(__dirname).forEach (file) ->
  moduleName     = path.basename(file).split('.')[0];
  db[moduleName] = require(path.join(path.dirname(file), moduleName))
  return

Object.keys(db).forEach (modelName) ->
  if mongoose.Model.prototype.isPrototypeOf db[modelName].prototype
    Promise.promisifyAll  db[modelName]
    Promise.promisifyAll  db[modelName].prototype
  if 'associate' of db[modelName]
    db[modelName].associate db

#only for models attached on this class and not on the directory
for name, model of @
  if mongoose.Model.prototype.isPrototypeOf model.prototype
    Promise.promisifyAll model
    Promise.promisifyAll model.prototype

db.connect     = connect
db.disconnect  = disconnect
module.exports = db

# module.exports = db


