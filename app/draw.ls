
color = \black; width = 2
sid = (new Date!).get-time!
paths = {}

$ \#drawpad .attr \width, window.inner-width
$ \#drawpad .attr \height, window.inner-height
$ \#drawpad .attr \width, window.inner-width
$ \#drawpad .attr \height, window.inner-height

/*
$.ajax do
  url: \get-port
  data: key: cookie.get \key
  success: ->
*/

socket = io.connect "http://iwonder.tw:10000/"

socket.emit \ping, some: \data

socket.on \pong, (data) ->
  console.log( 'socket: server said pong (4)', data );

socket.on \draw, (data) ->
  draw data.x * window.inner-width, data.y * window.inner-height, data.color, data.width, data.id, data.type


!function on-mouse-down
  sid := (new Date!).get-time!
  x = it.point.x;
  y = it.point.y;
  draw x, y, color, width, sid, 0
  emit x, y, color, width, sid, 0

!function on-mouse-drag
  x = it.point.x
  y = it.point.y
  draw x, y, color, width, sid, 1
  emit x, y, color, width, sid, 1

!function on-mouse-up
  x = it.point.x
  y = it.point.y
  draw x, y, color, width, sid, 2
  emit x, y, color, width, sid, 2

!function draw x, y, color, width, id, type
  if type is 0 then paths[id] = new Path!
  if type is 2 then paths[id].smooth!
  paths[id].stroke-color = color
  paths[id].stroke-width = 2
  paths[id].add new Point x, y
  view.draw!

!function emit x, y, color, width, id, type
  x = x / window.inner-width
  y = y / window.inner-height
  data = do
    x: x, y: y, width: width
    color: color, id: id, type: type

  socket.emit \draw, data, sid


