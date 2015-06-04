require! <[fs gulp main-bower-files gulp-concat gulp-filter gulp-jade gulp-livereload gulp-livescript gulp-markdown gulp-print gulp-rename gulp-stylus gulp-util streamqueue tiny-lr]>

port = 9999
tiny-lr-port = 35729

config = JSON.parse fs.read-file-sync \config.json \utf8
paths =
  app: \app
  build: \public

tiny-lr-server = tiny-lr!
livereload = -> gulp-livereload tiny-lr-server

gulp.task \default <[watch]>
gulp.task \watch <[build server socket]> ->
  tiny-lr-server.listen tiny-lr-port, -> gulp-util.log it if it
  gulp.watch paths.app+\/**/*.jade, <[html]>
  gulp.watch paths.app+\/**/*.styl, <[css]>
  gulp.watch paths.app+\/**/*.ls, <[js]>
  gulp.watch paths.app+\/res/**, <[res]>

gulp.task \build <[html css js res]>
gulp.task \server ->
  require! <[express mysql MD5]>
  app = express!
  app.use require(\connect-livereload)!
  app.use express.static paths.build
  app.listen port
  gulp-util.log "Listening on port: #port for app".yellow
  connection = mysql.create-connection config.mysql
  connection.connect!

  app.get \/create-room, (req, res) ->
    room-id = (new Date!).get-time!
    key = MD5 room-id+req.query.room
    sql = "INSERT INTO user SET user_id=0, username='#{req.query.user}', room_id='#room-id', enter_time=now()"
    connection.query sql, (err) -> if err then throw err
    sql = "INSERT INTO room SET num=0, room_id='#room-id', name='#{req.query.room}', access_key='#key', port=10000, create_time=now()"
    connection.query sql, (err) -> if err then throw err
    res.content-type \json .send key: key, room: req.query.room, user: req.query.user

  app.get \/check-user, (req, res) ->
    console.log req.query
    sql = "SELECT * FROM room JOIN user ON user.room_id=room.room_id WHERE access_key='#{req.query.key}' AND user_active=1 AND room_active=1 AND username='#{req.query.user}'"
    connection.query sql, (err, rows, fields) !->
      if err then throw err
      if rows.length isnt 1 then check = false else check = true
      res.content-type \json .send check: check, key: req.query.key

  app.get \/add-user, (req, res) ->
    key = req.query.key
    sql = "SELECT * FROM room JOIN user ON user.room_id=room.room_id WHERE access_key='#{req.query.key}' AND user_active=1 AND room_active=1 AND username='#{req.query.user}'"
    connection.query sql, (err, rows, fields) !->
      if err then throw err
      if rows.length isnt 0
        res.content-type \json .send status: 0
      else
        sql = "SELECT * FROM room WHERE access_key='#{req.query.key}' AND room_active=1"
        connection.query sql, (err, rows, fields) !->
          if err then throw err
          if rows.length isnt 1
            res.content-type \json .send status: 2
          else
            sql = "INSERT INTO user SET user_id=0, username='#{req.query.user}', room_id='#{rows.0.room_id}', enter_time=now()"
            connection.query sql, (err) !->
              if err then throw err
              res.content-type \json .send status: 1, key: req.query.key, user: req.query.user

  app.get \/user-leave, (req, res) ->
   sql = "SELECT * FROM room JOIN user ON user.room_id=room.room_id WHERE access_key='#{req.query.key}' AND user_active=1 AND username='#{req.query.user}'"
   connection.query sql, (err, rows) !->
     if err then throw err
     if rows.length is 1
       user-id = rows.0.user_id
       sql = "UPDATE user SET user_active=0 WHERE user_id=#user-id"
       connection.query sql, (err) !->
         if err then throw err
         sql = "SELECT * FROM room JOIN user ON user.room_id=room.room_id WHERE access_key='#{req.query.key}' AND user_active=1"
         connection.query sql, (err, rows) !->
           if err then throw err
           if rows.length is 0
             sql = "UPDATE room SET room_active=0, destroy_time=now() WHERE access_key='#{req.query.key}'"
             connection.query sql, (err) !-> if err then throw err

gulp.task \html ->
  jade = gulp.src paths.app+\/**/*.jade .pipe gulp-jade {+pretty}
  streamqueue {+objectMode}
    .done jade
    .pipe gulp.dest paths.build
    .pipe livereload!

gulp.task \css ->
  css-bower = gulp.src main-bower-files! .pipe gulp-filter \**/*.css
  styl-app = gulp.src paths.app+\/*.styl .pipe gulp-stylus!
  css-app = gulp.src paths.app+\/vendor/*.css
  streamqueue {+objectMode}
    .done css-bower, styl-app, css-app
    .pipe gulp-concat \app.css
    .pipe gulp.dest paths.build
    .pipe livereload!

gulp.task \js ->
  js-bower = gulp.src main-bower-files! .pipe gulp-filter \**/*.js
  js-app = gulp.src paths.app+\/vendor/*.js
  ls-app = gulp.src paths.app+\/app.ls .pipe gulp-livescript {+bare}
  streamqueue {+objectMode}
    .done js-bower, js-app, ls-app
    .pipe gulp-concat \app.js
    .pipe gulp.dest paths.build
    .pipe livereload!
  gulp.src paths.app+\/*.ls .pipe gulp-livescript {+bare}
    .pipe gulp.dest paths.build
    .pipe livereload!

gulp.task \res ->
  gulp.src \bower_components/semantic-ui/dist/themes/**
    .pipe gulp.dest paths.build+\/themes
  gulp.src paths.app+\/res/**
    .pipe gulp.dest paths.build+\/res
    .pipe livereload!

gulp.task \socket ->
  for i from 10000 to 10500 then create-socket-server i
  !function create-socket-server
    app = require \http .create-server handler .listen it
    io = require \socket.io .listen app
    ns = require \node-static
    gulp-util.log "Listening on port: #it for socket".yellow

    io.sockets.on \connection, (socket) ->

      console.log \connect!
      socket.on \ping, (data) ->
        io.sockets.emit \pong, data

      socket.on \draw, (data, session) ->
        socket.broadcast.emit \draw, data

  !function handler req, res
    req.add-listener \end, -> console.log \end

# vi:et:ft=ls:nowrap:sw=2:ts=2
