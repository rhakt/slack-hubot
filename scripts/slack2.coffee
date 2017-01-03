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

  robot.respond /owarigakimasu/i, (res)->
    robot.logger.info "owarigakimasu"
    slack.__deleteMessage res.envelope.message.room, 100
