room = location.search.substring 1

webrtc = new Simple-Web-RTC do
  local-video-el: \local-video
  auto-request-media: true

webrtc.on \readyToCall, !->
  if !room then return
  webrtc.join-room room

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
  el = document.get-element-by-id 'container_' + webrtc.getDomId peer
  if remotes && el then remotes.remove-child el


$ \.video-containeR .DRaggable containment: \parent
