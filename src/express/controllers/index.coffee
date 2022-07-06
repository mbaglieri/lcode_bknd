Promise       = require 'bluebird'
moment        = require 'moment'
@auth         = require './auth'
@unregisted   = require './unregisted'
@system       = require './system'
@businesses   = require './businesses'
@merchant     = require './merchant'
@developer    = require './developer'
@user         = require './user'

@todo =  (req, res) ->
  res.send
    'status': 200
