service = require '../../../../service'
utils   = require '../../../../tools/utils'
adapter = require '../../../../adapters'
Promise = require 'bluebird'

@get = (req, res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    adapter.api.user.get_context(req)
  .then (context) ->
    @context = context
    service.center.relationship.getv1(req.query, context)
  .then (calif_ls) ->
    @calif_ls = calif_ls
    service.center.relationship.analytics(req.query, @context)
  .then (analytics) ->
    dta = 
      last_recomendations: @calif_ls
      analytics          : analytics
    res.json dta
  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@post = (req, res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    adapter.api.user.get_context(req)
  .then (context) ->
    service.center.relationship.add(req.body, context)
  .then (type_event) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@put = (req, res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    adapter.api.user.get_context(req)
  .then (context) ->
    service.center.general.change_tx_state(req.query.id,  req.query.status || 'READED', context.qtask_user.user) 
  .then (type_event) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)

@remove = (req, res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    adapter.api.user.get_context(req)
  .then (context) ->
    service.center.general.change_tx_state(req.query.id, 'READED', context.qtask_user.user)
  .then (type_event) ->
    res.json
      status : 200

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)


@profile = (req, res) ->
  d_json = {
    status: 404
  }
  Promise.try ->
    adapter.api.user.get_context(req)
  .then (context) ->
    service.center.relationship.profile(req.query, context)
  .then (calif_ls) ->
    @calif_ls = calif_ls

    res.send JSON.stringify @calif_ls

  .catch (err) ->
    d_json = utils.errors_mod(err,'acl')
    res.status(d_json.status).json(d_json)