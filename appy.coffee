app = require('express').createServer()
io = require('socket.io').listen(app)

app.listen(3003)
app.use(express.static(__dirname + '/public'));

app.get '/', (req, res) ->
  res.sendfile(__dirname + '/index.html')

usernames = {}
user_sockets = {}

rooms = ['Redes 2','Algoritmos']

io.sockets.on 'connection', (socket) ->
	
  socket.on 'adduser', (username) ->
    socket.username = username
    user_sockets[username] = socket
    socket.room = 'room1'
    if usernames[username]?
      socket.emit('updatechat', 'ERROR', "Username #{username} has already been taken")
    else
      usernames[username] = username
      socket.join('room1')
      socket.emit('updatechat', 'SERVER', 'you have connected to room1')
      socket.broadcast.to('room1').emit('updatechat', 'SERVER', username + ' has connected to this room')
      socket.emit('updaterooms', rooms, 'room1')

  socket.on 'sendchat', (data) ->
    io.sockets.in(socket.room).emit('updatechat', socket.username, data)
  
  socket.on 'switchRoom', (newroom) ->
    socket.leave(socket.room)
    socket.join(newroom)
    socket.emit('updatechat', 'SERVER', 'you have connected to '+ newroom)
    socket.broadcast.to(socket.room).emit('updatechat', 'SERVER', socket.username+' has left this room')
    socket.room = newroom
    socket.broadcast.to(newroom).emit('updatechat', 'SERVER', socket.username+' has joined this room')
    socket.emit('updaterooms', rooms, newroom)
  

  socket.on 'disconnect', ->
    delete usernames[socket.username]
    io.sockets.emit('updateusers', usernames)
    socket.broadcast.emit('updatechat', 'SERVER', socket.username + ' has disconnected')
    socket.leave(socket.room)

  socket.on 'getusers', (data) ->
    console.log usernames
    socket.emit 'showusers', usernames

  socket.on 'sendprivatechat', (data) ->
    user_sockets[socket.username].emit('updateprivatechat', socket.username, data.message)
    user_sockets[data.username].emit('updateprivatechat', socket.username, data.message)
