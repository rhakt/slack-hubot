# Description:
#
#
# Dependencies:
#   None
#
# Commands:
#   wakame - awesome wakame
#   image - parrot.png
#
# Author:
#   a


qs = require 'querystring'
path = require 'path'
urljoin = require 'url-join'
_ = require 'lodash'

# この書き方はバカ
SlackBot = require '../node_modules/hubot-slack/src/bot'

# util
deleteRequireCache = (name)->
  file = require.resolve name
  if require.cache[file]?
    delete require.cache[file]

DATA_PATH = '../data'
loadData = (name, reload)->
  deleteRequireCache name if reload
  require path.join DATA_PATH, name

LIB_PATH = '../lib'
loadLib = (name)->
  require path.join LIB_PATH, name

# my module
timediff = loadLib 'timediff'
ut = loadLib 'util'

# data
WAKAME = loadData 'wakame'
LIMIT = loadData 'limit'


emojideco = (name, message)->
  "#{name} #{message} #{name}"


generateAttachment = (color, pretext)->
  #timestamp = new Date/1000 | 0
  obj =
    fallback: 'fallback text'
    color: color
    #ts: timestamp
  obj.pretext = pretext if pretext
  obj

generateButton = (name, value, extra={})->
  option =
    name: name
    text: name
    type: "button"
    value: value
  _.extend option, extra


module.exports = (robot) ->

  ADDRESS = process.env.HUBOT_SERVER_ADDRESS or 'http://localhost:8080'

  say = (channel_id, message)->
    envelope =
      user:
        type: 'groupchat'
        room: channel_id
      room: channel_id
    robot.send envelope, message

  sendAttachment = (room, attachments, extra={})->
    options =
      as_user: true
      link_names: 1
      attachments: attachments
    options = _.extend options, extra
    robot.adapter.client.web.chat.postMessage room, '', options

  actionListener = {}
  robot.router.post "/slack/action", (req, res) ->
    content = JSON.parse req.body.payload
    for own cid, func of actionListener
      if cid == content.callback_id
        idx = parseInt content.attachment_id
        text = content.original_message.attachments[idx - 1].text
        text = func content.user, content.channel, content.actions[0], text
        res.end text
        return

  interactiveMessagesListen = (callback_id, callback)->
    actionListener[callback_id] = callback


  robot.hear /卒論$/g, (res)->
    d = timediff new Date(), new Date(LIMIT.thesis)
    res.send emojideco ":fastparrot:", "卒論まであと#{d}日"

  robot.hear /wakame$/i, (res) ->
    res.send "#{res.random WAKAME.list}わかめ"

  robot.hear /.*/g, (res)->
    return if Math.random() < 0.97
    res.send res.random WAKAME.random

  robot.hear /金曜日/g, (res)->
    header = _.repeat ":aussiereversecongaparrot:", 8
    side = _.repeat ":fastparrot:", 3
    content = emojideco side, "華金"
    footer = _.repeat ":congaparrot:", 8
    res.send "#{header}\n#{content}\n#{footer}"

  robot.respond /image/i, (res)->
    query = qs.stringify timestamp: new Date().getTime()
    image_url = urljoin ADDRESS, 'image', "parrot.png?#{query}"
    res.send image_url

  robot.respond /choice\s*([^\s]*)/i, (res)->
    unless robot.adapter instanceof SlackBot
      res.send "unsurpported. (#{res.match[1]})"
      return

    query = qs.stringify timestamp: new Date().getTime()

    # https://api.slack.com/docs/message-attachments
    at1 = generateAttachment res.random(['good', 'warning', 'danger', '#439FE0']), res.match[1]
    at1.fields = [
      {
        title: 'parrot :parrot:'
        value: res.random(WAKAME.random)
        short: false
      }
    ]
    at1.footer = 'hubot'
    at1.footer_icon = urljoin(ADDRESS, 'image', "octicons_commit.png")

    at2 = generateAttachment "#3AA3E3"
    at2.text = emojideco ':fastparrot:', 'wakame or random'
    at2.callback_id = "button_test"
    at2.actions = []
    at2.actions.push generateButton "wakame", "wakame"
    at2.actions.push generateButton "random", "random",
      style: "danger"
      confirm:
        title: "Are you sure?"
        text: "卒論は大丈夫そうですか...？"
        ok_text: "Yes"
        dismiss_text: "No"
    sendAttachment res.envelope.room, [at1, at2]

  interactiveMessagesListen "button_test", (user, channel, action, text)->
    message = switch action.value
        when "wakame" then "#{ut.random WAKAME.list}わかめ"
        when "random" then "#{ut.random WAKAME.random}"
        else "unknown value: #{act.value}"
    say channel.id, "@#{user.name} #{message}"
    return "#{text} => #{user.name} choice #{action.name}"
    #return "send to #{channel.name}@#{user.name}: #{message}"
