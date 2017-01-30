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

  horobi = (ev, user, channel, item)->
    res = /(人間|感情|終わり)/i.match item.text
    return unless res
    msg = res.match[1]
    ts = if item.thread_ts? then item.thread_ts else item.ts
    options =
      thread_ts: ts
      reply_broadcast: false
    slack.say channel, msg, options

  slack.on 'message.channels', horobi
  slack.on 'message.groups', horobi
  slack.on 'message.im', horobi

  ###
  robot.hear /(人間|感情|終わり)/i, (res)->
    msg = res.match[1]
    options =
      thread_ts: res.envelope.message.id
      reply_broadcast: true
    slack.say res.envelope.message.room, msg, options
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
