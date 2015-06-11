socket = io.connect "http://iwonder.tw:9998/"

# User identified parameters
key  = location.search.substring 1; salt = null; user = null; sid = null

# Drawing pad related parameters
stroke-color = \#000; stroke-width = 2; drawpad-ratio = 0.82
erase-status = false
$ \#drawpad .attr \width , drawpad-w = window.inner-width * drawpad-ratio
$ \#drawpad .attr \height, drawpad-h = window.inner-height

# Others initial values
colors = <[#1f77b4 #ff7f0e #2ca02c #d62728 #9467bd #8c564b #e377c2 #7f7f7f #bcbd22 #17becf]>

# Storing variables
clients = [] # Client list
paths = {}   # Drawling paths

# Drawing tool action
$ '.tabular.menu .item' .tab!
$ \#color-picker .spectrum do
  color: \#000 show-alpha: true
  clickout-fires-change: true
  preferred-format: \hex
  show-buttons: false
  move: ->
    stroke-color := it.to-hex-string!
    $ \#color-string .html ' &nbsp&nbsp;&nbsp;'+stroke-color

$ \#stroke-width-bar .on \change, ->
  stroke-width := this.value
  $ \#stroke-width-pixal .text ' '+this.value+'px'

$ \.erase-btn .click ->
  if erase-status then erase-status := false
  else erase-status := true

$ \#reset .click reset
$ \#undo  .click undo


# Verify room
$.ajax do
  url: \/check-room
  data: key: key
  success: !->
    switch it.res
    | 0, 1=>
      $ '#msg-modal .content' .text it.msg
      $ \#msg-modal .modal {-closable} .modal on-approve: ->
        location.href = (location.href / \room.html).0
      .modal \show
    | 2 =>
      add-user!

# User leave
window.add-event-listener \beforeunload, ->
  socket.emit \leave, {key: key, salt: salt, user: user, sid: sid}

# Create user
function add-user
  $ '#enter-name input' .val ''
  $ \#enter-name .modal {-closable} .modal do
    on-deny: ->
      location.href = (location.href.split \/room.html).0
    on-approve: submit-user
  .modal \show

function submit-user
  user := $ '#enter-name input' .val!
  if user is '' then location.href = location.href
  $.ajax do
    url: \/add-user
    data: key: key, user: user
    success: !->
      switch it.res
      | 0 =>
        $ '#msg-modal .content' .text it.msg
        $ \#msg-modal .modal {-closable} .modal on-approve: ->
          location.href = (location.href / \room.html).0
        .modal \show
      | 1 =>
        $ '#msg-modal .content' .text it.msg
        $ \#msg-modal .modal {-closable} .modal on-approve: add-user
          .modal \show
      | 2 =>
        # Assign cookie
        cookie.set \key , key  := it.key
        cookie.set \salt, salt := it.salt
        cookie.set \user, user := it.user
        # Create socket

        socket.emit \ping, do
          key:  cookie.get \key
          user: cookie.get \user
          salt: cookie.get \salt

        socket.on \pong, ->
          cookie.set \sid, sid := it.sid
          clients.push user
          d3.select \#user-list .append \p
            .style \color, colors[0]
            .style \font-weight, \bold
            .attr \id, user.user+'-list-item'
            .text user
          for u in it.clients
            clients.push u.user
            append-mouse u
            d3.select \#user-list .append \div
              .classed 'ui divider', true
              .attr \id, u.user+'-divider'
            d3.select \#user-list .append \p
              .style \color, colors[clients.index-of u.user]
              .style \font-weight, \bold
              .attr \id, u.user+'-list-item'
              .text u.user

          # Prepare video chat
          video-chat!


# Socket

$ '#msg-input input' .focus ->
  $ window .keydown !->
    if it.which is 13 then emit-msg!

socket.on \draw, ->
  draw-line it

socket.on \msg,  ->
  show-msg it

socket.on \new,  ->
  clients.push it.user
  append-mouse it
  d3.select \#user-list .append \div
    .classed 'ui divider', true
    .attr \id, it.user+'-divider'
  d3.select \#user-list .append \p
    .style \color, colors[clients.index-of it.user]
    .style \font-weight, \bold
    .attr \id, it.user+'-list-item'
    .text it.user

socket.on \leave, ->
  d3.select '#'+it.user+'-mouse' .remove!
  i = clients.index-of it.user
  clients.splice i, 1
  d3.select '#'+it.user+'-list-item' .remove!
  d3.select '#'+it.user+'-divider' .remove!

socket.on \mouse, ->
  mouse-move it

socket.on \reset, ->
  project.clear!
  view.draw!

socket.on \undo, ->
  paths[it.sid].pop!.remove!
  view.draw!

!function emit-msg
  msg = $ '#msg-input input' .val!
  if msg is '' then return
  show-msg data = {user: user, sid: sid, msg: msg, time: (new Date!).get-time!}
  socket.emit \msg, data, key
  $ '#msg-input input' .val ''

!function on-mouse-down
  x = it.point.x / (window.inner-width * drawpad-ratio)
  y = it.point.y / window.inner-height
  draw-line x: x, y: y, stroke-color: stroke-color, stroke-width: stroke-width, type: 0, sid: sid
  socket.emit \draw, {x: x, y: y, stroke-color: stroke-color, stroke-width: stroke-width, type: 0, sid: sid}, key
  socket.emit \mouse, {x: x, y: y, user: user, sid: sid, salt: salt}, key

!function on-mouse-drag
  x = it.point.x / (window.inner-width * drawpad-ratio)
  y = it.point.y / window.inner-height
  draw-line x: x, y: y, stroke-color: stroke-color, stroke-width: stroke-width, type: 1, sid: sid
  socket.emit \draw, {x: x, y: y, stroke-color: stroke-color, stroke-width: stroke-width, type: 1, sid: sid}, key
  socket.emit \mouse, {x: x, y: y, user: user, sid: sid, salt: salt}, key

!function on-mouse-up
  x = it.point.x / (window.inner-width * drawpad-ratio)
  y = it.point.y / window.inner-height
  draw-line x: x, y: y, stroke-color: stroke-color, stroke-width: stroke-width, type: 2, sid: sid
  socket.emit \draw, {x: x, y: y, stroke-color: stroke-color, stroke-width: stroke-width, type: 2, sid: sid}, key
  socket.emit \mouse, {x: x, y: y, user: user, sid: sid, salt: salt}, key

!function on-mouse-move
  x = it.point.x / (window.inner-width * drawpad-ratio)
  y = it.point.y / window.inner-height
  socket.emit \mouse, {x: x, y: y, user: user, sid: sid, salt: salt}, key

!function draw-line
  if paths[it.sid] is undefined then paths[it.sid] = []
  switch it.type
  | 0 => paths[it.sid].push new Path!
  | 2 => paths[it.sid][paths[it.sid].length - 1].smooth!
  paths[it.sid][paths[it.sid].length - 1].stroke-color = it.stroke-color
  paths[it.sid][paths[it.sid].length - 1].stroke-width = it.stroke-width
  x = it.x * drawpad-w
  y = it.y * drawpad-h
  paths[it.sid][paths[it.sid].length - 1].add new Point x, y
  view.draw!

!function show-msg
  div = d3.select \#msg-list .append \div
    .classed 'msg-block', true
  div.append \span
    .classed 'msg-sender', true
    .style \color, colors[clients.index-of it.user]
    .text it.user+' ('+((new Date it.time).to-string!/' ').4+'):'
  div.append \div
    .classed 'msg-content', true
    .text it.msg
  div.append \div
    .classed 'ui divider', true
  $ \#msg-list .animate {scroll-top: $ \#msg-list .height! }, \fast

!function append-mouse
  d3.select \#room .append \div
    .style \position, \absolute
    .style \font-weight, \bold
    .style \color, colors[clients.index-of it.user]
    .style \left, \0px
    .style \top, \-100px
    .attr \id, it.user+'-mouse'
    .text it.user

!function mouse-move
  d3.select '#'+it.user+'-mouse'
    .style \left, (it.x * drawpad-w)+\px
    .style \top , (it.y * drawpad-h)+\px

!function reset
  socket.emit \reset, {}, key
  project.clear!
  view.draw!

!function undo
  socket.emit \undo, {sid: sid}, key
  paths[sid].pop!.remove!
  view.draw!

function video-chat

  webrtc = new Simple-Web-RTC do
    local-video-el: \local-video
    auto-request-media: true

  webrtc.on \readyToCall, !->
    if !key then return
    webrtc.join-room key

  webrtc.on \videoAdded, (video, peer) !->
    remotes = document.get-element-by-id \room
    container = document.createElement \div
    container.class-name = \video-container
    container.id = 'container_'+webrtc.get-dom-id peer
    container.append-child video
    $ container .draggable containment: \parent

    video.oncontextmenu = -> false
    remotes.append-child container

  webrtc.on \videoRemoved, (video, peer) ->
    remotes = document.get-element-by-id \room
    el = document.get-element-by-id 'container_' + webrtc.get-dom-id peer
    if remotes && el then remotes.remove-child el

