express   = require 'express'
path      = require ('path')
viewsPath = path.join(__dirname, '../views') 
Promise   = require 'bluebird'
config    = require '../config/config'
log       = require('../tools/log').create 'Express'
session   = require 'express-session'
mongo     = require '../dbs/mongoose'
#https://editor.swagger.io/
responseTime    = require 'response-time'
hsts            = require 'hsts'
morgan          = require 'morgan'
hidePoweredBy   = require 'hide-powered-by'
xssFilter       = require 'x-xss-protection'
swaggerUi       = require 'swagger-ui-express'
swaggerDocument = require '../../doc/swagger.json'
body_parser     = require 'body-parser'
cors            = require 'cors'
helmet          = require 'helmet'
passport        = require 'passport'
nunjucks        = require 'nunjucks'
ejs             = require 'ejs'
require( 'dotenv' ).config()
multer          = require('multer')
multerS3        = require('multer-s3')
aws             = require 'aws-sdk'
s3              = require 'multer-storage-s3'
rute            = require './routes'
utils           = require '../tools/utils'
app             = express()
{env}           = require '../config/env'
{i18n}          = require '../i18n'
{errorHandler}  = require '../middleware/error.middleware'
{changeLocale}  = require "../middleware/changeLocale.middleware"
{uuidMiddleware}         = require "../middleware/uuid.middleware";
{ requestCounters, responseCounters, injectMetricsRoute, startCollection}  = require "../tools/metric"
#swagger config
swaggerUiOptions =  
  explorer: true

app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument, swaggerUiOptions));
#swagger config

app.set 'trust proxy', 1

# app.set 'view engine', 'ejs'
app.use body_parser.urlencoded({ extended: true ,limit: '15mb'})
app.use body_parser.json({limit: '10mb'})

app.use errorHandler
app.use uuidMiddleware
app.use changeLocale
app.use utils.allowCrossDomain
app.use(cors())
app.options('*', cors())
app.use(helmet())
app.use(hsts({
    maxAge: 31536000,
    includeSubDomains: true, 
    preload: true
}));
app.use(xssFilter())
app.use(hidePoweredBy())
app.use(i18n.init)
app.use(responseTime());
app.use(responseCounters);
app.use(requestCounters);

###
Bucket S3 start
###
aws.config.update({
  acl: 'public-read',
  endpoint:env.spaces.bucket,
  region: 'sfo2',
  accessKeyId: env.cdn_digital_ocean.key,
  secretAccessKey: env.cdn_digital_ocean.access
});

storage = s3(
  destination: (req, file, cb) ->
    cb null, './'
    return
  filename: (req, file, cb) ->
    cb null,  Date.now().toString()+ "-" + file.originalname
    # crypto.pseudoRandomBytes 16, (err, raw) ->
    #   # cb null, raw.toString('hex') + Date.now() + '.' + mime.extension(file.mimetype)
    #   return
    return
  bucket: env.spaces.bucket1
  region:'sfo2'
  contentType: multerS3.AUTO_CONTENT_TYPE
  acl: 'public-read')

spacesEndpoint = new aws.Endpoint(env.spaces.bucket);
s3 = new aws.S3({
  endpoint: spacesEndpoint
})

cdn_digital_ocean = multer(storage: multerS3(
  s3: s3,
  bucket: env.spaces.bucket2,
  contentType: multerS3.AUTO_CONTENT_TYPE,
  acl: 'public-read',
  contentDisposition: 'attachment',
  metadata:  (req, file, cb) ->
    cb(null, Object.assign({}, req.body));
  key: (req, file, cb) ->
    cb null, Date.now().toString() + "." + file.originalname.split('.').pop()
    return
))

###
Bucket S3 end
###
morgan.token "id", (req) ->
  return req.id;
morgan.token "date", () ->
  return new Date().toLocaleString("pt-BR");

morgan.token("body", (req) => JSON.stringify(req.body));

app.use(morgan(":id :remote-addr - :remote-user [:date[clf]] \":method :url HTTP/:http-version\" :status :res[content-length] :body \":referrer\" \":user-agent\""));

app.use session
  secret: 'AIzaSyDwhlWJGPaff6eOjs5zfTKlEAlr02YUHUs'
  saveUninitialized: true
  resave: true
  # cookie:
  #   httpOnly: true
  #   secure: true

app.set 'superSecret', config.express.session_secret


router         = express.Router()
router_static  = express.Router()

