config = require '../../config/config'
utils  = require '../../utils'
#view http://documentup.com/kriskowal/q/

#view http://www.hnwatcher.com/r/1196438/Knex-js-A-SQL-Query-Builder-for-Javascript
knex = require('knex')
  client    : config.knex.dialect
  connection: config.knex
  pool:
    min: config.knex.pool.min
    max: config.knex.pool.max
  debug: false

@list = (filter) ->
  # lc.email is not null
  query = knex
    .select(
      'id','id_user','notes','created_date','visible'
    ).from 'notes'
  # query = @basic_filters query,filter
  query.orderBy('created_date', 'desc')
  query

@count = (filter) ->
  # lc.email is not null
  query = knex('notes').count('id as id')
  query

@edit = (filter) ->
  query = knex('notes')
  .update filter
  .where 'id', filter.id


@add = (filter) ->
  query = knex('notes')
  .insert filter


@basic_filters = (query, filter) ->
  if filter.init
    query.offset filter.init
  if filter.limit
    query.limit filter.limit

  delete filter.limit
  delete filter.init
  query.where filter

  return query