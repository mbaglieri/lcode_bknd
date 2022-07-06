{ redisClient }      = require "../tools/cache"
{ ValidadeSchema } = require "../tools/error.code"
Promise            = require 'bluebird'
mongo              = require '../dbs/mongoose'
log                = require('../tools/log').create 'quota.middleware'
utils              = require '../tools/utils'
fs                 = require 'fs'
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

    roles_l = (role for role in user.roles)
    requestmap_l = (rq for rq in requestmaps)
    mongo.requestmap_role.find
      where:
        role      : $in: roles_l
        requestmap: $in: requestmap_l
  .then (requestmap_roles) ->
    if requestmap_roles.length < 1
      throw new Error('user_role_not_found')
    return true
  .catch (err) ->
    return false
    
@fix_window_uri =  (windowSec, limit) ->
  return (req, res, next) ->
    path   = req.path
    methd  = req.method
    parms  = req.params
    for key,val of parms
      path = path.replace val, ":#{key}"
    try
      ip    = utils.get_ip_req(req)
      w_uri = "fw_#{ip}_#{path}_#{methd}"
      visit = await redisClient.redisClient.incr(w_uri);
      if (visit is 1) 
        await redisClient.redisClient.expire(w_uri, windowSec)
      if (visit > limit)
        time = Date.now().toString().slice(8, 13);
        return res.status(429).json({ time, error: 'Too Many Requests' })
      return next()
    catch e
      return res.status(429).json({ time, error: 'Too Many Requests' })

@fix_window =  (windowSec, limit) ->
  return (req, res, next) ->
    try
      ip    = utils.get_ip_req(req)
      visit = await redisClient.redisClient.incr("fw_#{ip}");
      if (visit is 1) 
        await redisClient.redisClient.expire("fw_#{ip}", windowSec)
      if (visit > limit)
        time = Date.now().toString().slice(8, 13);
        return res.status(429).json({ time, error: 'Too Many Requests' })
      return next()
    catch e
      return res.status(429).json({ time, error: 'Too Many Requests' })
    

@slide_log =  (windowSec, limit) ->
  windowMs = windowSec * 1000;
  return (req, res, next) ->
    try
      ip    = utils.get_ip_req(req)
      scr   = fs.readFileSync('./db/redis/slide_log.lua', {encoding: 'utf8'})
      curStamp = Date.now();
      result = await redisClient.redisClient.eval(scr.toString(), 1, ip, limit, curStamp, windowMs)

      if (result is 1) 
        return next()
      time = Date.now().toString().slice(8, 13)
      return res.status(429).json({ time, error: 'Too Many Requests' })
    catch e
      log.e e
      return res.status(429).json({ time, error: 'Too Many Requests' })
    
   

@slide_window =  (windowSec, limit) ->
  windowMs = windowSec * 1000;
  return (req, res, next) ->
    try
      ip    = utils.get_ip_req(req)
      scr   = fs.readFileSync('./db/redis/slide_window.lua', {encoding: 'utf8'})
      curStamp = Date.now();
      result = await redisClient.redisClient.eval(scr.toString(), 1, ip, limit, curStamp, windowMs)

      if (result is 1) 
        return next()
      time = Date.now().toString().slice(8, 13)
      return res.status(429).json({ time, error: 'Too Many Requests' })
    catch e
      log.e e.stack
      return res.status(429).json({ time, error: 'Too Many Requests' })
