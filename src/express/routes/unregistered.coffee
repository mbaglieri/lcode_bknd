{cachedMiddleware} = require "../../middleware/cached.middleware";
quota              = require "../../middleware/quota.middleware";
{verify}           = require "../../middleware/verify.middleware";
vUnregistered      =  require "../validations/unregisted";
controllers_       = require '../controllers'
@route = (router) ->
  router.route '/sexual_orientation'
    .get   cachedMiddleware(), controllers_.unregisted.sexual_orientation

  router.route '/countries'
    .get   cachedMiddleware(), controllers_.unregisted.countries
  router.route '/country/currency'
    .get   cachedMiddleware(), controllers_.unregisted.currency_by_country
    
  router.route '/msg_balancer'
    .get  verify(vUnregistered.findSchema),cachedMiddleware(), controllers_.unregisted.msg_balancer
  router.route '/test_send_email'
    .get  controllers_.unregisted.test_send_email

  router.route '/test_quota_fix_window'
    .get  quota.fix_window(5, 3),  controllers_.unregisted.quota_data

  router.route '/test_quota_fix_window_uri'
    .get  quota.fix_window_uri(5, 3),  controllers_.unregisted.quota_data

  router.route '/test_quota_fix_window_uri1'
    .get  quota.fix_window_uri(5, 3),  controllers_.unregisted.quota_data
    
  router.route '/test_quota_slide_log'
    .get  quota.slide_log(5, 3),  controllers_.unregisted.quota_data

  router.route '/test_quota_slide_window'
    .get  quota.slide_window(5, 3),  controllers_.unregisted.quota_data

  router.route '/networks'
    .get  controllers_.user.topology.networks.get_networks

  router.route '/network'
    .get  controllers_.user.topology.networks.get_detail_network

  router.route '/network_categories'
    .get  controllers_.user.topology.networks.get_network_categories

  router.route '/ranked_networks'
    .get  controllers_.user.topology.networks.get_best_ranked_networks

  router.route '/environmentsv1'
    .get  controllers_.user.topology.environments.get_environments_v1

  router.route '/environments'
    .get  controllers_.user.topology.environments.get_environments

  router.route '/communities'
    .get  controllers_.user.topology.communities.get_communities
    
  router.route '/user_data'
    .get  controllers_.user.topology.networks.public_user_data


  router.route '/countries'
    .get  controllers_.user.topology.countries.get_all

  return router

@route_upload = (router, cdn) ->
  router.route '/test_cdn'
    .post cdn.array('file',10), controllers_.unregisted.test_cdn

  return router

@route_me = (router) ->

  router.route '/login'
    .get  controllers_.user.acl.me.login
    .post controllers_.user.acl.me.login
    .put  controllers_.user.acl.me.login_guest

  router.route '/register'
    .post controllers_.user.acl.me.new_user
    .put  controllers_.user.acl.me.postUsers

  router.route '/validate'
    .post  controllers_.user.acl.verification.resend_code
    .put  controllers_.user.acl.verification.device_verify
    .delete  controllers_.user.acl.verification.edit_device_identification
    
  router.route '/forgot'
    .post  controllers_.user.acl.verification.forgot
    .put  controllers_.user.acl.verification.forgot_code

  router.route '/refresh_token'
    .post  controllers_.user.acl.token.refreshToken
    .get   controllers_.user.acl.token.refreshToken

  return router
