{ ValidadeSchema } = require "../tools/error.code";
Promise            = require 'bluebird'
mongo              = require '../dbs/mongoose'
log                = require('../tools/log').create 'verify.middleware'
@verify = (schema) ->
  return (req, res, next) -> 
    validation = schema.validate req,
      abortEarly: false
      stripUnknown: true
      allowUnknown: true
    if(validation.error)
      return next(new ValidadeSchema(validation.error.details));

    Object.assign(req, validation.value);
    return next();

#todo: requestmap:?req.path
@verif_auth = () ->
  return (req, res, next) -> 
    data = await check_permisson(req.user,req.path,req.method, req.params)
    if (data)
      return next()
    else
      res.status(403).json({message: "Forbidden"});

check_permisson = (user, path, methd, parms) ->
  Promise.try ->
    for key,val of parms
      path = path.replace val, ":#{key}"
    mthods = [methd,'*']
    mongo.requestmap.find
      path : path
      methd: mthods
    .exec()
  .then (requestmaps) ->
    if not requestmaps
      throw new Error('role_not_found')

    roles_l = (role.role._id for role in user.roles)
    requestmap_l = (rq._id for rq in requestmaps)
    mongo.requestmap_role.find
      role      : $in: roles_l
      requestmap: $in: requestmap_l
    .exec()
  .then (requestmap_roles) ->
    if requestmap_roles.length < 1
      throw new Error('user_role_not_found')
    return true
  .catch (err) ->
    log.e err.stack
    return false
    
