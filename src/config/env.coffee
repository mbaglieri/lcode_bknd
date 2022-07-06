path = require('path')
require('dotenv').config({path: path.resolve(__dirname, '../../.env') })
config = require './config'
uri  = process.env.SERVER_URL || "http://localhost:3000"
@env =
  country    : process.env.COUNTRY || "Argentina"
  env        : process.env.NODE_ENV || "development"
  network    : process.env.NETWORK ||"low_code_stage"
  community  : process.env.COMMUNITY ||"low_code_stage_hall"
  environment: process.env.ENVIRONMENT ||"low_code_stage_hall_guest"
  timezone   : process.env.TIME_ZONE || "America/Fortaleza"
  brapi      : process.env.BRAPI_URL || config.server[config.env].url
  yahoo      : process.env.YAHOO_FINANCE_URL
  yahooKey   : process.env.YAHOO_FINANCE_KEY
  apiUrl     : process.env.API_URL
  apiKey     : process.env.API_KEY
  server:
    url   :uri 
    active: process.env.SERVER_ACTIVE is true
    port  : parseInt(process.env.SERVER_PORT || "3000")
    bodyLimit: process.env.SERVER_BODY_LIMIT || "500kb"
  spaces:
    bucket:process.env.BUCKET
    bucket1:process.env.BUCKET1
    bucket2:process.env.BUCKET2
    public_data: process.env.URL_PUBLIC_DATA
    img_profile: process.env.IMG_PROFILE
    img_network: process.env.IMG_NETWORK
    img_network_icon: process.env.IMG_NETWORK
    img_community_icon: process.env.IMG_COMMUNITY_ICON
    img_community: process.env.IMG_COMMUNITY
    img_avatars: process.env.IMG_AVATARS
    img_profile_back: process.env.IMG_BACKGROUND
    img_env: process.env.IMG_ENV
    robot_catalog: process.env.IMG_ROBOT_CATALOG
  db:
    host: process.env.DB_HOST
    port: parseInt(process.env.DB_PORT)
    user: process.env.DB_USERNAME
    password: process.env.DB_PASSWORD
    database: process.env.DB_DATABASE
    debug   : process.env.DB_DEBUG is true 
  
  redis:
    host  : process.env.REDIS_HOST
    port  : parseInt(process.env.REDIS_PORT || "6379")
    prefix: process.env.REDIS_PREFIX || "finance" 
  
  apm:
    serverUrl  : process.env.APM_SERVER_URL
    serviceName: process.env.APM_SERVICE_NAME
    apiKey     : process.env.APM_API_KEY
    secretToken: process.env.APM_SECRET_TOKEN
    enable     : process.env.APM_ENABLE
  
  email:
    type       : process.env.EMAIL_TYPE || "OAuth2"
    host       : process.env.EMAIL_HOST || "smtp.gmail.com"
    port       : process.env.EMAIL_PORT ||  465
    secure     : process.env.EMAIL_SECURE is true
    notificator: process.env.EMAIL_USER
    pass       : process.env.EMAIL_PASSWORD
    OAuth2:
      clientId:  process.env.EMAIL_OAUTH2_CLIENTID
      clientSecret: process.env.EMAIL_OAUTH2_CLIENTSECRET
      refreshToken: process.env.EMAIL_OAUTH2_REFRESHTOKEN
      redirectUri: process.env.EMAIL_OAUTH2_REDIRECT_URI || "https://developers.google.com/oauthplayground"
  jobs:
    autoBackup: process.env.BACKUP_DB is true
  twilio:
    sid          :process.env.TWILIOSID
    token        :process.env.TWILIOTOKEN
    usa          :process.env.TWILIOUSA
    international:process.env.TWILIOINTERNATIONAL
  telesign:
    customerId   :process.env.TELESIGNID
    apiKey       :process.env.TELESIGNKEY
    rest_endpoint:process.env.TELESIGNREST
    timeout      :process.env.TELESIGNTIMEOUT
  system:
    files:
      default    :  "#{uri}/static/uploads/system/default.png"
      uploadsPath: "./src/public/uploads/"
      uploadsUrl : "#{uri}/static/uploads/"
  cdn_digital_ocean:
    key    :process.env.CDN_DIGITAL_OCEAN_KEY
    access :process.env.CDN_DIGITAL_OCEAN_ACCESS
  id_server:process.env.ID_SERVER || 'NODE1'