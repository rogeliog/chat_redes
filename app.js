// Generated by CoffeeScript 1.3.3
(function() {
  var app, io, rooms, user_sockets, usernames;

  app = require('express').createServer();

  io = require('socket.io').listen(app);

  app.listen(3003);

  app.get('/', function(req, res) {
    return res.sendfile(__dirname + '/index.html');
  });

  usernames = {};

  user_sockets = {};

  rooms = ['Redes 2', 'Algoritmos'];

  io.sockets.on('connection', function(socket) {
    socket.on('adduser', function(username) {
      socket.username = username;
      user_sockets[username] = socket;
      socket.room = 'room1';
      if (usernames[username] != null) {
        return socket.emit('updatechat', 'ERROR', "Username " + username + " has already been taken");
      } else {
        usernames[username] = username;
        socket.join('room1');
        socket.emit('updatechat', 'SERVER', 'you have connected to room1');
        socket.broadcast.to('room1').emit('updatechat', 'SERVER', username + ' has connected to this room');
        return socket.emit('updaterooms', rooms, 'room1');
      }
    });
    socket.on('sendchat', function(data) {
      return io.sockets["in"](socket.room).emit('updatechat', socket.username, data);
    });
    socket.on('switchRoom', function(newroom) {
      socket.leave(socket.room);
      socket.join(newroom);
      socket.emit('updatechat', 'SERVER', 'you have connected to ' + newroom);
      socket.broadcast.to(socket.room).emit('updatechat', 'SERVER', socket.username + ' has left this room');
      socket.room = newroom;
      socket.broadcast.to(newroom).emit('updatechat', 'SERVER', socket.username + ' has joined this room');
      return socket.emit('updaterooms', rooms, newroom);
    });
    socket.on('disconnect', function() {
      delete usernames[socket.username];
      io.sockets.emit('updateusers', usernames);
      socket.broadcast.emit('updatechat', 'SERVER', socket.username + ' has disconnected');
      return socket.leave(socket.room);
    });
    socket.on('getusers', function(data) {
      console.log(usernames);
      return socket.emit('showusers', usernames);
    });
    return socket.on('sendprivatechat', function(data) {
      user_sockets[socket.username].emit('updateprivatechat', socket.username, data.message);
      return user_sockets[data.username].emit('updateprivatechat', socket.username, data.message);
    });
  });

}).call(this);
