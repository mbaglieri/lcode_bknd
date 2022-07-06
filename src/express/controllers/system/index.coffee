Promise       = require 'bluebird'
moment        = require 'moment'
@acl          = require './acl'
@qtask        = require './qtask'
@topology     = require './topology'
@subscription = require './subscriptions'
@payment      = require './payments'
@center       = require './center'

@todo =  (req, res) ->
  res.send
    'status': 200
