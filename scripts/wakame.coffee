# Description:
#   a
#
# Dependencies:
#   None
#
# Commands:
#   wakame - awesome wakame
#   random - OMOMUKI
#   hubot image - parrot.png
#   卒論 - 卒論まであと...
#   金曜日 - 華金
#   hubot choice - wakame or random
#   :santa: - Merry X'mas!
#
# Author:
#   a


qs = require 'querystring'
path = require 'path'
urljoin = require 'url-join'
_ = require 'lodash'

# この書き方はバカ
SlackBot = require '../node_modules/hubot-slack/src/bot'

# util
deleteRequireCache = (name)->
  file = require.resolve name
  if require.cache[file]?
    delete require.cache[file]

DATA_PATH = '../data'
loadData = (name, reload=false)->
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


module.exports = (robot) ->
  ut = loadLib('util')(robot)
  ADDRESS = process.env.HUBOT_SERVER_ADDRESS or 'http://localhost:8080'

  # doは即時関数で、interactiveMessagesListen関数の中身を返す
  interactiveMessagesListen = do ->
    actionListener = {}
    # ボタンクリック時にslackからPOSTされる
    robot.router.post "/slack/action", (req, res) ->
      content = JSON.parse req.body.payload
      # callback_idで呼び出す関数を変える
      func = actionListener[content.callback_id]
      # 存在しなければさようなら
      return unless func
      # interactiveMessagesのtextフィールドを取り出す
      idx = parseInt content.attachment_id
      orig = content.original_message
      text = orig.attachments[idx - 1].text ? ""
      ret = func content.user, content.channel, content.actions[0], text, orig
      if ret
        # ボタンをクリック後に別のattachmentに置き変えるタイプ
        res.json ret
        # お役御免
        delete actionListener[content.callback_id]
      else
        # ボタンクリックしたあとも残すタイプ
        res.end ""
    # interactiveMessagesListenの中身 (actionListenerを外に出さないようにこうなっている)
    (callback_id, callback)-> actionListener[callback_id] = callback

  # 選択肢を作るために特化 callback_idの指定をミスらないように一箇所に固める
  generateChoice = (base, color, text, buttons, callback)->
    timestamp = new Date().getTime()
    cid = "#{base}_#{timestamp}"
    # ボタンクリック時の動作を登録
    interactiveMessagesListen cid, callback
    # 送信するためのattachmentを作る
    at = ut.generateActionAttachment color, cid,
      text: text
    for btn in buttons
      at.actions.push ut.generateButton btn[0], btn[1], btn[2] ? "default"
    at

  robot.adapter.client?.on? 'star_added', (res)->
    console.log res
    #return unless res.item.message.permalink
    #user = robot.adapter.client.getUserByID res.user
    #text = ":star: @#{user.name} added star #{res.item.message.permalink}"
    #robot.send {room: res.envelope.room}, text

  reaction_matcher = (msg)->
    msg.type is 'reaction_added'
  robot.listen reaction_matcher, {}, (res)->
    console.log res

  robot.hear /卒論$/g, (res)->
    d = timediff new Date(), new Date(LIMIT.thesis)
    res.send ut.emojideco "卒論まであと#{d}日", 'fastparrot'

  robot.hear /wakame$/i, (res) ->
    res.send "#{ut.random WAKAME.list}わかめ"

  robot.hear /random$/i, (res) ->
    res.send "#{ut.random WAKAME.random}"

  robot.hear /.*/g, (res)->
    return if Math.random() < 0.95
    res.send ut.random WAKAME.random

  robot.hear /金曜日/g, (res)->
    header = _.repeat ":aussiereversecongaparrot:", 8
    content = ut.emojideco "華金", 'fastparrot', 3
    footer = _.repeat ":congaparrot:", 8
    res.send "#{header}\n#{content}\n#{footer}"

  robot.respond /image/i, (res)->
    query = qs.stringify timestamp: new Date().getTime()
    res.send urljoin ADDRESS, 'image', "parrot.png?#{query}"

  robot.respond /wakame\s+(.+)/i, (res)->
    # attachmentsはslack専用なので
    unless robot.adapter instanceof SlackBot
      return res.send "unsurpported."

    num = parseInt res.match[1]
    num = 0 if isNaN num
    num = Math.min num, 20
    at = ut.generateFieldAttachment "good"
    for n in [0...num]
      text = "#{ut.random WAKAME.list}わかめ"
      # short=trueにするとハーフサイズになる
      at.fields.push ut.generateField "wakame#{n}", text, true
    ut.sendAttachment res.envelope.room, [at]

  robot.respond /att\s*([^\s]*)/i, (res)->
    unless robot.adapter instanceof SlackBot
      return res.send "unsurpported."

    color = ut.random ['good', 'warning', 'danger', '#439FE0']
    at = ut.generateAttachment color,
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
      footer_icon: urljoin ADDRESS, 'image', "octicons_commit.png"
    ut.sendAttachment res.envelope.room, [at]


  robot.respond /choice/i, (res)->
    unless robot.adapter instanceof SlackBot
      return res.send "unsurpported."

    text = 'wakame or random'
    buttons = [
      ["わかめ", "wakame", "primary"],
      ["趣", "random", "danger"],
      ["無", "none"]
    ]
    # 選択肢生成
    at = generateChoice "button_test", "#3AA3E3", text, buttons, (user, channel, action, text, original)->
      # ここはボタンクリック時の動作設定
      message = switch action.value
        when "wakame" then "#{ut.random WAKAME.list}わかめ"
        when "random" then "#{ut.random WAKAME.random}"
        when "none" then ""
        else "unknown value: #{act.value}"
      # bot君の発言 choiceに対する応答ではなく、自発なのでそういう関数を作ってある
      # room (channel.id)が必要
      ut.say channel.id, "@#{user.name} #{message}"
      # ボタンクリック後に置き換えられるattachmentを生成
      at2 = ut.generateAttachment "good",
        title: "result"
        text: "#{text} => #{user.name} choice #{action.name}"
      # originalは、下のut.sendAttachmentで最終的にslackに送った全文っぽい
      # originalの中身のうち、attachmentを変えたものを送るとうまくいく
      original.attachments = [at2]
      original

    # attachmentを送信
    ut.sendAttachment res.envelope.room, [at]

  # baka
  robot.hear /:santa:/i, (res)->
    unless robot.adapter instanceof SlackBot
      return res.send "unsurpported."

    text = '三択ロース'
    buttons = [
      ["ロース", "roast1", "primary"],
      ["ロース", "roast2", "danger"],
      ["ロース", "roast3"]
    ]
    at = generateChoice "santa", "good", text, buttons, (user, channel, action, text, original)->
    ut.sendAttachment res.envelope.room, [at]
