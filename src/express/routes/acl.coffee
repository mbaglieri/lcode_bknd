controllers_        = require '../controllers'
{cachedMiddleware}  = require "../../middleware/cached.middleware";
verify              = require "../../middleware/verify.middleware";

@route = (router) ->
  return router

@route_bs = (router) ->
  router.route '/system/roles'
    .get     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.acl.role.get_all
    .post    controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.acl.role.post
    .put     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.acl.role.pair_requestmap

  
  router.route '/system/role/:id'
    .get     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.acl.role.get_one
    .put     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.acl.role.modify
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.acl.role.delete
    
  router.route '/system/requestmaps'
    .get     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.acl.requestmap.get_all
    .post    controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.acl.requestmap.post
  
  router.route '/system/requestmap/:id'
    .get     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.acl.requestmap.get_one
    .put     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.acl.requestmap.modify
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.acl.requestmap.delete

  router.route '/system/users'
    .get     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.acl.user.get_all
  
  router.route '/system/users/guest'
    .get     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.acl.guest.get_all
    .put     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.acl.guest.modify
    .post    controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.acl.guest.delete_all
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.acl.guest.delete

  router.route '/system/user/:id'
    .get     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.acl.user.get_one
    .put     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.acl.user.modify
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.acl.user.delete

  router.route '/system/user/:id/firebase'
    .get     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.acl.firebase.get_one
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.acl.firebase.delete

  router.route '/system/user/:id/validation'
    .get     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.acl.validation.get_all
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.acl.validation.delete

  router.route '/system/user/:id/tokens'
    .get     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.acl.token.get_all
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.acl.token.delete
    .post  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.acl.token.delete_all

  router.route '/system/user/:id/photos'
    .get     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.acl.photos.get_all
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.acl.photos.delete

  router.route '/system/user/:id/files'
    .get     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.acl.files.get_all
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.acl.files.delete

  return router

@route_me = (router) ->
  router.route '/me'
    .get  controllers_.auth.isBearerAuthenticated, controllers_.user.acl.me.get_me
    .put controllers_.auth.isBearerAuthenticated, controllers_.user.acl.me.update_profile

  router.route '/me/devices'
    .get  controllers_.auth.isBearerAuthenticated, controllers_.user.acl.devices.get_all
    .delete controllers_.auth.isBearerAuthenticated, controllers_.user.acl.devices.remove

  router.route '/me/phone_email'
    .post  controllers_.auth.isBearerAuthenticated, controllers_.user.acl.me.edit_phone_email
    .put   controllers_.auth.isBearerAuthenticated, controllers_.user.acl.me.edit_phone_email_verify

  router.route '/me/change_password'
    .post controllers_.auth.isBearerAuthenticated, controllers_.user.acl.verification.change_passwrd
    
  router.route '/req'
    .get  controllers_.auth.isBearerAuthenticated, controllers_.user.todo
    .put controllers_.auth.isBearerAuthenticated, controllers_.user.todo
  return router

@route_upload = (router, cdn) ->
  router.route '/me/kyc'
    .post controllers_.auth.isBearerAuthenticated, cdn.array('file',10), controllers_.user.todo
  return router

@route_api = (router) ->
  return router

@route_upload_api = (router, cdn) ->

  router.route '/me/photos'
    .post controllers_.auth.isBearerAuthenticated, cdn.array('file',10), controllers_.user.acl.me.upload_photos

  router.route '/me/files'
    .get  controllers_.auth.isBearerAuthenticated, controllers_.user.acl.me.get_files
    .post controllers_.auth.isBearerAuthenticated, cdn.array('file',10), controllers_.user.acl.me.upload_file
    .delete  controllers_.auth.isBearerAuthenticated, controllers_.user.acl.me.remove_file

  return router

@route_upload_admin = (router, cdn) ->
  return router
  