# Description:
#   a
#
# Dependencies:
#   None
#
# Commands:
#   wakame - awesome wakame
#   random - OMOMUKI
#   hubot image - parrot.png
#   卒論 - 卒論まであと...
#
# Configuration:
#   HUBOT_SERVER_ADDRESS: required, http://example.com
#
# Author:
#   a


qs = require 'querystring'
_ = require 'lodash'
request = require 'request'

# my module
timediff = require '../lib/timediff'
Util = require '../lib/util'

# data
WAKAME = require '../data/wakame'
LIMIT = require '../data/limit'


module.exports = (robot) ->
  robot.hear /卒論$/g, (res)->
    d = timediff new Date(), new Date(LIMIT.thesis), 'day'
    h = timediff new Date(), new Date(LIMIT.thesis), 'hour'
    res.send "終わりまであと#{d}日と#{h%24}時間！"

  robot.respond /人間ですか？/g, (res)->
    res.send "人間です。"

  robot.hear /wakame$/i, (res) ->
    res.send "#{Util.random WAKAME.list}わかめ"

  robot.hear /random$/i, (res) ->
    res.send "#{Util.random WAKAME.random}"

  robot.hear /joke$/i, (res)->
    res.send "#{Util.random WAKAME.joke}"

  robot.hear /.*/i, (res)->
    return if Math.random() < 0.97
    res.send Util.random WAKAME.random

  robot.hear /紀貫之/i, (res)->
    res.send Util.random WAKAME.waka

  robot.respond /image/i, (res)->
    query = qs.stringify timestamp: new Date().getTime()
    res.send Util.getPath 'image', "parrot.png?#{query}"
