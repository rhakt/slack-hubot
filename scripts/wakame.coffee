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
  ":#{name}: #{message} :#{name}:"


module.exports = (robot) ->

  ADDRESS = process.env.HUBOT_SERVER_ADDRESS or 'http://localhost:8080'

  robot.hear /卒論$/g, (res)->
    d = timediff new Date(), new Date(LIMIT.thesis)
    res.send emojideco "fastparrot", "卒論まであと#{d}日"

  robot.hear /wakame$/i, (res) ->
    res.send "#{res.random WAKAME.list}わかめ"

  robot.hear /.*/g, (res)->
    return if Math.random() < 0.97
    res.send res.random [
      "分かる"
      "ウケる"
      "ほんとに〜？"
      "w"
      "こんにちは"
      "ちくわ大明神"
      "進捗どうですか？"
      "卒論は大丈夫そうですか...？"
      "スライド出来ましたか？"
      "論文読み終わりましたか？"
    ]

  robot.respond /echo-rich\s+(.*)/i, (res)->
    unless robot.adapter instanceof SlackBot
      res.send "unsurpported. (#{res.match[1]})"
      return
    data =
      content:
        color: "00ff00"
        fallback: "Sumally ....."
        title: "Title...."
        text: "#{res.match[1]}"
        mrkdwn_in: ["text"]
      channel: res.envelope.room
      username: "partyparrot"
      icon_emoji: ":fastparrot:"
    robot.emit 'slack.attachment', data

  robot.respond /image/i, (res)->
    query = qs.stringify timestamp: new Date().getTime()
    image_url = urljoin ADDRESS, 'image', "parrot.png?#{query}"
    res.send image_url
