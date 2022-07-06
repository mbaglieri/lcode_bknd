@changeLocale = (req, res, next) ->
  locale = req.query.lang || req.header("accept-language");
  if(locale)
    console.log locale
    # req.setLocale(locale)
    # res.setLocale(locale)
  next();
