controllers_        = require '../controllers'
{cachedMiddleware}  = require "../../middleware/cached.middleware";
verify              = require "../../middleware/verify.middleware";

@route_bs = (router) ->
  router.route '/system_qtasks'
    .get  cachedMiddleware(), controllers_.system.todo
    .delete controllers_.system.todo

  router.route '/system/qtasks'
    .get     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.qtask.qtask.get_all
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.qtask.qtask.disable_from_server
  
  router.route '/system/qtask/:id'
    .get     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.qtask.qtask.get_one
    .put     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.qtask.qtask.modify
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.qtask.qtask.delete

  router.route '/system/qtasks_history'
    .get     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.qtask.qtask_history.get_all
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.qtask.qtask_history.remove_from_server
    .put     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.qtask.qtask_history.copy_from_qtask

  router.route '/system/qtask_history/:id'
    .get     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.qtask.qtask_history.get_one

  router.route '/system/qtasks_action'
    .get     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.qtask.qtask_action.get_all
    .put     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.qtask.qtask_action.enable_all
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.qtask.qtask_action.disable_all
  
  router.route '/system/qtask_action/:id'
    .get     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.qtask.qtask_action.get_one
    .put     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.qtask.qtask_action.modify
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.qtask.qtask_action.delete

  router.route '/system/qtasks_user'
    .get     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.qtask.qtask_user.get_all
    .put     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.qtask.qtask_user.send_to_new_server
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.qtask.qtask_user.disable_from_server
  
  router.route '/system/qtasks_users'
    .get     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.qtask.qtask_user.get_by_user

  router.route '/system/qtask_user/:id'
    .get     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.qtask.qtask_user.get_one
    .put     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.qtask.qtask_user.modify
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.qtask.qtask_user.delete
    
  router.route '/system/qtasks_users_history'
    .get     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.qtask.qtask_user_history.get_all
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.qtask.qtask_user_history.remove_from_server

  router.route '/system/qtask_user_history/:id'
    .get     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.qtask.qtask_user_history.get_one
  
  router.route '/system/qtasks_user_exec'
    .get     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.qtask.qtask_user_exec.get_all
    .put     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.qtask.qtask_user_exec.send_to_new_server
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.qtask.qtask_user_exec.disable_from_server
  
  router.route '/system/qtasks_users_exec'
    .get     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.qtask.qtask_user_exec.get_by_user

  router.route '/system/qtask_user_exec/:id'
    .get     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.qtask.qtask_user_exec.get_one
    .put     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.qtask.qtask_user_exec.modify
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.qtask.qtask_user_exec.delete
    
  router.route '/system/qtasks_users_exec_history'
    .get     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.qtask.qtask_user_exec_history.get_all
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.qtask.qtask_user_exec_history.disable_from_server

  router.route '/system/qtask_user_exec_history/:id'
    .get     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.qtask.qtask_user_exec_history.get_one

  return router

@route_me = (router) ->

  router.route '/me/tasks'
    .get  controllers_.auth.isBearerAuthenticated,controllers_.user.qtask.user.get_all

  router.route '/me/task/:id'
    .get  controllers_.auth.isBearerAuthenticated,controllers_.user.qtask.user.get_one
    .put  controllers_.auth.isBearerAuthenticated,controllers_.user.qtask.user.modify
    .delete  controllers_.auth.isBearerAuthenticated,controllers_.user.qtask.user.disable
  return router
