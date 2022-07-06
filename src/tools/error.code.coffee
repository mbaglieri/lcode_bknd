Promise = require 'bluebird'
request = require 'request'
bcrypt  = require 'bcrypt'
moment  = require 'moment'
{ StatusCodes } = require "http-status-codes"

class CustomError extends Error
  constructor: (statusCode, message, code) ->
    super(message || statusCode)
    this.statusCode = statusCode
    this._code = code
    Error.captureStackTrace this, this.constructor
  


class BadRequest extends CustomError 
  constructor: (code, message) ->
    super StatusCodes.BAD_REQUEST, message, code
  


class NotFound extends CustomError 
  constructor: (code, message) ->
    super StatusCodes.NOT_FOUND, message, code
  
class InternalServer extends CustomError 
  constructor: (code, message) ->
    super StatusCodes.INTERNAL_SERVER_ERROR, message, code
  


class Brapi extends CustomError 
  constructor: (statusCode, message ) ->
    super statusCode, message, "brapi"
  


class YahooApi extends CustomError 
  constructor: (statusCode, message ) ->
    super statusCode, message, "yahoo"
  


class IexCloundApi extends CustomError 
  constructor: (statusCode, message ) ->
    super statusCode, message, "iexclound"
  


class ValidadeSchema extends CustomError
  constructor: (message) ->
    super StatusCodes.BAD_REQUEST, JSON.stringify(message)
  


module.exports =
  CustomError   : CustomError
  BadRequest    : BadRequest
  NotFound      : NotFound
  InternalServer: InternalServer
  Brapi         : Brapi
  YahooApi      : YahooApi
  IexCloundApi  : IexCloundApi
  ValidadeSchema: ValidadeSchema