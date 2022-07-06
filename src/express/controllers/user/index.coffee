Promise        = require 'bluebird'
moment         = require 'moment'
@acl           = require './acl'
@center        = require './center'
@payment       = require './payments'
@qtask         = require './qtask'
@subscription  = require './subscriptions'
@topology      = require './topology'

@todo =  (req, res) ->
  res.send
    'status': 200
