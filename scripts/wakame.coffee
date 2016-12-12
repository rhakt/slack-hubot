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
  
  wakame_list = ["増える", "動く", "走る", "歩く", "驚く", "靡く", "叫ぶ", "減る", "飛ぶ", "干からびる", "潤う", "弾ける", "爆ぜる", "伸びる", "縮む", "キレる", "跳ねる", "輝く", "光る", "収斂する", "躍動する", "落ち込む", "暴れる", "消える", "生きる", "食べる", "飲む", "踊る"]

  robot.hear /wakame/i, (res) ->
    res.send "#{res.random wakame_list}わかめ"

  robot.respond /wave/i, (res)->
  	res.send ":parrotwave1: :parrotwave2: :parrotwave3: :parrotwave4: :parrotwave5: :parrotwave6: :parrotwave7:"

