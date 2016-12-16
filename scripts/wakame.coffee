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
urljoin = require 'url-join'

WAKAME = require '../data/wakame'


module.exports = (robot) ->

  ADDRESS = process.env.HUBOT_HEROKU_URL or 'http://localhost:8080'

  robot.hear /wakame/i, (res) ->
    res.send "#{res.random WAKAME.list}わかめ"

  robot.respond /image/i, (res)->
    query = qs.stringify timestamp: new Date().getTime()
    image_url = urljoin ADDRESS, 'image', "parrot.png?#{query}"
    res.send image_url
