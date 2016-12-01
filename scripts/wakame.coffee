# Description:
#   
#
# Dependencies:
#   None
#
# Commands:
#   wakame - awesome wakame
#
# Author:
#   a

module.exports = (robot) ->
  
  wakame_list = ["増える", "動く", "走る", "歩く", "驚く", "座る", "靡く", "触る", "追いかける", "腰掛ける", "叫ぶ", "減る", "飛ぶ", "干からびる", "潤う", "弾ける", "爆ぜる"]

  robot.hear /wakame/i, (res) ->
    res.send "#{res.random wakame_list}わかめ"

