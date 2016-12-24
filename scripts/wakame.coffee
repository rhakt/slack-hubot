# Description:
#   a
#
# Dependencies:
#   None
#
# Commands:
#   wakame - awesome wakame
#   hubot image - parrot.png
#   卒論 - 卒論まであと...
#   金曜日 - 華金
#   hubot choice - wakame or random
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
loadData = (name, reload=false)->
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


module.exports = (robot) ->
  ut = loadLib('util')(robot)
  ADDRESS = process.env.HUBOT_SERVER_ADDRESS or 'http://localhost:8080'

  interactiveMessagesListen = do ->
    actionListener = {}
    robot.router.post "/slack/action", (req, res) ->
      content = JSON.parse req.body.payload
      func = actionListener[content.callback_id]
      return unless func
      idx = parseInt content.attachment_id
      text = content.original_message.attachments[idx - 1].text ? ""
      res.end func content.user, content.channel, content.actions[0], text
    (callback_id, callback)-> actionListener[callback_id] = callback


  robot.hear /卒論$/g, (res)->
    d = timediff new Date(), new Date(LIMIT.thesis)
    res.send ut.emojideco "卒論まであと#{d}日", 'fastparrot'

  robot.hear /wakame$/i, (res) ->
    res.send "#{ut.random WAKAME.list}わかめ"

  robot.hear /.*/g, (res)->
    return if Math.random() < 0.97
    res.send ut.random WAKAME.random

  robot.hear /金曜日/g, (res)->
    header = _.repeat ":aussiereversecongaparrot:", 8
    content = ut.emojideco "華金", 'fastparrot', 3
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

    # https://api.slack.com/docs/message-attachments
    color = ut.random ['good', 'warning', 'danger', '#439FE0']
    at1 = ut.generateFieldAttachment color,
      pretext: res.match[1]
      text: 'a'
      author_name: 'author君'
      author_link: "https://tklab-slack-hubot-test.herokuapp.com/"
      author_icon: "https://tklab-slack-hubot-test.herokuapp.com/image/smallparrot.png"
      title: "Slack API Documentation"
      title_link: "https://api.slack.com/"
      image_url: "https://tklab-slack-hubot-test.herokuapp.com/image/parrot.png"
      thumb_url: "https://tklab-slack-hubot-test.herokuapp.com/image/smallparrot.png"
      footer: 'hubot'
      footer_icon: urljoin ADDRESS, 'image', "octicons_commit.png"

    at1.fields.push ut.generateField 'wakame1', ut.random(WAKAME.random)
    at1.fields.push ut.generateField 'wakame2', ut.random(WAKAME.random)
    at1.fields.push ut.generateField 'wakame3', ut.random(WAKAME.random)
    at1.fields.push ut.generateField 'wakame4', ut.random(WAKAME.random)
    
    at2 = ut.generateActionAttachment "#3AA3E3", "button_test",
      text: ut.emojideco 'wakame or random', 'fastparrot'
      footer: 'hubot'
      footer_icon: urljoin ADDRESS, 'image', "octicons_commit.png"

    at2.actions.push ut.generateButton "wakame", "wakame", "primary"
    at2.actions.push ut.generateButton "random", "random", "danger",
      confirm: ut.generateConfirm "角煮ん", "卒論は...", "余裕", "ダメ"

    ut.sendAttachment res.envelope.room, [at1, at2]

  interactiveMessagesListen "button_test", (user, channel, action, text)->
    message = switch action.value
        when "wakame" then "#{ut.random WAKAME.list}わかめ"
        when "random" then "#{ut.random WAKAME.random}"
        else "unknown value: #{act.value}"
    ut.say channel.id, "@#{user.name} #{message}"
    "#{text} => #{user.name} choice #{action.name}"
