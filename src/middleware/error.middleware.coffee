{
    BadRequest,
    Brapi,
    InternalServer,
    NotFound,
    ValidadeSchema
} = require "../tools/error.code"
{ StatusCodes } = require "http-status-codes"
# import elasticAgent from "../apm"
config = require '../config/config'
log    = require('../tools/log').create 'i18n'
errorsConfigs = [
  { class: NotFound, code: null, i18n: "NotFound" },
  { class: InternalServer, code: "Category", i18n: "InternalServer.Category" },
  { class: InternalServer, code: "Broker", i18n: "InternalServer.Broker" },
  { class: BadRequest, code: "Transaction.qnt", i18n: "Transaction.Qnt" },
  { class: Error, code: "ER_DUP_ENTRY", i18n: "BadRequest.Duplicate" },
  { class: ValidadeSchema, code: "any.required", i18n: "ValidadeSchema.required" },
  { class: ValidadeSchema, code: "any.only", i18n: "ValidadeSchema.only" },
  { class: ValidadeSchema, code: "string.min", i18n: "ValidadeSchema.min" },
  { class: ValidadeSchema, code: "string.email", i18n: "ValidadeSchema.email" },
  { class: ValidadeSchema, code: "async.exist", i18n: "ValidadeSchema.async" },
]

_getErrorConfig = (error) -> 
  errorsConfigs.find (errorConfig) -> 
    if (error instanceof NotFound && error instanceof errorConfig.class)
      return errorConfig
    else 
      if (error instanceof errorConfig.class && (error._code is errorConfig.code || error.code is errorConfig.code)) 
        return errorConfig

_loadErrorMessage = (req, error) -> 
  if (error instanceof ValidadeSchema)
    error.message = JSON.stringify(
      JSON.parse(error.message).map element ->
        e       = error
        e._code = element.type
        errorConfig = _getErrorConfig(e)
        if (errorConfig)
          element.message = req.__(errorConfig.i18n, {
            name: element.context.key,
            limit: element.context.limit,
            value: element.context.value,
            valids: element.context.valids,
            code: error._code
          })
          return element
        return element
    )
  else
    errorConfig = _getErrorConfig(error)
    if (errorConfig)
      errorWithMessage = error
      data             = {}
      if(error.code is "ER_DUP_ENTRY")
        data.dup = error.sqlMessage.split(/'(.*?)'/)[1]
      errorWithMessage.message = req.__(errorConfig.i18n, {
        params: req.params,
        query: req.query,
        headers: req.headers,
        body: req.body,
        code: error._code,
        duplicateValue: data.dup
      })

@errorHandler = (error, req, res, next) ->
  log.w("#{req.id} #{error.message}")
  _loadErrorMessage(req, error)
  if error.constructor is ValidadeSchema
    response = JSON.parse(error.message).map (i) ->
      dat = 
        name   : i.context.key
        message: i.message
      return dat
    res.status(error.statusCode).json(response)
  else if error.constructor is NotFound
    res.status(StatusCodes.NOT_FOUND).json([{ message: error.message }])
  else if error.constructor is Brapi
    res.status(error.statusCode || 400).json([{ message: error.message }])
  else if error.constructor is BadRequest
    res.status(StatusCodes.BAD_REQUEST).json([{ message: error.message }])
  else
    if(error.code)
      message = error.message || error.sqlMessage
      if(config.env is not "development")
        message = "Contact the developer and give me your ID #{req.id}, we're sorry this happened 😞"
      res.status(StatusCodes.NOT_ACCEPTABLE).json([{ message }])
    else
      if(elasticAgent)
        elasticAgent.captureError error,() -> 
          log.e("ID - #{req.id}, Send APM: #{error.message}")
      else
        log.e("ID - #{req.id}, Error: #{error.message}")
      message = "Contact the developer and give me your ID #{req.id}, we're sorry this happened 😞"
      res.status(StatusCodes.INTERNAL_SERVER_ERROR).json([{ message }])