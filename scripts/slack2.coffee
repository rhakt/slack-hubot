# Description:
#   a
#
# Dependencies:
#   None
#
# Commands:
#   金曜日 - 華金
#   hubot choice - wakame or random
#
# Author:
#   a

{inspect} = require 'util'
_ = require 'lodash'
request = require 'request'
Slack = require 'hubot-slack-enhance'

# my module
Util = require '../lib/util'

# data
WAKAME = require '../data/wakame'
LIMIT = require '../data/limit'
SOUMU = "#{process.env.SOUMU}".split ','


module.exports = (robot) ->
  return unless Slack.isSlackAdapter robot
  slack = Slack.getInstance robot


  registerReply = do ->
    replyList = []
    slack.on 'message', (ev, user, channel)->
      return if ev.subtype?
      return if user.name == robot.name
      for {reg, cb} in replyList
        res = reg.exec ev.text
        if res
          msg = cb res
          ts = if ev.thread_ts? then ev.thread_ts else ev.ts
          options =
            thread_ts: ts
            reply_broadcast: false
          slack.say channel, msg, options
          break
    (reg, cb)-> replyList.push [reg, cb]

  registerReply /(人間|感情|終わり)/i, (match)-> match[1]

  registerReply /総務$/i, (match)->
    if Math.random() < 0.9
      ":fastparrot: 次の総務は〜〜 :point_right: #{Util.random SOUMU}"
    else
      "お前"


  robot.respond /upload (.+)/i, (res)->
    filename = "#{new Date().getTime()}.txt"
    title = "終わりが来ます"
    text = res.match[1]
    channel = res.envelope.message.room
    slack.plainTextUpload filename, title, text, channel

  robot.respond /owarigakimasu/i, (res)->
    robot.logger.info "owarigakimasu"
    slack.__deleteMessage res.envelope.message.room, 100

  ###
  slack.on 'star_added', (ev, user, channel, item)->
    return if user.name == robot.name
    link = item.message.permalink
    text = item.message.text
    slack.say channel, ":star: added by #{user.name}: #{link}"

  slack.on 'reaction_added', (ev, user, channel, item)->
    return if user.name == robot.name
    reaction = ev.reaction
    ts = item.ts
    slack.getMessageFromTimestamp channel, ts, (err, res)->
      return if err
      text = ":#{reaction}: added by #{user.name}"
      at = slack.generateFieldAttachment "good",
        pretext: text
        text: "#{res.text}"
        author_name: "#{res.userName}"
      slack.sendAttachment channel, [at]
  ###

