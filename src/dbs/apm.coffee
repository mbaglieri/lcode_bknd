{env} = require '../config/env'
apm = require "elastic-apm-node";
log = require('../tools/log').create 'apm'

# /** @type {import('elastic-apm-node')} */
@elasticAgent;
if(env?.apm?.serverUrl and env.apm.enabled)
  @elasticAgent = apm.start
    serviceName: env.apm.serviceName
    secretToken: env.apm.secretToken
    apiKey: env.apm.apiKey
    serverUrl: env.apm.serverUrl
  
  if(!@elasticAgent.isStarted())
    log.i("Failed to start APM server");
  else
    log.i("Registered service #{env.apm.serviceName} in APM Server: #{env.apm.serverUrl}");

