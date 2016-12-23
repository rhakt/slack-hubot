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

# data
WAKAME = loadData 'wakame'
LIMIT = loadData 'limit'


emojideco = (name, message)->
  "#{name} #{message} #{name}"


module.exports = (robot) ->

  ADDRESS = process.env.HUBOT_SERVER_ADDRESS or 'http://localhost:8080'

  robot.hear /卒論$/g, (res)->
    d = timediff new Date(), new Date(LIMIT.thesis)
    res.send emojideco ":fastparrot:", "卒論まであと#{d}日"

  robot.hear /wakame$/i, (res) ->
    res.send "#{res.random WAKAME.list}わかめ"

  robot.hear /.*/g, (res)->
    return if Math.random() < 0.97
    res.send res.random WAKAME.random

  robot.hear /金曜日/g, (res)->
    header = ":aussiereversecongaparrot:".repeat 8
    side = ":fastparrot:".repeat 3
    content = emojideco side, "華金"
    footer = ":congaparrot:".repeat 8
    text = "#{header}\n#{content}\n#{footer}"
    res.send text


  robot.respond /echo-rich\s+(.*)/i, (res)->
    unless robot.adapter instanceof SlackBot
      res.send "unsurpported. (#{res.match[1]})"
      return

    room = res.envelope.room
    #timestamp = new Date/1000|0
    query = qs.stringify timestamp: new Date().getTime()

    # https://api.slack.com/docs/message-attachments
    attachments = [
      {
        fallback: ':parrot:',
        color: res.random ['good', 'warning', 'danger', '#439FE0'],
        pretext: "#{res.match[1]}",
        fields: [
          {
            title: 'parrot :parrot:',
            value: res.random WAKAME.random,
            short: false
          }
        ],
        image_url: urljoin ADDRESS, 'image', "parrot.png?#{query}",
        footer: 'hubot',
        footer_icon: 'https://hubot.github.com/assets/images/layout/hubot-avatar@2x.png'
        #ts: timestamp
      }
    ]

    options = { as_user: true, link_names: 1, attachments: attachments }

    client = robot.adapter.client
    client.web.chat.postMessage(room, '', options)


  robot.respond /image/i, (res)->
    query = qs.stringify timestamp: new Date().getTime()
    image_url = urljoin ADDRESS, 'image', "parrot.png?#{query}"
    res.send image_url
