Promise  = require 'bluebird'
async    = require 'async'

request       = Promise.promisifyAll require 'request'
fs            = Promise.promisifyAll require 'fs'
mongo         = require '../../dbs/mongoose'
servoce       = require '../../service'
config        = require '../../config/config'
{env}         = require '../../config/env'
log           = require('../../tools/log').create 'FirebaseService'
jwt           = require 'jsonwebtoken'
randtoken     = require 'rand-token'
tools         = require '../../tools/utils'
# data_adapter  = require '../../dbs/data_adapter'

###
  @file_owner push_notification
  @owner mbaglieri
  Tis class represent the push flow
###
@add_token = (params) ->
  if not params.firebase_token or params.firebase_token.length < 8
    return

  Promise.try ->
    mongo.user.findOne
      _id: params.id_user
    .exec()
  .then (person) ->
    if not person
      throw new Error('NO_USER')
    @person = person
    mongo.firebase_token.findOne
      type_push : params.device_key
      user      : person
      token     : params.firebase_token
    .exec()
  .then (token) ->
    if not token
      data =
        type_push     : params.device_key || 'UNDEFINED',
        token         : params.firebase_token,
        user          : @person
      token = mongo.firebase_token data
    token.saveAsync()
  .then (firebase_token) ->
    return firebase_token

@remove_token = (params) ->
  if not params.firebase_token
    return 

  Promise.try ->
    mongo.user.findOne
      _id: params.id_user
    .exec()
  .then (person) ->
    if not person
      throw new Error('NO_USER')
    mongo.firebase_token.findOne
      where:
        token  : params.firebase_token
        user   : person
  .then (fbt) ->
    if not fbt
      throw new Error('NOT_FOUND')

    fbt.removeAsync()
  .then (firebase_token) ->
    return firebase_token


@edit_token = (params) ->

  Promise.try ->
    mongo.user.findOne
      _id: params.id_user
    .exec()
  .then (person) ->
    if not person
      throw new Error('NO_USER')
    mongo.firebase_token.findOne
      token  : params.firebase_token
      user   : person
    .exec()
  .then (fbt_item) ->
    if not fbt_item
      throw new Error("NOT_FOUND")
    fbt_item.status =   params.status
    fbt_item.saveAsync()
  .then (num) ->
    return num

execute_verifying_messages = (worker) ->
  Promise.try ->
    log.d " execute_qtask_user_firebase: :-)   -> #{worker}"

    mongo.fcm_queue.find
      worker: worker
      status    : "VERIFYING"
    .populate("qtask_user")
    .limit(10)
    .exec()
  .then (fcm_queue) ->
    Promise.all(
      for bm in fcm_queue
        await verify_push(bm, worker, 1)
    )
  .then (fcm_queue) ->
    return fcm_queue

verify_push = (fcm_queue, worker,  status = 0) ->
  if not fcm_queue.registration_ids or fcm_queue.registration_ids.length < 1
    return

  Promise.try ->
    mongo.user.findOne
      _id: fcm_queue.qtask_user.user
  .then (person) ->
    if not person
      throw new Error('NO_USER')
    mongo.firebase_token.findOne
      where:
        token  : person.firebase_uid
        user   : person
  .then (fbt) ->
    @fbt = fbt
    if not fbt
      fcm_queue.status = "ERROR"
    fcm_queue.saveAsync()
  .then (token) ->
    if not @fbt
      throw new Error('NO_TOKEN')

    send_msg_fcm fcm_queue, @fbt
  .then (ff) ->
    if ff.status == 200
      fcm_queue.status = "COMPLETED"
    else
      fcm_queue.status = "ERROR"

    fcm_queue.saveAsync()
  .then (ffff) ->
    @ffff = ffff
    return @ffff
  .catch (err) ->
    log.e err, "push:sub_process", "#{err.stack}"
    return

send_msg_fcm = (fcm_queue, token) ->
  for registration_id  in fcm_queue.registration_ids
    if registration_id.length < 10
      d_json = {
        status: 406
        id    : fcm_queue._id
      }
      return d_json
  new Promise (resolve, reject) ->
    if token.type_push == 'ANDROID'
      dta = {}
      dta.action = fcm_queue.data.action
      if fcm_queue.data.question
        dta.conversation  = JSON.stringify(fcm_queue.data.question)
      else if fcm_queue.data.conversation
        dta.conversation  = JSON.stringify(fcm_queue.data.conversation)
      else if fcm_queue.data.match
        dta.match  = JSON.stringify(fcm_queue.data.match)
      dta.title = fcm_queue.notification.title
      dta.body = fcm_queue.notification.body
      options =
        uri: 'https://fcm.googleapis.com/fcm/send'
        method: 'POST'
        headers:
          'Authorization': "key=#{config.firebase.key}"
          'project_id'   : config.firebase.project_id
        json:
          registration_ids: fcm_queue.registration_ids
          priority: fcm_queue.priority,
          data:dta
          android:
            ttl:"86400s"
            # android_channel_id: "EveryThinkChannelId"
          # collapse_key: fcm_queue.collapse_key,
          # notification:
          #   click_action: fcm_queue.collapse_key
    else if token.type_push == 'iOS'
      options =
        uri: 'https://fcm.googleapis.com/fcm/send'
        method: 'POST'
        headers:
          'Authorization': "key=#{config.firebase.key}"
          'project_id'   : config.firebase.project_id
        json:
          registration_ids: fcm_queue.registration_ids
          priority: fcm_queue.priority,
          data: fcm_queue.data,
          # apns:
          #   headers:
          #     "apns-priority":5
          #   payload:
          #     aps:
          #       category: fcm_queue.collapse_key
          collapse_key: fcm_queue.collapse_key,
          notification: fcm_queue.notification
    else
      throw new Error('NO_USER')

    if options
      request options, (error, response, body) ->
        if !error and response.statusCode == 200
          # request was success, should early return response to client
          d_json = {
            status: 200
            data  : body
            id    : fcm_queue._id
          }
          resolve d_json
        else
          d_json = {
            status: 500
            data  : body
            id    : fcm_queue._id
          }
          resolve d_json

