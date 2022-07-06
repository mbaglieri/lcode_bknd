{ v4 } = require "uuid";

@uuidMiddleware = (req, res, next) ->
  req.id = v4();
  return next();
