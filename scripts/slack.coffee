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
  slack = new Slack robot

  slack.slash.on 'say', (option, cb)->
    #slack.say option.channel.id, option.text
    at = slack.generateAttachment 'good',
      text: option.text
      author_name: option.user.name
    cb '',
      #response_type: "in_channel"
      attachments: [at]

  slack.slash.on 'delete', (option, cb)->
    slack.deleteMessage option.channel.id, 100, (cnt)->
      cb "deleted #{cnt} messages."

  robot.hear /金曜日/g, (res)->
    mes = res.envelope.message
    slack.addReaction 'parrot', mes.room, mes.id
    header = _.repeat ":aussiereversecongaparrot:", 8
    content = slack.emojideco "華金", 'fastparrot', 3
    footer = _.repeat ":congaparrot:", 8
    res.send "#{header}\n#{content}\n#{footer}"

  robot.respond /wakame\s+(.+)/i, (res)->
    num = parseInt res.match[1]
    num = 1 if isNaN num
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
    at = slack.generateAttachment 'warning',
      pretext: "outer"
      text: "inner"
    # 選択肢生成
    option =
      title: 'wakame or random？'
      text: 'わかめを選ぶと、わかめが得られます. 趣を選ぶと、趣が得られます.'
    buttons = [
      ["わかめ", "wakame", "primary"],
      ["趣", "random", "danger"]
    ]
    at2 = slack.generateChoice "button_test", "#3AA3E3", buttons, option, (user, action)->
      # ここはボタンクリック時の動作設定
      message = switch action.value
        when "wakame" then "#{Util.random WAKAME.list}わかめ"
        when "random" then "#{Util.random WAKAME.random}"
        else "unknown value: #{act.value}"
      # bot君の発言 choiceに対する応答ではなく、自発なのでそういう関数を作ってある
      slack.say res.envelope.room, "@#{user.name} #{message}"
      # ボタンクリック後に置き換えられるattachmentを生成
      # これがoriginalのattachmentの置き換わり先になる
      slack.generateAttachment "good",
        title: option.title
        text: "#{user.name} choice #{action.name}"
    # attachmentを送信
    slack.sendAttachment res.envelope.room, [at, at2]

  robot.respond /coffee[^]*```([^]+)```/m, (res)->
    room = res.envelope.room
    options =
      uri: 'http://melpon.org/wandbox/api/compile.json',
      method: 'POST',
      json:
        compiler: 'coffee-script-head'
        code: res.match[1]
        #options: 'coffee-compile-only'
    request options, (err, res, body)=>
      return @robot.logger.erro "err: #{inspect err, depth: null}" if err
      color = if body.status == '0' then 'good' else 'danger'
      result = if body.status == '0' then 'success' else 'error'
      code = if body.program_error? then body.program_error else body.program_output
      message = body.program_message
      at = slack.generateAttachment color,
        title: result
        text: "#{message}"
      slack.sendAttachment room, [at], ->
        #slack.say room, ">```#{code}```"
