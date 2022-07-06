Promise     = require 'bluebird'
mongodb     = require('mongodb');
log         = require('../../tools/log').create 'task.queries'
config      = require '../../config/config'
{env}       = require '../../config/env'
MongoClient = mongodb.MongoClient;
Collection  = mongodb.Collection;
Promise.promisifyAll(Collection.prototype);
Promise.promisifyAll(MongoClient);

#hard fix for worker, problem on reload. manually fix Attempt to unlock Agenda jobs that were stuck due server restart
#See https://github.com/agenda/agenda/issues/410
#https://github.com/Trustroots/trustroots/blob/master/config/lib/worker.js#L175-L228
@fix_agenda_node = ->
  log.i "fix_agenda_node"
  # Promise.try ->
  #   MongoClient.connectAsync( "mongodb://#{config.mongo.host}:#{config.mongo.port}/#{config.mongo.task}")
  # .then (db) ->
  #   @db = db
  #   @db(env.id_server).findAsync()
  # .then (colection) ->
  #   log.d colection
  # .catch (err) ->
  #   log.e "Failed to start: #{err.stack}"