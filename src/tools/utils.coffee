Promise = require 'bluebird'
request = require 'request'
bcrypt  = require 'bcrypt'
moment  = require 'moment'
bcast   = require '../dbs/redis/broadcast'
fs      = require('fs')
path    = require('path')
mongo   = require '../dbs/mongoose'
config  = require '../config/config'
{IP2Location} = require 'ip2location-nodejs'

Array.prototype.remove = (args...) ->
  output = []
  for arg in args
    index = @indexOf arg
    output.push @splice(index, 1) if index isnt -1
  output = output[0] if args.length is 1
  output

@remove_from_array = remove_from_array = (arry, element) ->
  if arry.indexOf(element)
    return arry.splice(arry.indexOf(element), 1) 
  return arry

@arry1_distinct = (arry1, arry2) ->
  for f1 in arry2
    arry1 = remove_from_array arry1,f1
  return arry1

@find_join_jsons = (dir, files) ->
  f = {}
  for i in files
    for name, task of require(path.resolve(dir,i))
      f[name] = task
  return f

@get_ip_info = (ip) ->
  ip2location = new IP2Location()
  ip2location.open(path.resolve("./db/ip2location/IP2LOCATIONLITEDB11.BIN"))
  v = ip2location.getAll(ip)
  ip2location.close()
  return v

@set_req_res_upload = (req,res) ->
  res.header 'Access-Control-Allow-Origin', '*'
  res.header 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE'
  res.header 'Access-Control-Allow-Headers', 'Content-Type, Authorization'
  res.header 'Content-Type', 'application/json'
  req.socket.setTimeout(10 * 60 * 1000);
  
@get_ip_req = (req) ->
  ip_full = req.headers['x-forwarded-for'] || req.connection.remoteAddress || req.socket.remoteAddress || req.connection.socket.remoteAddress;
  ip      = ip_full.split(',')[0];
  ip      = ip.split(':').slice(-1);
  return ip_full
  
@errors_mod = (err,modul) ->
  errors   = require "../i18n/errors/#{modul}"
  
  if(errors["#{err.message}"]?.status)
    err_json = errors["#{err.message}"]
  else
    err_json = errors["BASE"]

  if config.logging.showErrorsInHttp
    err_json.stack = err.stack
    
  if config.logging.showErrorsInConsole
    console.log err.stack

  return err_json

Promise.fcall = (func, args...) ->
  Promise.promisify(func).apply null, args

Promise.mcall = (object, method_name, args...) ->
  Promise.promisify(object[method_name]).apply object, args

JSON.pretty = (object) ->
  JSON.stringify object, null, 4
  
@authenticate = (value,password) ->
  if bcrypt.compareSync(value, password)
    this
  else
    false

@getAllFiles = getAllFiles =(dirPath, arrayOfFiles) ->
  files = fs.readdirSync(dirPath)
  arrayOfFiles = arrayOfFiles || []

  files.forEach (file) ->
    if fs.statSync(dirPath + "/" + file).isDirectory()
      arrayOfFiles = getAllFiles(dirPath + "/" + file, arrayOfFiles)
    else
      if(file.indexOf('.') != 0 and file != 'index.js' and file != 'index.coffee' and file != 'replica.js' and file != 'replica.coffee' and file.indexOf('.map') == -1  and file.indexOf('.sh') == -1)
        arrayOfFiles.push(path.join( dirPath, "/", file))

  return arrayOfFiles
  
@closeConnection = (type, id, code = 3000, reason = "3000" ) ->
  messg = {
    'action' : "close"
    'code'   : code
    'reason' : reason
  }
  if type is 'operator'
    bcast.broadcastToOperator  id, messg
  else if type is 'guest'
    bcast.broadcastToUser id, messg
  else if type is 'user'
    bcast.broadcastToUser id, messg
  else if type is 'employee'
    bcast.broadcastToUser id, messg
  else if type is 'analytics'
    bcast.broadcastToUser id, messg
  else if type is 'admin'
    bcast.broadcastToUser id, messg
    
@startsWith = (st, subString) ->
  return st.charAt(1) is subString
  
@onlyUnique = (value, index, self) ->
  self.indexOf(value) == index

@authClient = (token) ->
  Promise.promisifyAll request.defaults
    headers: { authorization: "Bearer #{token}" }

@urlToArray = (url) ->
  request = {}
  pairs   = url.substring(url.indexOf('?') + 1).split('&')
  for i in [0...pairs.length]
    pair = pairs[i].split('=');
    request[decodeURIComponent(pair[0])] = decodeURIComponent(pair[1])
  return request

@arrayToUrl = (obj) ->
  str = []
  for p in obj
    if obj.hasOwnProperty(p)
      str.push(encodeURIComponent(p) + "=" + encodeURIComponent(obj[p]))

  return str.join("&")

@replaceName = (text,json_name) ->
  text = text.replace ":first_name",json_name.first_name
  text = text.replace ":last_name",json_name.last_name
  return text


@replaceVarName = (name) ->
  if '-' in name
    return  name.split('-')[1]
  return name


