
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

var isMobile = {
  Android: function() { return navigator.userAgent.match(/Android/i); },
  BlackBerry: function() { return navigator.userAgent.match(/BlackBerry/i); },
  iOS: function() { return navigator.userAgent.match(/iPhone|iPad|iPod/i); },
  Opera: function() { return navigator.userAgent.match(/Opera Mini/i); },
  Windows: function() { return navigator.userAgent.match(/IEMobile/i); },
  any: function() { return (isMobile.Android() || isMobile.BlackBerry() || isMobile.iOS() || isMobile.Opera() || isMobile.Windows()); }
};

var eventtype = isMobile.any() ? 'touchstart' : 'click';
var paths = {}, color= 'black', width = 4;
var sessionId = Math.floor( ( Math.random() * 10000 ) + 1);
// Connect to the nodeJs Server
var socket = io.connect(port_url);

var canvas = $('#paper')[0];
var wx = window.innerWidth,
    wy = window.innerHeight;

$('#red').on(eventtype, function(){color = 'red'; $('#svg_circle').attr('fill', color);});
$('#green').on(eventtype, function(){color = 'green'; $('#svg_circle').attr('fill', color);});
$('#yellow').on(eventtype, function(){color = 'yellow'; $('#svg_circle').attr('fill', color);});
$('#black').on(eventtype, function(){color = 'black'; $('#svg_circle').attr('fill', color);});
$('#DarkBlue').on(eventtype, function(){color = '#00008B'; $('#svg_circle').attr('fill', color);});
$('#DarkOrange').on(eventtype, function(){color = '#FF8C00'; $('#svg_circle').attr('fill', color);});
$('#Violet').on(eventtype, function(){color = '#EE82EE'; $('#svg_circle').attr('fill', color);});
$('#DarkMagenta').on(eventtype, function(){color = '#8B008B'; $('#svg_circle').attr('fill', color);});
$('#eraser').on(eventtype, function(){color='white'; width = 15;});
$('#thin').on(eventtype, function(){width = 2;});
$('#normal').on(eventtype, function(){width = 4;});
$('#fat').on(eventtype, function(){width = 6;});

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
  drawLine(x, y, color, width, sessionId, 0);
  emitLine(x, y, color, width, sessionId, 0);

}

function onMouseDrag(event) {
  var x = event.point.x;
  var y = event.point.y;

  drawLine(x, y, color, width, sessionId, 1);
  emitLine(x, y, color, width, sessionId, 1);
}

function onMouseUp(event) {
  var x = event.point.x;
  var y = event.point.y;

  drawLine(x, y, color, width, sessionId, 2);
  emitLine(x, y, color, width, sessionId, 2);

  console.log(project.activeLayer);
}

function drawLine( x, y, color, width, id, type) {
  if(type == 0){
    paths[id] = new Path();
  }
  if(type == 2){
    paths[id].smooth();
  }
  paths[id].strokeColor = color;
  paths[id].strokeWidth = width;
  paths[id].add(new Point(x, y));

  view.draw();
}

function emitLine( x, y, color, width, id, type) {

  x = x / window.innerWidth;
  y = y / window.innerHeight;
  // An object to describe the circle's draw data
  var data = {
    x: x,
    y: y,
    color: color,
    width: width,
    id: id,
    type: type
  };

  // send a 'drawCircle' event with data and sessionId to the server
  socket.emit( 'drawLine', data, sessionId )

    // Lets have a look at the data we're sending
    console.log( data )

}

socket.on( 'drawLine', function( data ) { 
  drawLine( data.x * window.innerWidth, data.y * window.innerHeight, data.color, data.width, data.id, data.type);
});

$("#clean-button").on("click", function(e) {
  project.activeLayer.removeChildren();
  view.draw();
  console.log('clear');
}); 
