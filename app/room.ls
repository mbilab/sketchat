key = location.search.substring 1
$ \.video-container .draggable containment: \parent

$.ajax do
  url: \/check-user
  data: key: key, user: (cookie.get \user)
  success: !->
    if !it.check then enter-name-modal it.key
    else video-chat!

window.onunload = ->
  $.ajax do
    url: \/user-leave
    data: key: key, user: (cookie.get \user)

function enter-name-modal key
  $ \#enter-name .modal closable: false .modal do
    on-deny: ->
      location.href = (location.href.split \/room.html).0
    on-approve: ->
      user = $ '#enter-name input' .val!
      if user is '' then location.href = (location.href.split \/room.html).0
      $.ajax do
        url: \/add-user
        data: key: key, user: user
        success: !->
          switch it.status
          | 2 =>
            location.href = (location.href.split \/room.html).0
          | 1 =>
            cookie.set \key,  it.key
            cookie.set \user, it.user
            video-chat!
          | 0 =>
            set-timeout ->
              $ '#enter-name .form' .add-class \error
              enter-name-modal key
  .modal \show

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


