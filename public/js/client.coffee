socket = io.connect 'http://localhost:3003', {'connect timeout': 1000}



socket.on 'connect', ->
  socket.emit('adduser', prompt("What's your name?"))

socket.on 'showusers', (usernames) ->
  $('#private_chat_wrapper ul').html("")
  $.each usernames, (key, value) ->
    $('#private_chat_wrapper ul').append("<li> <a href='#'>#{value}</a></li>")

socket.on 'updateprivatechat', (username, data) ->
  if !socket.private_chat_user?
    socket.private_chat_user = username
  $("#private_conversation").append("<b>#{username}:</b> #{data}<br>")

socket.on 'updatechat', (username, data) ->
  $('#conversation').append("<b>#{username}:</b> #{data}<br>")
  if(username == 'ERROR')
    socket.emit('adduser', prompt("What's your name?"))

socket.on 'updaterooms', (rooms, current_room) ->
  $('#rooms').empty()
  $.each rooms, (key, value) ->
    if(value == current_room)
      $('#rooms').append("<div>#{value}</div>")
    else
      $('#rooms').append("<div><a href='#' onclick='switchRoom(#{value})'>#{value}</a></div>")

switchRoom: (room)->
  socket.emit('switchRoom', room)

$ ->
  $('#datasend').click () ->
    message = $('#data').val()
    $('#data').val('')
    socket.emit('sendchat', message)

  $('#private_datasend').click () ->
    message = $('#private_data').val()
    if !socket.private_chat_user?
      socket.private_chat_user = $('#private_chat_wrapper li.active:first a').text()
    $('#private_chat_wrapper ul').html(socket.private_chat_user)
    $('#private_data').val('')
    socket.emit('sendprivatechat', {username: socket.private_chat_user, message: message})

  $('#private_chat_trigger').click (e) ->
    socket.emit('getusers')

  $('#private_chat_wrapper a').live 'click', (e) ->
    $(this).parent().addClass('active')

  $('#data').keypress (e) ->
    if e.which == 13
      $(this).blur()
      $('#datasend').focus().click()
