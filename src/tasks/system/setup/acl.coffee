Promise      = require 'bluebird'
mongo        = require '../../../dbs/mongoose'
config       = require '../../../config/config'
{env}        = require '../../../config/env'
log          = require('../../../tools/log').create 'setup.acl'
utils        = require '../../../tools/utils'
task_tools   = require '../../tools'
fs           = require 'fs'

@users = () ->
  log.d "users = setup"
  Promise.try ->

    mongo.user.countDocuments()
  .then (users_c) ->
    if users_c > 100
      throw new Error('USER_ADDEDED')
    file = fs.readFileSync('./db/acl/users.geojson', "utf8");
    users_json = JSON.parse(file);
    Promise.all(
      await users_add obj_json for obj_json in users_json
    )
  .then (us_r) ->
    log.i "finish users"
  .catch (err) ->
    if err.message not in ['USER_ADDEDED']
      log.e "JobAddRoles:users : #{err.stack}"
    return     
    
users_add = (obj_json) ->
  log.d "users_add = setup"
  Promise.try ->
    mongo.user.findOne
      username: obj_json.email
    .exec()
  .then (person) ->
    if person
      throw new Error('USER_ADDEDED')

    user = mongo.user
      first_name  : obj_json.first_name
      last_name   : obj_json.last_name
      phone       : obj_json.phone
      email       : obj_json.email
      username    : obj_json.email
      password    : obj_json.password
      latitude    : obj_json.latitude || 0.0
      longitude   : obj_json.longitude || 0.0
      avatar      : env.spaces.img_avatars
      photo       : env.spaces.img_profile_back
      device_key  : "WEB"
      device_token: "NOT_IMPLEMENTED_WEB"
      firebase_uid: "NOT_IMPLEMENTED"
      background_img : obj_json.background_img || env.spaces.img_profile_back
    user.saveAsync()
  .then (user_s) ->
    return user_s
  .catch (err) ->
    if err.message not in ['USER_ADDEDED']
      log.e "JobAddRoles:users_add : #{err.stack}"
    return obj_json


@roles = () ->
  Promise.try ->

    mongo.role.countDocuments()
  .then (users_c) ->
    if users_c > 100
      throw new Error('ROLES_ADDEDED')
    file = fs.readFileSync('./db/acl/roles.geojson', "utf8");
    role_json = JSON.parse(file);
    Promise.all(
      await role_add obj_json for obj_json in role_json
    )
  .then (us_r) ->
    log.i "finish role"
  .catch (err) ->
    if err.message not in ['ROLES_ADDEDED']
      log.e "JobAddRoles:role : #{err.stack}"
    return
    
role_add = (obj_json) ->
  Promise.try ->
    mongo.role.findOne
      authority: obj_json.authority
    .exec()
  .then (role) ->
    if role
      throw new Error('ROLES_ADDEDED')

    role = mongo.role
      authority   : obj_json.authority
    role.saveAsync()
  .then (role_s) ->
    return role_s
  .catch (err) ->
    if err.message not in ['ROLES_ADDEDED']
      log.e "JobAddRoles:role : #{err.stack}"
    return obj_json
    

@user_role = () ->
  Promise.try ->
    mongo.user_role.countDocuments()
  .then (users_c) ->
    if users_c > 100
      throw new Error('ROLES_ADDEDED')
    file = fs.readFileSync('./db/acl/user_roles.geojson', "utf8");
    user_role_json = JSON.parse(file);
    Promise.all(
      await user_role_add obj_json for obj_json in user_role_json
    )
  .then (us_r) ->
    log.i "finish user_role"
  .catch (err) ->
    if err.message not in ['ROLES_ADDEDED']
      log.e "JobAddRoles:user_role : #{err.stack}"
    return 
    
