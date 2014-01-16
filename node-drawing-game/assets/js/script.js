$(function(){

  // This demo depends on the canvas element
  if(!('getContext' in document.createElement('canvas'))){
    alert('Sorry, it looks like your browser does not support canvas!');
    return false;
  }
  //console.log('s');
  //The URL of your web server (the port is set in app.js)

  var ary = location.search.substr(1).split("?", 2);
  var room_key = ary[0];
  var user_name = ary[1];

  //Ajax to get the drawing port
  $.ajax({
    url: './room-admin/set-drawing-port.php?room-key=' + room_key,
    type: 'GET',
    dataType: 'text',
    success: function(msg) { 

      var port_url = 'http://59.127.174.192:' + msg;
      var doc = $(document);
      var win = $(window);
      var canvas = $('#paper');
      var ctx = canvas[0].getContext('2d');
      var instructions = $('#instructions');
      var offset  = $('#draw').offset();
      var wx = window.innerWidth;
      var wy = window.innerHeight;
      var conf_height_string = $(".gridster ul").css("height");
      var conf_height = conf_height_string.substr(0, conf_height_string.length - 2); 
      console.log(conf_height);

      $('canvas')[0].width = wx;
      $('canvas')[0].height = wy;

      // Generate an unique ID
      var id = Math.round($.now()*Math.random());

      // A flag for drawing activity
      var drawing = false;

      var clients = {};
      var cursors = {};

      var socket = io.connect(port_url);

      socket.on('moving', function (data) {

	if(! (data.id in clients)){
	  // a new user has come online. create a cursor for them
	  cursors[data.id] = $('<div class="cursor">').appendTo('#cursors');
	}

	// Move the mouse pointer
	cursors[data.id].css({
	  'left' : data.x * wx + offset.left,
	  'top' : data.y * wy + offset.top - conf_height
	});
	//console.log(data.x + 'px' + data.y +'px\n');	
	// Is the user drawing?
	if(data.drawing && clients[data.id]){

	  // Draw a line on the canvas. clients[data.id] holds
	  // the previous position of this user's mouse pointer

	  drawLine(clients[data.id].x * wx, clients[data.id].y * wy, data.x * wx, data.y * wy);
	}

	// Saving the current client state
	clients[data.id] = data;
	clients[data.id].updated = $.now();
      });

      var prev = {};

      canvas.on('mousedown',function(e){
	console.log(e);
	e.preventDefault();
	drawing = true;
	prev.x = e.offsetX/wx;
	prev.y = e.offsetY/wy;
	console.log(prev);
	// Hide the instructions
	instructions.fadeOut();
      });

      doc.bind('mouseup mouseleave',function(){
	drawing = false;
      });

      var lastEmit = $.now();

      doc.on('mousemove',function(e){
	if($.now() - lastEmit > 1){
	  socket.emit('mousemove',{
	    'x': e.offsetX/wx,
	    'y': e.offsetY/wy,
	    'drawing': drawing,
	    'id': id
	  });
	  lastEmit = $.now();
	}

	// Draw a line for the current user's movement, as it is
	// not received in the socket.on('moving') event above

	if(drawing){
	  drawLine(prev.x*wx, prev.y*wy, e.offsetX, e.offsetY);
	  prev.x = e.offsetX/wx;
	  prev.y = e.offsetY/wy;
	}
      });

      // Remove inactive clients after 10 seconds of inactivity
      setInterval(function(){

	for(ident in clients){
	  if($.now() - clients[ident].updated > 10000){

	    // Last update was more than 10 seconds ago. 
	    // This user has probably closed the page

	    cursors[ident].remove();
	    delete clients[ident];
	    delete cursors[ident];
	  }
	}

      },10000);

      function drawLine(fromx, fromy, tox, toy){
	ctx.moveTo(fromx, fromy);
	ctx.lineTo(tox, toy);
	ctx.stroke();
      }
    }
  });

});
