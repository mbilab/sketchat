require! <[mysql sha256 node-uuid]>

module.exports = (app, config) !->

  pool = mysql.create-pool config.mysql
  (err, connection) <-! pool.get-connection

  app.get \/create-room, (req, res) !->
    create-room!
    function create-room
      key = sha256 config.crypt.key+sha256 node-uuid.v4!
      sql = "SELECT * FROM room WHERE access_key='#key' AND room_active=1"
      connection.query sql, (err, rows) !->
        if rows.length isnt 0
          create-room!
        else
          sql = "INSERT INTO room SET access_key='#key', create_time=now()"
          (err) <-! connection.query sql
          if err then throw err
          res.redirect "/room.html?#key"

  app.get \/check-room, (req, res) !->
    sql = "SELECT * FROM room WHERE access_key='#{req.query.key}'"
    connection.query sql, (err, rows) !->
      if err then throw err
      if rows.length isnt 1
        res.content-type \json .send res: 0, msg: 'The room is not exists.'
      else if rows.0.room_active is 0
        res.content-type \json .send res: 1, msg: 'The room is no longer available. Please create a new one'
      else
        res.content-type \json .send res: 2

  app.get \/add-user, (req, res) ->
    sql = "SELECT * FROM room WHERE access_key='#{req.query.key}'"
    connection.query sql, (err, rows) !->
      if err then throw err
      if rows.length isnt 1
        res.content-type \json .send res: 0, msg: 'The room is not avaiable.'
      else
        room-id = rows.0.room_id
        sql = "SELECT * FROM user WHERE name='#{req.query.user}' AND room_id=#room-id AND user_active=1"
        (err, rows) <-! connection.query sql
        if rows.length isnt 0
          res.content-type \json .send res: 1, msg: 'The user name has been used.'
        else
          salt = sha256 config.crypt.key+sha256 node-uuid.v4!
          sql = "INSERT INTO user SET salt='#salt', name='#{req.query.user}', room_id=#room-id, enter_time=now()"
          (err) <-! connection.query sql
          if err then throw err
          res.content-type \json .send res: 2, salt: salt, key: req.query.key, user: req.query.user

  app.get \/user-leave, (req, res) ->
    sql =  "SELECT * FROM user JOIN room ON user.room_id=room.room_id "
    sql += "WHERE access_key='#{req.query.key}' AND salt='#{req.query.salt}' AND name='#{req.query.user}' "
    sql += "AND user_active=1 AND room_active=1"
    connection.query sql, (err, rows) !->
      if err then throw err
      if rows.length isnt 1 then return
      sql = "UPDATE user SET user_active=0, leave_time=now() WHERE user_id=#{rows.0.user_id}"
      (err) <-! connection.query sql
      if err then throw err
      sql = "SELECT * FROM room JOIN user ON user.room_id=room.room_id WHERE access_key='#{req.query.key}' AND user_active=1"
      (err, rows) <-! connection.query sql
      if err then throw err
      if rows.length isnt 0 then return
      sql = "UPDATE room SET room_active=0, destroy_time=now() WHERE access_key='#{req.query.key}'"
      (err) <-! connection.query sql
      if err then throw err

