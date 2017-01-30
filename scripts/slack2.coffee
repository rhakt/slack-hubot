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


module.exports = (robot) ->
  return unless Slack.isSlackAdapter robot
  slack = Slack.getInstance robot

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

  slack.on 'message', (ev, user, channel)->
    return if ev.subtype?
    res = /(人間|感情|終わり)/i.exec ev.text
    return unless res
    msg = res[1]
    ts = if ev.thread_ts? then ev.thread_ts else ev.ts
    options =
      thread_ts: ts
      reply_broadcast: false
    robot.logger.info "user.name: #{user.name}"
    robot.logger.info "robot.name: #{robot.name}"
    #slack.say channel, msg, options

  ###
  robot.hear /(人間|感情|終わり)/i, (res)->
    #msg = res.match[1]
    #options =
    #  thread_ts: res.envelope.message.id
    #  reply_broadcast: true
    #slack.say res.envelope.message.room, msg, options
  ###
  
  robot.respond /upload (.+)/i, (res)->
    filename = "#{new Date().getTime()}.txt"
    title = "終わりが来ます"
    text = res.match[1]
    channel = res.envelope.message.room
    slack.plainTextUpload filename, title, text, channel

  robot.respond /owarigakimasu/i, (res)->
    robot.logger.info "owarigakimasu"
    slack.__deleteMessage res.envelope.message.room, 100
