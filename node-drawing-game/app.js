// Including libraries

//var port = parseInt(process.argv[2]);
//var port = 5000;

var PORT_HEAD = 5000;
var PORT_TAIL = 5020;

for(var i = PORT_HEAD; i <= PORT_TAIL; i++) {
  open_drawing_port(i);
}


function open_drawing_port(port) {

  var app = require('http').createServer(handler),
      io = require('socket.io').listen(app),
      static = require('node-static'); // for serving files

  // This will make all the files in the current folder
  // accessible from the web
  var fileServer = new static.Server('./');

  // This is the port for our web server.
  // you will need to go to http://localhost:8080 to see it
  app.listen(port);

  // If the URL of the socket server is opened in a browser
  function handler (request, response) {

    request.addListener('end', function () {
      fileServer.serve(request, response);
    });
  }

  // Delete this row if you want to see debug messages
  io.set('log level', 1);

  // Listen for incoming connections from clients
  io.sockets.on('connection', function (socket) {

    // Start listening for mouse move events
    socket.on('mousemove', function (data) {

      // This line sends the event (broadcasts it)
      // to everyone except the originating client.
      socket.broadcast.emit('moving', data);
    });
  });

}
