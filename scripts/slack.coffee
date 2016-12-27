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

_ = require 'lodash'
Slack = require 'hubot-slack-enhance'

# my module
Util = require '../lib/util'

# data
WAKAME = require '../data/wakame'
LIMIT = require '../data/limit'


module.exports = (robot) ->
  return unless Slack.isSlackAdapter robot
  slack = new Slack robot

  robot.hear /金曜日/g, (res)->
    mes = res.envelope.message
    slack.addReaction 'parrot', mes.room, mes.id
    header = _.repeat ":aussiereversecongaparrot:", 8
    content = slack.emojideco "華金", 'fastparrot', 3
    footer = _.repeat ":congaparrot:", 8
    res.send "#{header}\n#{content}\n#{footer}"

  robot.respond /wakame\s+(.+)/i, (res)->
    num = parseInt res.match[1]
    num = 0 if isNaN num
    num = Math.min num, 20
    at = slack.generateFieldAttachment "good"
    for n in [0...num]
      text = "#{Util.random WAKAME.list}わかめ"
      # short=trueにするとハーフサイズになる
      at.fields.push slack.generateField "wakame#{n}", text, true
    slack.sendAttachment res.envelope.room, [at]

  robot.respond /att\s*([^\s]*)/i, (res)->
    color = Util.random ['good', 'warning', 'danger', '#439FE0']
    at = slack.generateAttachment color,
      pretext: res.match[1]
      text: 'a'
      author_name: 'author君'
      author_link: "https://tklab-slack-hubot-test.herokuapp.com/"
      author_icon: "https://tklab-slack-hubot-test.herokuapp.com/image/smallparrot.png"
      title: "Slack API Documentation"
      title_link: "https://api.slack.com/"
      image_url: "https://tklab-slack-hubot-test.herokuapp.com/image/parrot.png"
      thumb_url: "https://tklab-slack-hubot-test.herokuapp.com/image/smallparrot.png"
      footer: 'hubot'
      footer_icon: Util.getPath 'image', "octicons_commit.png"
    slack.sendAttachment res.envelope.room, [at]

  robot.respond /choice/i, (res)->
    text = 'wakame or random'
    buttons = [
      ["わかめ", "wakame", "primary"],
      ["趣", "random", "danger"]
    ]
    # 選択肢生成
    at = slack.generateChoice "button_test", "#3AA3E3", text, buttons, (user, channel, action, text, original)->
      # ここはボタンクリック時の動作設定
      message = switch action.value
        when "wakame" then "#{Util.random WAKAME.list}わかめ"
        when "random" then "#{Util.random WAKAME.random}"
        else "unknown value: #{act.value}"
      # bot君の発言 choiceに対する応答ではなく、自発なのでそういう関数を作ってある
      # room (channel.id)が必要
      slack.say channel.id, "@#{user.name} #{message}"
      # ボタンクリック後に置き換えられるattachmentを生成
      at2 = slack.generateAttachment "good",
        title: "result"
        text: "#{text} => #{user.name} choice #{action.name}"
      # originalは、下のslack.sendAttachmentで最終的にslackに送った全文っぽい
      # originalの中身のうち、attachmentを変えたものを送るとうまくいく
      original.attachments = [at2]
      original
    # attachmentを送信
    slack.sendAttachment res.envelope.room, [at]