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

  robot.respond /delete/g, (res)->
    slack.deleteMessage res.envelope.room, 100

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
    text = 'wakame or random？'
    buttons = [
      ["わかめ", "wakame", "primary"],
      ["趣", "random", "danger"]
    ]
    at2 = slack.generateChoice "button_test", "#3AA3E3", text, buttons, (user, action)->
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
        title: "#{text}"
        text: "#{user.name} choice #{action.name}"
    # attachmentを送信
    slack.sendAttachment res.envelope.room, [at, at2]

  slack.on 'star_added', (ev, user, channel, item)->
    return if user.name == robot.name
    link = item.message.permalink
    text = item.message.text
    slack.say channel, ":star: added by #{user.name}: #{link}"

  slack.on 'reaction_added', (ev, user, channel, item)->
    return if user.name == robot.name
    reaction = ev.reaction
    ts = item.ts
    slack.getMessageFromTimestamp channel, ts, (err, res)->
      return if err
      text = ":#{reaction}: added by #{user.name}"
      at = slack.generateFieldAttachment "good",
        pretext: text
        text: "#{res.text}"
        author_name: "#{res.userName}"
      slack.sendAttachment channel, [at]

  robot.respond /coffee\s+```(.+)```/m, (res)->
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
      message = body.program_message
      at = slack.generateFieldAttachment color
      text = "```\n#{message}\n```"
      at.fields.push slack.generateField "result", text, false
      slack.sendAttachment res.envelope.room, [at]