process_message = (chat, qtask_user) ->
  Promise.try ->

    log.i "Firebase Process Message: #{qtask_user.user}"

    mongo.user.findOne
      _id: qtask_user.user
    .exec()
  .then (member) ->
    if not member
      throw new Error("not_member_found")

    log.i "Firebase Member: #{member}"
    @member_sq = member
    chat.members_ack.push qtask_user.user
    chat.status_h = chat.status
    chat.status   = 2

    if not @member_sq.firebase_uid
      chat.status   = 401
    chat.saveAsync()
  .then (member_) ->
    if not @member_sq.firebase_uid
      throw new Error("firebase_uid_error")

    send_message(chat, qtask_user, @member_sq)
  .catch (err) ->
    log.e err, "push:sub_process", "#{err.stack}"
    return


# send_message = (chat, qtask_user, user) ->
#   chat_location = ""
#   Promise.try ->
#     log.d "Firebase Send Message Hai user: #{qtask_user.user}"
#     log.d "Firebase Send Message user: #{user.id}"
#     log.d chat
#     data_adapter.adapt_conversation(chat.conversation, user.id)
#   .then (conversation_) ->
#     @conversation_ = conversation_
#     mongo.user.findOne
#       where:
#         id: chat.member_id
#   .then (sender_) ->
#     fcm = new FCM(config.firebase.key.server)
#     log.d "Firebase sender"
#     @sender_sq = sender_
#     log.d @sender_sq.username
#     if chat.file and chat.file.location
#       chat_location = chat.file.location
#     message =
#       registration_ids: [user.firebase_uid]
#       priority        : 'high',
#       collapse_key: 'chat'
#       data:
#         action : 'chat/message'
#         conversation: @conversation_
#         type_message: chat.type_message
#         file: chat_location
#       notification:
#         title: @sender_sq.username
#         body : chat.text_message
#     @message = message

#     members_without_creator = chat.members
#     members_without_creator.remove chat.member_id
#     for ack in chat.members_ack
#       members_without_creator.remove ack

#     fcm_prepare_query(members_without_creator, @message)
#   .then (q) ->
#     return q
#   .catch (err) ->
#     console.error err
#     return null

Array.prototype.remove = (args...) ->
  output = []
  for arg in args
    index = @indexOf arg
    output.push @splice(index, 1) if index isnt -1
  output = output[0] if args.length is 1
  output

@fcm_prepare_query = fcm_prepare_query = ( members, message) ->
  Promise.all(
    for member in members
      member_id = 0
      if member.id
        member_id = member.id
      else
        member_id = member

      await prepare_query member_id, message
  )

@prepare_query = prepare_query = (member_id, message) ->
    # body...
  if not member_id
    return
  Promise.try ->
    mongo.user.findOne
      _id: member_id
    .exec()
  .then (member) ->
    if not member
      throw new Error("not_member_found")
    @member = member
    @member_j =
      first_name: member.first_name
      last_name : member.last_name
      _id       : member._id
      avatar    : member.avatar
      lang      : member.lang
      firebase_uid : member.firebase_uid

    service.qtask.user.get_create(user)
  .then (qtask_user_) ->
    @qtask_user = qtask_user_

    fcm_queue = new mongo.fcm_queue
      qtask_user             : qtask_user_
      registration_ids: [@member_j.firebase_uid]
      collapse_key    : message.collapse_key
      notification    : message.notification
      data            : message.data
    fcm_queue.saveAsync()
  .then (fcm_queu_) ->
    return fcm_queu_

fcm_send = (data) ->

  options =
    uri: 'https://fcm.googleapis.com/fcm/send'
    method: 'POST'
    headers:
      'Authorization': "key=#{config.firebase.key}"
      'project_id'   : config.firebase.project_id
    json: data

  request options, (error, response, body) ->
    if !error and response.statusCode == 200
      # request was success, should early return response to client
      d_json = {
        status: 200
        data  : body
      }
    else
      d_json = {
        status: 500
        data  : body
      }
    return d_json