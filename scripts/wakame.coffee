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
  
  wakame_list = ["増える", "動く", "走る", "歩く", "驚く", "座る", "靡く", "追いかける", "叫ぶ", "減る", "飛ぶ", "干からびる", "潤う", "弾ける", "爆ぜる", "伸びる", "縮む", "冷える", "凍る", "溶ける"]

  robot.hear /wakame/i, (res) ->
    res.send "#{res.random wakame_list}わかめ"

