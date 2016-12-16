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

  ADDRESS = process.env.HUBOT_HEROKU_URL or 'http://localhost:8080'

  robot.hear /卒論/g, (res)->
    d = timediff new Date(), new Date(LIMIT.thesis)
    res.send emojideco "fastparrot", "卒論まであと#{d}日"

  robot.hear /wakame/i, (res) ->
    res.send "#{res.random WAKAME.list}わかめ"

  robot.respond /image/i, (res)->
    query = qs.stringify timestamp: new Date().getTime()
    image_url = urljoin ADDRESS, 'image', "parrot.png?#{query}"
    res.send image_url
