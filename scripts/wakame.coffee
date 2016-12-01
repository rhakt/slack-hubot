# Description:
#   
#
# Dependencies:
#   None
#
# Commands:
#   wakame - wakame
#
# Author:
#   a

module.exports = (robot) ->
  
  wakame_list = ["増える", "動く", "走る"]

  robot.hear /wakame/i, (res) ->
    res.send "#{res.random wakame_list}わかめ"
