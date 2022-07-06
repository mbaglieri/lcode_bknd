@unregistered = require './unregistered'
@acl          = require './acl'
@payment      = require './payment'
@qtask        = require './qtask'
@center       = require './center'
@topology     = require './topology'
@subscriptions= require './subscriptions'

@populate_router_me = (router, cdn) ->
  router = @unregistered.route_me(router)
  router = @acl.route_me(router, cdn)
  router = @subscriptions.route_me(router)
  router = @payment.route_me(router)
  router = @topology.route_me(router)
  router = @center.route_me(router)
  router = @qtask.route_me(router, cdn)
  return router

@populate_router_api = (router, cdn) ->
  router = @acl.route_upload_api(router, cdn)
  router = @topology.route_upload_api(router, cdn)
  router = @acl.route_api(router, cdn)
  router = @topology.route_api(router, cdn)
  return router


@populate_router_admin = (router, cdn) ->
  router = @acl.route_bs(router)
  router = @qtask.route_bs(router)
  router = @center.route_bs(router)
  router = @subscriptions.route_bs(router)
  router = @topology.route_bs(router)
  router = @acl.route_upload_admin(router, cdn)
  router = @topology.route_upload_admin(router, cdn)
  return router

@populate_router_static = (router_static, cdn) ->
  router_static = @unregistered.route(router_static)
  router_static = @unregistered.route_upload(router_static, cdn)
  router_static = @topology.route_upload(router_static, cdn)
  return router_static


@populate_router_acl = (router_static) ->
  router_static = @unregistered.route_me(router_static)
  return router_static