compare_attr = (attr1, attr2) ->
  result_set = attr2
  #We only evaluate the attr1, if attr2 is undefined who cares!!!
  if attr1? and attr2?
    attr1_st = JSON.stringify attr1
    attr2_st = JSON.stringify attr2
    if attr1_st.length > attr2_st
      result_set = attr1

  else if attr1?
    result_set = attr1

  return result_set


push_attrs = (attr1, attr2) ->
  result_set = attr2
  if attr1? and attr2?
    for i in [0...attr1.length]
      if attr1[i] not in  result_set
        result_set.push attr1[i]

  else if attr1?
    result_set = attr1

  return result_set

@allowCrossDomain = (req, res, next) ->
  if req.headers['x-arr-ssl'] and !req.headers['x-forwarded-proto']
    req.headers['x-forwarded-proto'] = 'https'
  res.header 'Access-Control-Allow-Origin', '*'
  res.header 'Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE'
  res.header 'Access-Control-Allow-Headers', 'Content-Type,X-Requested-With,content-type, Authorization'
  res.header 'Access-Control-Allow-Credentials', true
  next()


@AuthorizationRouteAdmin = (req, res, next) ->
  if not req.isAuthenticated()
     res.send('you dont have permission to access')
     return
  if not req.user or not req.user.is_admin
     res.send('you dont have permission to access')
     return
  next()


@randomNum = randomNum = (max, min=0) ->
  return Math.floor(Math.random() * (max - min + 1)) + min

@randomFloat = randomFloat = (max, min=0) ->
  return Math.random() * max 
  

@decodeBase64Image = (dataString) ->

  matches = dataString.match(/^data:([A-Za-z-+\/]+);base64,(.+)$/)
  response = {}
  if matches.length != 3
    return new Error('Invalid input string')
  response.type = matches[1]
  response.data = new Buffer(matches[2], 'base64')
  response


@update_with_hit = (next) ->
  @created_at = Date.now() unless @created_at?
  @updated_at = Date.now()
  @hits       = @hits + 1
  next()

@update_timestamp = (next) ->
  @created_at = Date.now() unless @created_at?
  @pong_date  = Date.now() unless @pong_date?
  @updated_at = Date.now()
  next()
  
@update_timestamp_user = (next) ->
  @created_at = Date.now() unless @created_at?
  @updated_at = Date.now()
  if not this.isModified('password')
    return next()

  salt = bcrypt.genSaltSync(10)
  hash = bcrypt.hashSync(@password, salt)
  @password = hash
  next()


@getFromYesterday = () ->
  myFromDate = moment(Date.now())
  myFromDate1 = myFromDate.subtract(1, 'days').toDate()
  myToDate   = moment(Date.now()).add(1, 'days').toDate()
  #moment().calendar().toDate()
  f =
    '$gte': myFromDate1
    '$lte': myToDate
  return f
  
@getFromPastDay = () ->
  myFromDate = moment(Date.now())
  myFromDate1 = myFromDate.subtract(2, 'days').toDate()
  myToDate   = moment(Date.now()).subtract(1, 'days').toDate()
  #moment().calendar().toDate()
  f =
    '$gte': myFromDate1
    '$lte': myToDate
  return f

@get_from_yesterday = () ->
  myFromDate = moment(Date.now())
  myToDate   = moment(Date.now()).subtract(1, 'days').toDate()
  #moment().calendar().toDate()
  f =
    '$lte': myToDate
  return f

@getFromPastDays = (days) ->
  myFromDate = moment(Date.now())
  myFromDate1 = myFromDate.subtract(days, 'days').toDate()
  f =
    '$lte': myFromDate1
  return f
  
@getFromPastMinutes = (minutes) ->
  myFromDate = moment(Date.now())
  myFromDate1 = myFromDate.subtract(minutes, 'minutes').toDate()
  f =
    '$lte': myFromDate1
  return f
@getFrom = (hours) ->
  myFromDate = moment(Date.now())
  myFromDate1 = myFromDate.subtract(hours, 'hours').toDate()
  myToDate   = moment(Date.now()).add(1, 'days').toDate()
  #moment().calendar().toDate()
  f =
    '$gte': myFromDate1
    '$lte': myToDate
  return f

@getFromMinutes = (minutes) ->
  myFromDate = moment(Date.now())
  myFromDate1 = myFromDate.subtract(minutes, 'minutes').toDate()
  myToDate   = moment(Date.now()).add(1, 'days').toDate()
  #moment().calendar().toDate()
  f =
    '$gte': myFromDate1
    '$lte': myToDate
  return f

@getQueryDayAfterXDays = (days) ->
  return moment(Date.now()).add(days, 'days').toDate()

@getQueryDayBeforeXDays = (days) ->
  #moment().add(1, 'days').calendar();       // Tomorrow at 10:37 AM
  #moment().calendar().toDate()
  myToDate   = moment(Date.now()).subtract(days, 'days').toDate()
  f =
    '$lte': myToDate
  return f