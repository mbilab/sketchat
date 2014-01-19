
tool.minDistance = 10;

var port_url;
var ary = location.search.substr(1).split("?", 2);
var room_key = ary[0];
var user_name = ary[1];


function randomColor() {
  
  return {
    red: 0,
    green: Math.random(),
    blue: Math.random(),
    //alpha: ( Math.random() * 0.25 ) + 0.05
  };

}

$.ajax({
  url: './room-admin/set-drawing-port.php?room-key=' + room_key,
  type: 'GET',
  async: false,
  dataType: 'text',
  success: function(msg) { 
    port_url = 'http://59.127.174.192:' + msg;
  }
});

var paths = {}, color;
var sessionId = Math.floor( ( Math.random() * 10000 ) + 1);
// Connect to the nodeJs Server
var socket = io.connect(port_url);

var canvas = $('#paper')[0];
var wx = window.innerWidth,
    wy = window.innerHeight;

canvas.width = wx;
canvas.height = wy;
// (1): Send a ping event with 
// some data to the server
console.log( "socket: browser says ping (1)" )
socket.emit('ping', { some: 'data' } );

// (4): When the browser recieves a pong event
// console log a message and the events data
socket.on('pong', function (data) {
	console.log( 'socket: server said pong (4)', data );
});
function onMouseDown(event) {
  var x = event.point.x;
  var y = event.point.y;
  console.log(event.point);
  console.log(x);
  console.log(y);
  color = randomColor();
  drawLine(x, y, color, sessionId, 0);
  emitLine(x, y, color, sessionId, 0);

}

function onMouseDrag(event) {
  var x = event.point.x;
  var y = event.point.y;
  
  drawLine(x, y, color, sessionId, 1);
  emitLine(x, y, color, sessionId, 1);
}

function onMouseUp(event) {
  var x = event.point.x;
  var y = event.point.y;

  drawLine(x, y, color, sessionId, 2);
  emitLine(x, y, color, sessionId, 2);

  console.log(project.activeLayer);
}

function drawLine( x, y, color, id, type) {
  if(type == 0){
    paths[id] = new Path();
  }
  if(type == 2){
    paths[id].smooth();
  }
  paths[id].strokeColor = color;
  paths[id].add(new Point(x, y));

  view.draw();
}

function emitLine( x, y, color, id, type) {
  
  x = x / window.innerWidth;
  y = y / window.innerHeight;
  // An object to describe the circle's draw data
  var data = {
    x: x,
    y: y,
    color: color,
    id: id,
    type: type
  };

  // send a 'drawCircle' event with data and sessionId to the server
  socket.emit( 'drawLine', data, sessionId )

  // Lets have a look at the data we're sending
  console.log( data )

}

socket.on( 'drawLine', function( data ) { 
  drawLine( data.x * window.innerWidth, data.y * window.innerHeight, data.color, data.id, data.type);
});

$("#clean-button").on("click", function(e) {
 project.activeLayer.removeChildren();
 view.draw();
 console.log('clear');
}); 
