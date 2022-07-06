'use strict'
fs        = require('fs')
path      = require('path')
Sequelize = require('sequelize')
config    = require '../../config/config'
utils     = require '../../tools/utils'
seq       = new Sequelize("#{config.sequelize.database}_replica", config.sequelize.username, config.sequelize.password, config.sequelize.options)
db        = {}
log       = require('../../tools/log').create 'sequelize'

utils.getAllFiles(__dirname).forEach (file) ->
  # model          = sequelize.import(path.join(__dirname, file))
  moduleName     = path.basename(file).split('.')[0];
  model          = require(path.join(path.dirname(file), moduleName))(seq, Sequelize.DataTypes)
  db[model.name] = model
  return

Object.keys(db).forEach (modelName) ->
  if 'associate' of db[modelName]
    db[modelName].associate db
  return

db.sequelize   = seq
db.Sequelize   = Sequelize
module.exports = db

seq.authenticate().then ((err) ->
  log.i 'DATABASE-REPLICA- Connection has been established successfully.'
  return
), (err) ->
  log.i err.stack
  log.i 'DATABASE-REPLICA- Unable to connect to the database:', err
  return
