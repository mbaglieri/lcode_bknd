axios = require "axios";
log   = require('../tools/log').create 'Axios'
{ v4 } = require "uuid";

class HttpAdapter

  @instance;

  constructor: ({ baseUrl, headers = {},  params = {} }) ->
    @instance = axios.create({
      baseURL: baseUrl,
      headers: Object.assign(headers, {
          id:  v4()
      }),
      params
    });

  send:(config) ->
    return @instance.request(config);


module.exports = HttpAdapter