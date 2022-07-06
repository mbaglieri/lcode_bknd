controllers_        = require '../controllers'
{cachedMiddleware}  = require "../../middleware/cached.middleware";
verify              = require "../../middleware/verify.middleware";

@route = (router) ->
  return router

@route_bs = (router) ->
  # TODO: CREATE ALGORITHMS
  router.route '/system/center/notifications'
    .post    controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.center.notifications.post
    .get     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.center.notifications.get
    .put     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.center.notifications.put
    .delete  controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.center.notifications.remove
  # TODO: CREATE ALGORITHMS
  router.route '/system/center/analytics'
    .post    controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.center.analytics.post
    .get     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.center.analytics.get
    .put     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.center.analytics.put
    .delete  controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.center.analytics.remove
  # TODO: CREATE ALGORITHMS
  router.route '/system/center/relationship'
    .post    controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.center.relationship.post
    .get     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.center.relationship.get
    .put     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.center.relationship.put
    .delete  controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.center.relationship.remove
  # TODO: CREATE ALGORITHMS
  router.route '/system/center/places'
    .post    controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.center.places.post
    .get     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.center.places.get
    .put     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.center.places.put
    .delete  controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.center.places.remove

  # TODO: CREATE ALGORITHMS
  router.route '/system/center/active/users'
    .post    controllers_.auth.isBearerAdmin, verify.verif_auth(),  controllers_.system.center.active.users.post
    .get     controllers_.auth.isBearerAdmin, verify.verif_auth(),  controllers_.system.center.active.users.get
    .put     controllers_.auth.isBearerAdmin, verify.verif_auth(),  controllers_.system.center.active.users.put
    .delete  controllers_.auth.isBearerAdmin, verify.verif_auth(),  controllers_.system.center.active.users.remove
  # TODO: CREATE ALGORITHMS
  router.route '/system/center/active/qtask'
    .post    controllers_.auth.isBearerAdmin, verify.verif_auth(),  controllers_.system.center.active.qtask.post
    .get     controllers_.auth.isBearerAdmin, verify.verif_auth(),  controllers_.system.center.active.qtask.get
    .put     controllers_.auth.isBearerAdmin, verify.verif_auth(),  controllers_.system.center.active.qtask.put
    .delete  controllers_.auth.isBearerAdmin, verify.verif_auth(),  controllers_.system.center.active.qtask.remove
  # TODO: CREATE ALGORITHMS
  router.route '/system/center/active/match'
    .post    controllers_.auth.isBearerAdmin, verify.verif_auth(),  controllers_.system.center.active.match.post
    .get     controllers_.auth.isBearerAdmin, verify.verif_auth(),  controllers_.system.center.active.match.get
    .put     controllers_.auth.isBearerAdmin, verify.verif_auth(),  controllers_.system.center.active.match.put
    .delete  controllers_.auth.isBearerAdmin, verify.verif_auth(),  controllers_.system.center.active.match.remove

  return router

@route_me = (router) ->
  router.route '/me/center/notifications'
    .get     controllers_.auth.isBearerAuthenticated, controllers_.user.center.notifications.get
    .put     controllers_.auth.isBearerAuthenticated, controllers_.user.center.notifications.put
    .post    controllers_.auth.isBearerAuthenticated, controllers_.user.center.notifications.post
    .delete  controllers_.auth.isBearerAuthenticated, controllers_.user.center.notifications.remove
  router.route '/me/center/relationships'
    .get     controllers_.auth.isBearerAuthenticated, controllers_.user.center.relationship.get
    .post    controllers_.auth.isBearerAuthenticated, controllers_.user.center.relationship.post
    .put     controllers_.auth.isBearerAuthenticated, controllers_.user.center.relationship.put
    .delete  controllers_.auth.isBearerAuthenticated, controllers_.user.center.relationship.remove
  # TODO: CREATE ALGORITHMS
  router.route '/me/center/analytics'
    .get     controllers_.auth.isBearerAuthenticated, controllers_.user.center.analytics.get
    .put     controllers_.auth.isBearerAuthenticated, controllers_.user.center.analytics.put
    .delete  controllers_.auth.isBearerAuthenticated, controllers_.user.center.analytics.remove
  # TODO: CREATE ALGORITHMS 
  router.route '/me/center/places'
    .get     controllers_.auth.isBearerAuthenticated, controllers_.user.center.places.get
    .post    controllers_.auth.isBearerAuthenticated, controllers_.user.center.places.post
    .put     controllers_.auth.isBearerAuthenticated, controllers_.user.center.places.put
    .delete  controllers_.auth.isBearerAuthenticated, controllers_.user.center.places.remove
  # TODO: CREATE ALGORITHMS  
  router.route '/me/center/users'
    .get     controllers_.auth.isBearerAuthenticated, controllers_.user.center.users.get
    .post    controllers_.auth.isBearerAuthenticated, controllers_.user.center.users.post
    .put     controllers_.auth.isBearerAuthenticated, controllers_.user.center.users.put
    .delete  controllers_.auth.isBearerAuthenticated, controllers_.user.center.users.remove

  router.route '/me/center/profile'
    .get     controllers_.auth.isBearerAuthenticated, controllers_.user.center.relationship.profile
  return router

@route_upload = (router, cdn) ->
  return router

@route_api = (router) ->
  return router

@route_upload_api = (router, cdn) ->
  return router

@route_upload_admin = (router, cdn) ->
  return router
  