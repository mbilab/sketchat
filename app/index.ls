$ \#create-btn .click !->

  room = $ '#room input' .val!
  user = $ '#user input' .val!
  console.log room, user

  $.ajax do
    url: \/create-room
    data: room: room, user: user
    success: ->
      cookie.set \key,  it.key
      cookie.set \user, it.user
      location.href = location.href+'room.html?'+it.key

