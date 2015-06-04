var PORT_HEAD = 8880;
var PORT_TAIL = 8890;

for(var i = PORT_HEAD; i <= PORT_TAIL; i++) {
  open_drawing_port(i);
}


function open_drawing_port(port) {

  // Enable Socket.io
  var app = require('http').createServer(handler),
      io = require('socket.io').listen(app),
      static = require('node-static'); // for serving files

  // This will make all the files in the current folder
  // accessible from the web
  var fileServer = new static.Server('./');

  // This is the port for our web server.
  // you will need to go to http://localhost:8080 to see it
  app.listen(port);

  function handler (request, response) {

    request.addListener('end', function () {
      fileServer.serve(request, response);
    });
  }


  // A user connects to the server (opens a socket)
  io.sockets.on('connection', function (socket) {

    // (2): The server recieves a ping event
    // from the browser on this socket
    socket.on('ping', function ( data ) {

      console.log('socket: server recieves ping (2)');

      // (3): Emit a pong event all listening browsers
      // with the data from the ping event
      io.sockets.emit( 'pong', data );   

      console.log('socket: server sends pong to all (3)');

    });

    socket.on( 'drawCircle', function( data, session ) {

      console.log( "session " + session + " drew:");
      console.log( data );


      socket.broadcast.emit( 'drawCircle', data );

    });

    socket.on( 'drawLine', function( data, session ) {

      console.log( "session " + session + " drew:");
      console.log( data );


      socket.broadcast.emit( 'drawLine', data );

    });


  });

}
