Promise      = require 'bluebird'
mongo        = require '../../../dbs/mongoose'
config       = require '../../../config/config'
log          = require('../../../tools/log').create 'setup.countries'
utils        = require '../../../tools/utils'
fs           = require 'fs'


@countries = () ->
  Promise.try ->
    mongo.countries.countDocuments()
  .then (country_m) ->
    if country_m > 10
      throw new Error('COUNTRIES_ADDEDED')
    file = fs.readFileSync('./db/sys/countries.geojson', "utf8");
    countries_json = JSON.parse(file);
    Promise.all(
      await countries_add obj_json for obj_json in countries_json.features
    )
  .then (environment_) ->
    log.i "finish countries"
  .catch (err) ->
    if err.message not in ['COUNTRIES_ADDEDED']
      log.d "JobAddCountries:countries : #{err.stack}"
    return
    
countries_add = (obj_json) ->
  Promise.try ->
    log.i "countries_add #{obj_json.name}"
    mongo.countries.findOne
      name  : obj_json.properties.ADMIN
    .exec()
  .then (country) ->
    if country
      throw new Error('COUNTRY_ADDEDED')
    country = new mongo.countries(
      name   : obj_json.properties.ADMIN
      type   : obj_json.type
      properties  : obj_json
      polygon_delimiter  : obj_json.geometry)
    country.saveAsync()
  .then (country_m) ->
    return country_m
  .catch (err) ->
    log.e  err.stack
    log.i  obj_json.properties.ADMIN
    return obj_json

@currencies = () ->
  Promise.try ->
    mongo.currencies.countDocuments()
  .then (currencies_m) ->
    if currencies_m > 10
      throw new Error('CURRENCIES_ADDEDED')
    file = fs.readFileSync('./db/sys/currencies.geojson', "utf8");
    currencies_json = JSON.parse(file);
    Promise.all(
      await currencies_add obj_json for obj_json in currencies_json
    )
  .then (environment_) ->
    log.i "finish currencies"
  .catch (err) ->
    if err.message not in ['CURRENCIES_ADDEDED']
      log.d "JobAddCurrencies:currencies : #{err.stack}"
    return

currencies_add = (obj_json) ->
  Promise.try ->
    log.i "currencies_add #{obj_json.name}"
    mongo.countries.findOne
      name  : obj_json.country
    .exec()
  .then (country) ->
    if not country
      throw new Error('COUNTRY_NOT_FOUND')
    @country = country
    mongo.currencies.findOne
      country   : @country
      currency  : obj_json.currency
    .exec()
  .then (currency) ->
    if currency
      throw new Error('COUNTRY_ADDEDED')
    currency = new mongo.currencies
      country  : @country
      currency : obj_json.currency
      code     : obj_json.code
      minor_unit  : obj_json.minor_unit
      symbol      : obj_json.symbol
    currency.saveAsync()
  .then (currency_m) ->
    return currency_m
  .catch (err) ->
    log.e "JobAddCurrencies:currencies_add : #{err.stack}"
    log.i  "#{obj_json.currency}--#{obj_json.country}"
    return obj_json

    