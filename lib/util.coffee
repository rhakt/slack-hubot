_ = require 'lodash'

module.exports = (robot)->
  obj = {}

  obj.random =  (arr)->
    arr[Math.floor Math.random() * arr.length]

  obj.emojideco = (message, name, repeat=1)->
    emo = _.repeat ":#{name}:", repeat
    "#{emo} #{message} #{emo}"

  obj.generateAttachment = (color, extra={})->
    #timestamp = new Date/1000 | 0
    obj =
      fallback: 'fallback text'
      color: color
      #ts: timestamp
    _.extend option, extra

  obj.generateButton = (name, value, extra={})->
    option =
      name: name
      text: name
      type: "button"
      value: value
    _.extend option, extra

  obj.say = (channel_id, message)->
    envelope =
      user:
        type: 'groupchat'
        room: channel_id
      room: channel_id
    robot.send envelope, message

  obj.sendAttachment = (room, attachments, extra={})->
    options =
      as_user: true
      link_names: 1
      attachments: attachments
    options = _.extend options, extra
    robot.adapter.client.web.chat.postMessage room, '', options

  return obj
