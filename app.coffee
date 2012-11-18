express = require('express')
app = express.createServer()
io = require('socket.io').listen(app)
app.use(express.static(__dirname + '/public'))

app.listen(3003)


app.get '/', (req, res) ->
  res.sendfile(__dirname + '/index.html')

timeouts = {}
usernames = {}
user_sockets = {}

rooms = ['Redes 2','Algoritmos']

io.sockets.on 'connection', (socket) ->
	
  setInterval ->
    now = new Date()
    console.log socket.username
    if timeouts != {}
      if (now.getTime() - timeouts[socket.username].getTime()) > 120000
        socket.disconnect()
        console.log "Se desconecta"
  , 121000

  socket.on 'adduser', (username) ->
    socket.username = username
    timeouts[socket.username] = new Date()
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
    timeouts[socket.username] = new Date()
    io.sockets.in(socket.room).emit('updatechat', socket.username, data)
  
  socket.on 'switchRoom', (newroom) ->
    timeouts[socket.username] = new Date()
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
    timeouts[socket.username] = new Date()
    socket.emit 'showusers', usernames

  socket.on 'sendprivatechat', (data) ->
    timeouts[socket.username] = new Date()
    user_sockets[socket.username].emit('updateprivatechat', socket.username, data.message)
    user_sockets[data.username].emit('updateprivatechat', socket.username, data.message)
