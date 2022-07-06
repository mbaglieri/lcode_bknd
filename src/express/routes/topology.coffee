controllers_        = require '../controllers'
{cachedMiddleware}  = require "../../middleware/cached.middleware";
verify              = require "../../middleware/verify.middleware";

@route = (router) ->
  return router

@route_bs = (router) ->
   # router.route '/cities'
  #   .post controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.topology.cities.postCities
  #   .get  controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.topology.cities.getCities

  # router.route '/cities/:id'
  #   .get controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.topology.cities.getCity
  #   .put controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.topology.cities.putCity
  #   .delete controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.topology.cities.deleteCity

  # router.route '/network_news'
  #   .post controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.topology.network_news.postNetworkNew
  #   .get  controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.topology.network_news.getNetworkNews

  # #INIT COMMUNITIES CRUD #

  # router.route '/network_news/:id'
  #   .get controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.network_news.getNetworkNew
  #   .put controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.network_news.putNetworkNew
  #   .post controllers_.auth.isBearerAdmin, verify.verif_auth(),   controllers_.system.topology.network_news.rNetworkNew
   
  
  router.route '/system/company/transfer_ownership'
    .post    controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.topology.networks.change_owner

  router.route '/system/networks'
    .get  controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.topology.networks.owner_networks
    .post  controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.topology.networks.add

  router.route '/system/network/:id'
    .get controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.networks.get
    .put controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.networks.modify
    .delete controllers_.auth.isBearerAdmin, verify.verif_auth(),   controllers_.system.topology.networks.delete
    .post controllers_.auth.isBearerAdmin, verify.verif_auth(),   controllers_.system.topology.networks.pub_sub

  # router.route '/system/network_categories'
  #   .post controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.topology.network_categories.postNetworkCategory
  #   .get  controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.topology.network_categories.getNetworkCategories
  #   .delete controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.topology.network_categories.removeNetworkCategories

  # router.route '/system/network_category/:id'
  #   .get controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.network_categories.getNetworkCategory
  #   .put controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.network_categories.putNetworkCategory
  #   .delte controllers_.auth.isBearerAdmin, verify.verif_auth(),   controllers_.system.topology.network_categories.rNetworkCategory
  
  # router.route '/system/network_users'
  #   .post controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.topology.network_user.postNetworkUser
  #   .get  controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.topology.network_user.getNetworkUsers

  # router.route '/system/network_user/:id'
  #   .get controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.topology.network_user.getNetworkUser
  #   .put controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.topology.network_user.putNetworkUser
  #   .delete controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.topology.network_user.deleteNetworkUser
  
  router.route '/system/communities'
    .get  controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.topology.communities.by_network
    .post  controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.topology.communities.add

  router.route '/system/community/:id'
    .get controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.communities.get
    .put controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.communities.modify
    .delete controllers_.auth.isBearerAdmin, verify.verif_auth(),   controllers_.system.topology.communities.delete
    .post controllers_.auth.isBearerAdmin, verify.verif_auth(),   controllers_.system.topology.communities.pub_sub

  router.route '/system/environments'
    .get  controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.topology.environments.by_network
    .post  controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.topology.environments.add

  router.route '/system/environment/:id'
    .get controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.get
    .put controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.modify
    .delete controllers_.auth.isBearerAdmin, verify.verif_auth(),   controllers_.system.topology.environments.delete


  router.route '/system/environment/:id/analytics'
    .get controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.analytics.get
    .put controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.analytics.refresh


  router.route '/system/environment/:id/aaarrr'
    .get controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.aaarrr.get
    .put controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.aaarrr.add
    .delete controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.aaarrr.remove

  router.route '/system/environment/:id/ebitda'
    .get controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.ebitda.get
    .put controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.ebitda.add
    .delete controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.ebitda.remove
    
  router.route '/system/environment/:id/integrations'
    .get controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.integrations.get
    .put controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.integrations.add
    .delete controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.integrations.remove

  router.route '/system/environment/:id/merchant'
    .get controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.merchant.get
    .put controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.merchant.add
    .delete controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.merchant.remove

  router.route '/system/environment/:id/payments'
    .get controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.payments.get
    .put controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.payments.add
    .delete controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.payments.remove

  router.route '/system/environment/:id/promotions'
    .get controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.promotions.get
    .put controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.promotions.add
    .delete controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.promotions.remove

  router.route '/system/environment/:id/qtasks'
    .get controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.qtasks.get
    .put controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.qtasks.add

  router.route '/system/environment/:id/subscriptions'
    .get controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.subs.get
    .put controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.subs.pub_sub
    .delete controllers_.auth.isBearerAdmin, verify.verif_auth(),   controllers_.system.topology.environments.subs.block
    .post controllers_.auth.isBearerAdmin, verify.verif_auth(),   controllers_.system.topology.environments.subs.invite

  router.route '/system/environment/:id/users'
    .get controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.users.get
    .post controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.users.add
    .delete controllers_.auth.isBearerAdmin, verify.verif_auth(),    controllers_.system.topology.environments.users.remove
    


  return router

@route_upload_admin = (router, cdn) ->

  router.post   '/system/upload/networks', controllers_.auth.isBearerAdmin, cdn.array('file',10), controllers_.system.topology.networks.upload_photos
  router.post   '/system/upload/community', controllers_.auth.isBearerAdmin, cdn.array('file',10), controllers_.system.topology.communities.upload_photos
  router.post   '/system/upload/environment/:id/users', controllers_.auth.isBearerAdmin, cdn.array('file',10), controllers_.system.topology.environments.users.bulk
  return router
  
@route_me = (router) ->
  router.route '/me/environments'
    .get  controllers_.auth.isBearerAuthenticated, controllers_.user.topology.environments.get_environments_by_id
    .post controllers_.auth.isBearerAuthenticated, controllers_.user.topology.environments.post_environments
    .put controllers_.auth.isBearerAuthenticated , controllers_.user.topology.environments.pub_sub

  router.route '/me/settings/enviroment'
    .get  controllers_.auth.isBearerAuthenticated, controllers_.user.topology.environments.get_environment_by_id_parsed
  
  router.route '/me/communities'
    .get  controllers_.auth.isBearerAuthenticated, controllers_.user.topology.communities.my_communities
    .put controllers_.auth.isBearerAuthenticated, controllers_.user.topology.communities.pub_sub

  router.route '/me/networks'
    .get  controllers_.auth.isBearerAuthenticated, controllers_.user.topology.networks.my_networks
    .put controllers_.auth.isBearerAuthenticated, controllers_.user.topology.networks.pub_sub

  router.route '/me/web/networks'
    .get  controllers_.auth.isBearerAuthenticated, controllers_.user.topology.networks.get_networks
  return router

@route_upload = (router, cdn) ->
  return router

@route_api = (router) ->
  router.route '/environments'
    .get controllers_.auth.isBearerAuthenticated,  controllers_.user.topology.environments.get_environments

  router.route '/communities'
    .get  controllers_.auth.isBearerAuthenticated, controllers_.user.topology.communities.get_communities

  router.route '/networks'
    .get controllers_.auth.isBearerAuthenticated,  controllers_.user.topology.networks.get_networks

  router.route '/network_categories'
    .get  controllers_.auth.isBearerAuthenticated, controllers_.user.topology.networks.get_network_categories
  return router

@route_upload_api = (router, cdn) ->

  return router

  