# Description:
#   send Heatbeat for heroku keepalive
#

https = require 'https'

module.exports = (robot)->
  interval = 1000 * 60 * 60 * 60;

  heartbeat = ()->
    url = process.env.HUBOT_HEROKU_KEEPALIVE_URL
    opt = host: url, path: '/'
    ()->
      https.get opt, (res)->
        console.log "HEARTBEAT: #{url} [#{res.statusCode}]"

  hb_id = setInterval heartbeat(), interval
