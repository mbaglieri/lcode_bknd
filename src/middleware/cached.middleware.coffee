{ getCache, setCache } = require "../tools/cache"

# @param {number} timeExp
# @returns {import('express').RequestHandler}
 
@cachedMiddleware = (timeExp = 20) ->
  return (req, res, next) =>
    key  = req.originalUrl || req.url
    data = await getCache(key)
    if (data)
      res.json(data)
    else
      res.sendResponse = res.send
      res.send = (body) =>
          setCache(key, body, timeExp)
          res.sendResponse(body)
      return next()
