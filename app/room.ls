key  = location.search.substring 1; salt = null; user = null; sid = null
$ \#drawpad .attr \width, window.inner-width
$ \#drawpad .attr \height, window.inner-height
paths = {}; color = \#000; width = 2;
socket = io.connect "http://iwonder.tw:9998/"
colors = <[#1f77b4 #ff7f0e #2ca02c #d62728 #9467bd #8c564b #e377c2 #7f7f7f #bcbd22 #17becf]>
clients = []

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
    on-approve: ->
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
              for u in it.clients
                clients.push u.user
                append-mouse u

            # Prepare video chat
            video-chat!

  .modal \show

# Socket

$ \#send-msg .click emit-msg
$ \#msg-input .focus ->
  $ window .keydown !->
    if it.which is 13 then emit-msg!

socket.on \draw, ->
  draw-line it

socket.on \msg,  ->
  show-msg it

socket.on \new,  ->
  clients.push it.user
  append-mouse it

socket.on \leave, ->
  d3.select '#'+it.user+'-mouse' .remove!
  i = clients.index-of it.user
  clients.splice i, 1

socket.on \mouse, ->
  mouse-move it

!function emit-msg
  msg = $ \#msg-input .val!
  if msg is '' then return
  show-msg data = {user: user, sid: sid, msg: msg, time: (new Date!).get-time!}
  socket.emit \msg, data, key
  $ \#msg-input .val ''

!function on-mouse-down
  x = it.point.x / window.inner-width
  y = it.point.y / window.inner-height
  draw-line x: x, y: y, color: color, width: width, type: 0, sid: sid
  socket.emit \draw, {x: x, y: y, color: color, width: width, type: 0, sid: sid}, key
  socket.emit \mouse, {x: x, y: y, user: user, sid: sid, salt: salt}, key

!function on-mouse-drag
  x = it.point.x / window.inner-width
  y = it.point.y / window.inner-height
  draw-line x: x, y: y, color: color, width: width, type: 1, sid: sid
  socket.emit \draw, {x: x, y: y, color: color, width: width, type: 1, sid: sid}, key
  socket.emit \mouse, {x: x, y: y, user: user, sid: sid, salt: salt}, key

!function on-mouse-up
  x = it.point.x / window.inner-width
  y = it.point.y / window.inner-height
  draw-line x: x, y: y, color: color, width: width, type: 2, sid: sid
  socket.emit \draw, {x: x, y: y, color: color, width: width, type: 2, sid: sid}, key
  socket.emit \mouse, {x: x, y: y, user: user, sid: sid, salt: salt}, key

!function on-mouse-move
  x = it.point.x / window.inner-width
  y = it.point.y / window.inner-height
  socket.emit \mouse, {x: x, y: y, user: user, sid: sid, salt: salt}, key

!function draw-line
  switch it.type
  | 0 => paths[it.sid] = new Path!
  | 2 => paths[it.sid].smooth!
  paths[it.sid].stroke-color = it.color
  paths[it.sid].stroke-width = it.width
  x = it.x * window.inner-width
  y = it.y * window.inner-height
  paths[it.sid].add new Point x, y
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
    .style \left, (it.x * window.inner-width)+\px
    .style \top , (it.y * window.inner-height)+\px

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

