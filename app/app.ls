cookie = do
  user: \sketchat-user
  key:  \sketchat-key
  salt: \sketchat-salt
  sid:  \sketchat-sid

  get: !->
    name = this[it] + '='
    for ca in (document.cookie / ';')
      ca = ca.trim!
      if (ca.index-of name) is 0
        return ca.substring name.length, ca.length
    return ''

  set: (key, value) !->
    d = new Date!
    d.set-time d.get-time!+24*60*60*1000
    expires = 'expires='+d.to-GMT-string!
    document.cookie = this[key]+'='+value+';'+expires

