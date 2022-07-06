Promise     = require 'bluebird'
env         = require "../config/env"
@redisClient = redisClient = require "../dbs/redis/client"

@setCache = (key, value, timeExp) -> 
  if(env?.redis?.host)
    return redisClient.set(key, value, "EX", timeExp)

# 
# 
# @param {import('ioredis').KeyType} key 
# @returns {object}
# 
@getCache = (key) ->
  if(env?.redis?.host)
    data = await redisClient.get(key)
    if(not data)
      return null
    return JSON.parse(data)

###
 * 
 * @param {import('express').Request} req 
 * @param {Array<import('ioredis').KeyType>} key 
 * @returns {Promise<Array<number>>}
###
@delCache = (req, key) ->
  if (env.redis.host)
    prossed = []
    if (req)
      prossed.push(redisClient.del(req.originalUrl || req.url))

    if(key)
      key.forEach (prefix) =>
        prossed.push(redisClient.del(prefix))

    return Promise.all(prossed)

###
 * 
 * @param {string} prefix 
 * @returns {void}
###
@delPrefixCache = (prefix) ->
  if (env.redis.host)
    keys = (await redisClient.keys("#{env.redis.prefix}#{prefix}:*")).map (key) =>
      key.replace(env.redis.prefix, "")
    if(keys.length > 0)
      return redisClient.del(keys)
    