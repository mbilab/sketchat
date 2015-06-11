require! <[mysql sha256 gulp-util colors]>

module.exports = (io, config) !->

  connection = mysql.create-connection config.mysql
  connection.connect!
  clients = {}

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
          c = (Object.keys clients[rows.0.access_key]).map -> user: (it / \-).2
          clients[rows.0.access_key][rows.0.salt+'-'+socket.id+'-'+rows.0.name] = 1
          socket.join rows.0.access_key
          sql = "UPDATE user SET session_id='#{socket.id}' WHERE user_id=#{rows.0.user_id}"
          connection.query sql, (err) ->
            if err then throw err
            socket.emit \pong, {req: 1, sid: socket.id, clients: c}
            socket.broadcast.in rows.0.access_key .emit \new, do
              user: rows.0.name
              sid: socket.id
              salt: rows.0.salt
              key: rows.0.access_key

    socket.on \leave, !->
      key = it.key; salt = it.salt; user = it.user
      sql =  "SELECT * FROM user JOIN room ON user.room_id=room.room_id "
      sql += "WHERE access_key='#key' AND salt='#salt' AND name='#user' "
      sql += "AND user_active=1 AND room_active=1"
      (err, rows) <-! connection.query sql
      if err then throw err
      if rows.length isnt 1 then return
      sid = rows.0.session_id
      rid = rows.0.room_id

      sql = "UPDATE user SET user_active=0, leave_time=now() WHERE user_id=#{rows.0.user_id}"
      (err) <-! connection.query sql
      if err then throw err
      if clients[key] and clients[key][salt+'-'+sid+'-'+user]
        delete clients[key][salt+'-'+sid+'-'+user]
        socket.broadcast.in key .emit \leave, user: user

      sql = "SELECT * FROM user WHERE room_id=#rid AND user_active=1"
      (err, rows) <-! connection.query sql
      if err then throw err

      if rows.length isnt 0 then return

      sql = "UPDATE room SET room_active=0, destroy_time=now() WHERE access_key='#key'"
      (err) <-! connection.query sql
      if err then throw err

      if clients[key] then delete clients[key]

    socket.on \draw, (data, key) !->
      socket.broadcast.in key .emit \draw, data

    socket.on \msg, (data, key) !->
      socket.broadcast.in key .emit \msg, data

    socket.on \mouse, (data, key) !->
      socket.broadcast.in key .emit \mouse, data

    socket.on \reset, (data, key) !->
      socket.broadcast.in key .emit \reset, data

    socket.on \undo, (data, key) !->
      socket.broadcast.in key .emit \undo, data