user_role_add = (obj_json) ->
  Promise.try ->
    mongo.role.findOne
      authority: obj_json.authority
    .exec()
  .then (role) ->
    if not role
      throw new Error('ROLE_NOT_EXIST')
    @role = role

    mongo.user.findOne
      username: obj_json.email
    .exec()
  .then (person) ->
    if not person
      throw new Error('USER_NOT_EXIST')
    @person = person
    mongo.user_role.findOne
      role: @role
      user: @person
    .exec()
  .then (usr_role) ->
    if usr_role
      throw new Error('USR_ROLE_EXIST')

    usr_role = mongo.user_role
      role: @role
      user: @person
    usr_role.saveAsync()
  .then (usr_role_s) ->
    return usr_role_s
  .catch (err) ->
    if err.message not in ['ROLE_NOT_EXIST','USR_ROLE_EXIST']
      log.e "JobAddRoles:user_role_add : #{err.stack}"
    return obj_json

@requestmaps = () ->
  log.d "requestmaps = setup"
  Promise.try ->

    mongo.requestmap.countDocuments()
  .then (users_c) ->
    if users_c > 100
      throw new Error('REQUESTMAPS_ADDEDED')
    file = fs.readFileSync('./db/acl/requestmap.geojson', "utf8");
    requestmap_json = JSON.parse(file);
    Promise.all(
      await requestmap_add obj_json for obj_json in requestmap_json
    )
  .then (us_r) ->
    log.i "finish requestmap"
  .catch (err) ->
    if err.message not in ['REQUESTMAPS_ADDEDED']
      log.e "JobAddRoles:requestmaps : #{err.stack}"
    return 
    
    
requestmap_add = (obj_json) ->
  Promise.try ->
    mongo.requestmap.findOne
      path : obj_json.path
      methd: obj_json.methd
    .exec()
  .then (requestmap) ->
    if requestmap
      throw new Error('REQUESTMAPS_ADDEDED')

    requestmap = mongo.requestmap
      path       : obj_json.path
      methd      : obj_json.methd
      description: obj_json.description
    requestmap.saveAsync()
  .then (requestmap_s) ->
    return requestmap_s
  .catch (err) ->
    if err.message not in ['REQUESTMAPS_ADDEDED']
      log.e "JobAddRoles:requestmap_add : #{err.stack}"
    return obj_json
    

@requestmap_role = () ->
  log.d "requestmap_role = setup"
  Promise.try ->

    mongo.requestmap_role.countDocuments()
  .then (users_c) ->
    log.d users_c > 100
    if users_c > 100
      throw new Error('ROLES_ADDEDED')
    file = fs.readFileSync('./db/acl/requestmap_roles.geojson', "utf8");
    requestmap_role_json = JSON.parse(file);
    Promise.all(
      await requestmap_role_add obj_json for obj_json in requestmap_role_json
    )
  .then (us_r) ->
    log.i "finish requestmap_role"
  .catch (err) ->
    if err.message not in ['ROLES_ADDEDED']
      log.e "JobAddRoles:requestmap_role : #{err.stack}"
    return 
    
requestmap_role_add = (obj_json) ->

  Promise.try ->
    mongo.role.findOne
      authority: obj_json.authority
    .exec()
  .then (role) ->
    if not role
      throw new Error('ROLE_NOT_EXIST')
    @role = role

    mongo.requestmap.findOne
      path : obj_json.path
      methd: obj_json.methd
    .exec()
  .then (requestmap) ->
    if not requestmap
      throw new Error('USER_NOT_EXIST')
    @requestmap = requestmap
    mongo.requestmap_role.findOne
      role      : @role
      requestmap: @requestmap
    .exec()
  .then (rqmap_role) ->
    if rqmap_role
      throw new Error('USR_ROLE_EXIST')

    rqmap_role = mongo.requestmap_role
      role      : @role
      requestmap: @requestmap
    rqmap_role.saveAsync()
  .then (rqmap_role_s) ->
    return rqmap_role_s
  .catch (err) ->
    if err.message not in ['USER_NOT_EXIST','USR_ROLE_EXIST']
      log.e "JobAddRoles:requestmap_role_add : #{err.stack}"
    return obj_json    