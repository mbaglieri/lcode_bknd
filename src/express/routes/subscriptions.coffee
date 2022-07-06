controllers_        = require '../controllers'
{cachedMiddleware}  = require "../../middleware/cached.middleware";
verify              = require "../../middleware/verify.middleware";

@route_bs = (router) ->
  router.route '/system_subscriptions'
    .get  cachedMiddleware(), controllers_.system.todo
    .delete controllers_.system.todo
 
  router.route '/system/subscriptions/plans'
    .get     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.subscription.plans.get_all
    .post    controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.subscription.plans.add_plan
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.subscription.plans.delete_plan
    .put     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.subscription.plans.modify_plan
    
  router.route '/system/subscriptions/customers'
    .get     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.subscription.customers.get_customers
  
  router.route '/system/subscription/customers/:id'
    .get     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.subscription.customers.get_one
    .put     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.subscription.customers.modify
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.subscription.customers.disable

  router.route '/system/subscriptions/payments'
    .get     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.subscription.payments.get_carts
    .post     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.subscription.payments.buy_cart
    .put     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.subscription.payments.add_cart
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.subscription.payments.empty_user_cart

  # router.route '/system/subscriptions/referials'
  #   .get     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.subscription.referials.get_all
  #   .put     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.subscription.referials.enable_all
  #   .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.subscription.referials.disable_all
  
  # router.route '/system/subscription/referials/:id'
  #   .get     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.subscription.referials.get_one
  #   .put     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.subscription.referials.modify
  #   .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.subscription.referials.delete

  # router.route '/system/subscriptions/credits'
  #   .get     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.subscription.credits.get_all
  #   .put     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.subscription.credits.enable_all
  #   .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.subscription.credits.disable_all
  
  # router.route '/system/subscription/credits/:id'
  #   .get     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.subscription.credits.get_one
  #   .put     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.subscription.credits.modify
  #   .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.subscription.credits.delete


  return router

@route_me = (router) ->

  router.route '/me/subscriptions/plans'
    .get  controllers_.auth.isBearerAuthenticated,controllers_.user.subscription.plans.get_all
    
  router.route '/me/subscriptions/cart'
    .get  controllers_.auth.isBearerAuthenticated,controllers_.user.subscription.plans.get_cart
    .post  controllers_.auth.isBearerAuthenticated,controllers_.user.subscription.plans.buy_cart
    .put  controllers_.auth.isBearerAuthenticated,controllers_.user.subscription.plans.add_cart
    .delete  controllers_.auth.isBearerAuthenticated,controllers_.user.subscription.plans.remove_to_cart
    

  router.route '/me/subscriptions/txs'
    .get  controllers_.auth.isBearerAuthenticated,controllers_.user.subscription.txs.get_all
  router.route '/me/subscriptions/tx/:id'
    .get  controllers_.auth.isBearerAuthenticated,controllers_.user.subscription.txs.get_one
    .put  controllers_.auth.isBearerAuthenticated,controllers_.user.subscription.txs.modify
    .delete  controllers_.auth.isBearerAuthenticated,controllers_.user.subscription.txs.disable
    


  return router
