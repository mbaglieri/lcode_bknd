controllers_        = require '../controllers'
{cachedMiddleware}  = require "../../middleware/cached.middleware";
verify              = require "../../middleware/verify.middleware";

@route_bs = (router) ->
  router.route '/system_payments'
    .get  cachedMiddleware(), controllers_.system.todo
    .delete controllers_.system.todo
 
  router.route '/system/payments/cards'
    .get     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.payment.cards.get_all
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.payment.cards.disable_from_server
  
  router.route '/system/payment/card/:id'
    .get     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.payment.cards.get_one
    .put     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.payment.cards.modify
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.payment.cards.delete

  router.route '/system/payments/subscriptions'
    .get     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.payment.subscription.get_all
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.payment.subscription.disable_from_server
  
  router.route '/system/payment/subscription/:id'
    .get     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.payment.subscription.get_one
    .put     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.payment.subscription.modify
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.payment.subscription.delete

  router.route '/system/payments/txs'
    .get     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.payment.txs.get_all
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.payment.txs.remove_from_server
    .put     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.payment.txs.copy_from_payment

  router.route '/system/payment/tx/:id'
    .get     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.payment.txs.get_one

  router.route '/system/payments/users'
    .get     controllers_.auth.isBearerAdmin, verify.verif_auth(), controllers_.system.payment.users.get_all
    .put     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.payment.users.enable_all
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.payment.users.disable_all
  
  router.route '/system/payment/user/:id'
    .get     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.payment.users.get_one
    .put     controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.payment.users.modify
    .delete  controllers_.auth.isBearerAdmin,  verify.verif_auth(), controllers_.system.payment.users.delete

  return router
 
@route_me = (router) ->

  router.route '/me/payments/cards'
    .get  controllers_.auth.isBearerAuthenticated,controllers_.user.payment.cards.get_cards
    .post  controllers_.auth.isBearerAuthenticated,controllers_.user.payment.cards.add_card
    .put  controllers_.auth.isBearerAuthenticated,controllers_.user.payment.cards.edit_card
    
  router.route '/me/payments/pay'
    .post  controllers_.auth.isBearerAuthenticated,controllers_.user.payment.subscriptions.pay

  router.route '/me/payments/txs'
    .get  controllers_.auth.isBearerAuthenticated,controllers_.user.payment.subscriptions.get_all

  router.route '/me/payment/history/:id'
    .get  controllers_.auth.isBearerAuthenticated,controllers_.user.payment.subscriptions.get_one
    .delete  controllers_.auth.isBearerAuthenticated,controllers_.user.payment.subscriptions.delete
  return router
