config        = require '../config/config'
models        = require '../dbs/sequelize'
models_rep    = require '../dbs/sequelize/replica'

@start = start = ->
  if not config.sequelize.is_active
    return 
  Promise.try ->
    l
    log.d "Connecting to SQLORM"
    models.sequelize.sync()
  .then ->
    models_rep.sequelize.sync()
  .then ->
    log.i "Connecting to completed SQLORM"

  .catch (err) ->
    log.e "Error starting server, #{err.stack}"