router_static.all '*', (req, res, next) ->
  console.log "static router log"
  res.header('Access-Control-Allow-Origin' , '*')

  # Request methods you wish to allow
  res.header 'Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE'
  # Request headers you wish to allow
  res.header 'Access-Control-Allow-Headers', 'X-Requested-With, Content-Type, Accept'

  # Set to true if you need the website to include cookies in the requests sent
  # to the API (e.g. in case you use sessions)
  res.header 'Access-Control-Allow-Credentials', true
  res.header('Content-Type'                , 'application/json')

  next()

app.use '/static' , rute.populate_router_static(router_static, cdn_digital_ocean)
app.use '/acl'    , rute.populate_router_acl(router_static)

router.all '*', (req, res, next) ->
  console.log " router log"

  res.header('Access-Control-Allow-Origin' , '*')

  # Request methods you wish to allow
  res.header 'Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE'
  # Request headers you wish to allow
  res.header 'Access-Control-Allow-Headers', 'X-Requested-With, Content-Type, Accept'

  # Set to true if you need the website to include cookies in the requests sent
  # to the API (e.g. in case you use sessions)
  res.header 'Access-Control-Allow-Credentials', true
  res.header('Content-Type'                , 'application/json')
    # check header or url parameters or post parameters for token
  token = req.body.token or req.query.token or req.query.access_token or req.body.access_token
  if config.debug
    fullUrl = req.protocol + '://' + req.get('host') + req.originalUrl
  if not token
    if req.headers['authorization']
      token = req.headers['authorization'].split(' ')[1]

  Promise.try ->
    if not token
      throw new Error("NOT_TOKEN_FOUND")
    next()

  .catch (err) ->
    log.e err
    if err.message in ['NOT_TOKEN_FOUND']
      return res.status(401).send(
        success: false
        message: 'No token provided.')
    else if err.message in ['NOT_TOKEN_VALID']
      return res.status(401).send(
        success: false
        message: 'Failed to authenticate token.')
    else
      return res.status(401).send(
        success: false
        message: 'No token provided.')

app.use passport.initialize()

app.use '/api/admin', rute.populate_router_admin(router, cdn_digital_ocean)

app.use '/api', rute.populate_router_api(router, cdn_digital_ocean)

app.use '/api', rute.populate_router_me(router, cdn_digital_ocean)

# app.set 'view engine', 'pug'
app.set 'view engine', 'html'
app.set 'views', viewsPath


app.use (err, req, res, next) ->
  if err
    d_json = 
      message : 'Failed to decode param: ' + req.url
      status  : err.statusCode = 400
    log.e err.stack
    res.status(406).json(d_json)
  else
    next();

# /** Metric Endpoint */
injectMetricsRoute(app);

app.get('/', (req, res, next) ->

  Promise.try ->
    # data  :data_adapter.get_me(req.user),
    mongo.Connection.findOne().exec()
  .then (token) ->
    log.d token
    res.render 'about'
  .catch (err) ->
    log.e "get_fail: #{err}"
    res.send '{"status":200}'
)

app.get('*', (req, res, next) ->
  # res.render 'index'
  res.status(200).send('Sorry, page not found')
  next()
)

# Templating:
nunjucks.configure config.express.view_root,
  express: app
  autoescape: true

servers = []

@start = -> 
  log.i "started:rest_server"

  if config.rest.ports.length < 1
    throw new Error "no rest defined. Please check your config"


  if config.ssl.https_enabled

    hskey   = fs.readFileSync(config.ssl.privkey)
    hscert  = fs.readFileSync(config.ssl.cert)
    hsca    = fs.readFileSync(config.ssl.ca)
    options =
      key : hskey
      cert: hscert
      ca  : hsca

    secureServer = https.createServer(options, app)

    new Promise (resolve, reject) ->
      server = secureServer.listen config.ssl.port, (err) ->
        startCollection()
        if not err? then resolve() else reject err

      servers.push server
  new Promise (resolve, reject) ->
    server = app.listen config.express.port, (err) ->
      startCollection()
      if not err? then resolve() else reject err

    server.on 'connection', (socket)  ->
      socket.setTimeout(10 * 60 * 1000)

    servers.push server

@stop = ->
  for server in servers
    if server?
      new Promise (resolve, reject) ->
        if server?
          Promise.mcall server, 'close'
        else
          reject new Error "app.stop() called, but http server is not running"
    else
      log.i "stopServer() called, but server is not running"