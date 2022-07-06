Redis  = require 'ioredis'
{env}    = require '../../config/env'
log      = require('../../tools/log').create 'Redis'

# /** @type {import('ioredis').Redis} */
@redisClient

if(env?.redis?.host)
  @redisClient = new Redis
    host: env.redis.host,
    port: env.redis.port,
    keyPrefix: env.redis.prefix
  log.i("Registered service REDIS is ON")
else
  log.i("Not registered service REDIS")

