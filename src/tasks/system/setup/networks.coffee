Promise      = require 'bluebird'
mongo        = require '../../../dbs/mongoose'
config       = require '../../../config/config'
log          = require('../../../tools/log').create 'setup.networks'
utils        = require '../../../tools/utils'
task_tools   = require '../../tools'
fs           = require 'fs'

@categories = () ->
  Promise.try ->
    mongo.category_type.countDocuments()
  .then (country_m) ->
    if country_m > 1
      throw new Error('CATEGORIES_ADDEDED')
    file = fs.readFileSync('./db/network/categories.geojson', "utf8");
    categories_json = JSON.parse(file);
    Promise.all(
      await categories_add obj_json for obj_json in categories_json
    )
  .then (environment_) ->
    log.i "finish categories"
  .catch (err) =>
    if err.message not in ['CATEGORIES_ADDEDED']
      log.d "JobAddCategories:categories : #{err.stack}"
    return
    
categories_add = (obj_json) ->
  Promise.try ->
    mongo.category_type.findOne
      key  : obj_json.key
    .exec()
  .then (category) ->
    if category
      throw new Error('CATEGORIES_ADDEDED')
    category = new mongo.category_type(
      key      : obj_json.key
      status   : obj_json.status
      cfg      : obj_json.cfg)
    category.saveAsync()
  .then (country_m) ->
    return country_m
  .catch (err) =>
    log.i  obj_json.key
    return obj_json

@networks = () ->
  Promise.try ->
    mongo.network.countDocuments()
  .then (networks_m) ->
    if networks_m > 1
      throw new Error('NETWORKS_ADDEDED')
    file = fs.readFileSync('./db/network/networks.geojson', "utf8");
    networks_json = JSON.parse(file);
    Promise.all(
      await networks_add obj_json for obj_json in networks_json
    )
  .then (environment_) ->
    log.i "finish networks"
  .catch (err) =>
    if err.message not in ['NETWORKS_ADDEDED']
      log.d "JobAddNetworks:networks : #{err.stack}"
    return

networks_add = (obj_json) ->
  Promise.try ->
    mongo.user.findOne
      username: obj_json.creator
    .exec()
  .then (person) ->
    if not person
      throw new Error('USER_ADDEDED')
    @person = person
    mongo.category_type.find
      status : 'ACTIVE'
      key    : $in: obj_json.categories
    .exec()
  .then (category_type) ->
    @category_type = category_type
    mongo.countries.findOne
      name  : obj_json.country
    .exec()
  .then (country) ->
    if not country
      throw new Error('COUNTRY_NOT_FOUND')
    @country = country
    mongo.network.findOne
      key       : obj_json.key
    .exec()
  .then (net) ->
    if net
      throw new Error('NETWORK_ADDEDED')
    net = new mongo.network
      country  : @country
      key      : obj_json.key
      status   : obj_json.status
      location : obj_json.location
      cfg      : obj_json.cfg
    net.creator  = @person
    net.polygon_delimiter = @country.polygon_delimiter
    for categ in @category_type
      net.categories.push categ
    console.log net
    net.saveAsync()
  .then (net_m) ->
    return net_m
  .catch (err) =>
    log.e "JobAddNetworks:networks_add : #{err.stack}"
    log.i  "#{obj_json.currency}--#{obj_json.country}"
    return obj_json

@communities = () ->
  Promise.try ->
    mongo.community.countDocuments()
  .then (networks_m) ->
    if networks_m > 1
      throw new Error('NETWORKS_ADDEDED')
    file = fs.readFileSync('./db/network/communities.geojson', "utf8");
    networks_json = JSON.parse(file);
    Promise.all(
      await communities_add obj_json for obj_json in networks_json
    )
  .then (environment_) ->
    log.i "finish networks"
  .catch (err) =>
    if err.message not in ['NETWORKS_ADDEDED']
      log.d "JobAddNetworks:networks : #{err.stack}"
    return

communities_add = (obj_json) ->
  Promise.try ->
    mongo.community.findOne
      key       : obj_json.key
    .exec()
  .then (comun) ->
    if comun
      throw new Error('NETWORK_ADDEDED')
    mongo.network.findOne
      key    : obj_json.network_key
    .exec()
  .then (net) ->
    comun = new mongo.community
      key              : obj_json.key
      status           : 'ACTIVE'
      network          : net
      location         : obj_json.location
      cfg              : obj_json.cfg

    comun.polygon_delimiter = net.polygon_delimiter
    comun.saveAsync()
  .then (comun_m) ->
    return comun_m
  .catch (err) =>
    log.e "JobAddNCommunities:communities_add : #{err.stack}"
    log.i  "#{obj_json.currency}--#{obj_json.country}"
    return obj_json


    
@environments = () ->
  Promise.try ->
    mongo.environment.countDocuments()
  .then (networks_m) ->
    if networks_m > 1
      throw new Error('NETWORKS_ADDEDED')
    file = fs.readFileSync('./db/network/environments.geojson', "utf8");
    env_json = JSON.parse(file);
    Promise.all(
      await environments_add obj_json for obj_json in env_json
    )
  .then (environment_) ->
    log.i "finish networks"
  .catch (err) =>
    if err.message not in ['NETWORKS_ADDEDED']
      log.d "JobAddNetworks:networks : #{err.stack}"
    return

environments_add = (obj_json) ->
  Promise.try ->
    mongo.environment.findOne
      key       : obj_json.key
    .exec()
  .then (envir) ->
    if envir
      throw new Error('NETWORK_ADDEDED')
    mongo.community.findOne
      key    : obj_json.community_key
    .exec()
  .then (community) ->
    envir = new mongo.environment
      key              : obj_json.key
      status           : 'ACTIVE'
      community        : community
      location         : obj_json.location
      enabled          : obj_json.enabled
      name             : obj_json.name
      algorithm        : obj_json.algorithm

    envir.polygon_delimiter = community.polygon_delimiter
    envir.saveAsync()
  .then (envirn_m) ->
    return envirn_m
  .catch (err) =>
    log.e "JobAddNEnvironments:environments_add : #{err.stack}"
    log.i  "#{obj_json.currency}--#{obj_json.country}"
    return obj_json


    