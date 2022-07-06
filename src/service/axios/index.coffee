Promise  = require 'bluebird'
async    = require 'async'
R = require "ramda";
{ Brapi }     = require "../../tools/error.code";
HttpAdapter   = require "../../tools/axios";
{env}         = require '../../config/env'
log           = require('../../tools/log').create 'axios.service'

http = new HttpAdapter
  baseUrl: env.brapi
@findQoute = (name) ->
  try
    { data } = await http.send
      url: "/quote/#{name.toLocaleUpperCase()}?fundamental=true",
      method: "GET"
    return data
  catch error
    defaultMessage = "Failed to get quote brapi";
    log.e error.stack
    message = R.pathOr(
      defaultMessage,
      ["response", "data", "error"],
      error,
    );
    throw new Brapi({statusCode: error?.response?.status, message});