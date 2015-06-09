require! <[mysql sha256 gulp-util colors]>

module.exports = (io, config) !->

  connection = mysql.create-connection config.mysql
  connection.connect!
  clients = {}

  set-interval ->
    sql = "SELECT * FROM room WHERE room_active=0 AND clean=0"
    (err, rows) <-! connection.query sql
    if err then throw err
    r <-! rows.for-each
    if clients[r.access_key]
      delete clients[r.access_key]
      sql = "UPDATE room SET clean=1 WHERE room_id=#{r.room_id}"
      (err) <-! connection.query sql
      if err then throw err
  , 1000

  set-interval ->
    sql = "SELECT * FROM user JOIN room ON room.room_id=user.room_id WHERE user_active=0 AND user.clean=0"
    (err, rows) <-! connection.query sql
    if err then throw err
    r <-! rows.for-each
    if clients[r.access_key] and clients[r.access_key][r.salt+'-'+r.session_id]
      delete clients[r.access_key][r.salt+'-'+r.session_id]
      sql = "UPDATE user SET clean=1 WHERE user_id=#{r.user_id}"
      (err) <-! connection.query sql
      if err then throw err
  , 1000

  set-interval ->
    room-num = (Object.keys clients).length
    user-num = 0
    for c in Object.keys clients then user-num += (Object.keys clients[c]).length
    gulp-util.log "[#{'Report'.cyan}] room: #{room-num.to-string!magenta}, user: #{user-num.to-string!magenta}"
  , 5000

  io.sockets.on \connection, (socket) !->

    socket.on \ping, !->
      sql =  "SELECT * FROM user JOIN room ON room.room_id=user.room_id "
      sql += "WHERE name='#{it.user}' AND access_key='#{it.key}' AND salt='#{it.salt}' AND user_active=1 AND room_active=1"
      connection.query sql, (err, rows, fields) !->
        if rows.length isnt 1
          io.sockets.emit \pong, req: 0
        else
          if clients[rows.0.access_key] is undefined then clients[rows.0.access_key] = {}
          clients[rows.0.access_key][rows.0.salt+'-'+socket.id] = 1
          socket.join rows.0.access_key
          sql = "UPDATE user SET session_id='#{socket.id}' WHERE user_id=#{rows.0.user_id}"
          connection.query sql, (err) ->
            if err then throw err
            io.sockets.emit \pong, req: 1, sid: socket.id

    socket.on \draw, (data, key) ->
      socket.broadcast.in key .emit \draw, data

    socket.on \msg, (data, key) ->
      socket.broadcast.in key .emit \msg, data

    socket.on \mouse, (data, key) ->
      console.log data
      socket.broadcast.in key .emit \mouse, data

