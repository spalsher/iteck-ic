const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Message = require('../models/Message');

// Store active connections
const activeUsers = new Map(); // userId -> socketId
const socketToUser = new Map(); // socketId -> userId

module.exports = (io) => {
  // Socket.io middleware for authentication
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token;
      
      if (!token) {
        return next(new Error('Authentication error'));
      }

      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findById(decoded.id);
      
      if (!user) {
        return next(new Error('User not found'));
      }

      socket.userId = user._id.toString();
      socket.username = user.username;
      next();
    } catch (error) {
      next(new Error('Authentication error'));
    }
  });

  io.on('connection', (socket) => {
    console.log(`User connected: ${socket.username} (${socket.id})`);

    // Store user connection
    activeUsers.set(socket.userId, socket.id);
    socketToUser.set(socket.id, socket.userId);

    // Update user online status
    User.findByIdAndUpdate(socket.userId, {
      isOnline: true,
      socketId: socket.id,
      lastSeen: Date.now()
    }).catch(err => console.error('Error updating user status:', err));

    // Notify contacts that user is online
    socket.broadcast.emit('user-online', {
      userId: socket.userId,
      username: socket.username
    });

    // Join user's personal room
    socket.join(socket.userId);

    // Handle WebRTC signaling events
    
    // Call request
    socket.on('call-request', async (data) => {
      const { to, callType, callerInfo } = data;
      const targetSocketId = activeUsers.get(to);
      
      console.log(`📞 Call request from ${socket.username} (${socket.userId}) to ${to}`);
      console.log(`Call type: ${callType}, Target socket: ${targetSocketId}`);
      
      if (targetSocketId) {
        // Get caller's full info from database
        const caller = await User.findById(socket.userId);
        
        io.to(targetSocketId).emit('call-request', {
          from: socket.userId,
          callType,
          callerInfo: {
            userId: socket.userId,
            username: socket.username,
            displayName: caller?.displayName || callerInfo?.displayName || socket.username,
            avatar: caller?.avatar || callerInfo?.avatar || ''
          }
        });
        
        console.log('✅ Call request sent to recipient');
      } else {
        console.log('❌ User is offline');
        socket.emit('call-failed', {
          message: 'User is offline'
        });
      }
    });

    // Call accept
    socket.on('call-accept', (data) => {
      const { to } = data;
      const targetSocketId = activeUsers.get(to);
      
      if (targetSocketId) {
        io.to(targetSocketId).emit('call-accept', {
          from: socket.userId
        });
      }
    });

    // Call reject
    socket.on('call-reject', (data) => {
      const { to, reason } = data;
      const targetSocketId = activeUsers.get(to);
      
      if (targetSocketId) {
        io.to(targetSocketId).emit('call-reject', {
          from: socket.userId,
          reason
        });
      }
    });

    // Call end
    socket.on('call-end', (data) => {
      const { to } = data;
      const targetSocketId = activeUsers.get(to);
      
      if (targetSocketId) {
        io.to(targetSocketId).emit('call-end', {
          from: socket.userId
        });
      }
    });

    // WebRTC offer
    socket.on('offer', (data) => {
      const { to, offer } = data;
      const targetSocketId = activeUsers.get(to);
      
      if (targetSocketId) {
        io.to(targetSocketId).emit('offer', {
          from: socket.userId,
          offer
        });
      }
    });

    // WebRTC answer
    socket.on('answer', (data) => {
      const { to, answer } = data;
      const targetSocketId = activeUsers.get(to);
      
      if (targetSocketId) {
        io.to(targetSocketId).emit('answer', {
          from: socket.userId,
          answer
        });
      }
    });

    // ICE candidate exchange
    socket.on('ice-candidate', (data) => {
      const { to, candidate } = data;
      const targetSocketId = activeUsers.get(to);
      
      if (targetSocketId) {
        io.to(targetSocketId).emit('ice-candidate', {
          from: socket.userId,
          candidate
        });
      }
    });

    // Text message (fallback/signaling)
    socket.on('message', async (data) => {
      const { to, message, timestamp, type, mediaUrl, thumbnailUrl } = data;
      
      try {
        // Save message to database
        const savedMessage = await Message.create({
          senderId: socket.userId,
          receiverId: to,
          content: message,
          type: type || 'text',
          mediaUrl,
          thumbnailUrl,
          createdAt: timestamp ? new Date(timestamp) : new Date()
        });

        // Send to recipient if online
        const targetSocketId = activeUsers.get(to);
        if (targetSocketId) {
          io.to(targetSocketId).emit('message', {
            id: savedMessage._id,
            from: socket.userId,
            to: to,
            message,
            content: message,
            type: type || 'text',
            mediaUrl,
            thumbnailUrl,
            timestamp: savedMessage.createdAt.getTime(),
            isDelivered: true
          });

          // Mark as delivered
          savedMessage.isDelivered = true;
          await savedMessage.save();
        }

        // Send acknowledgment back to sender
        socket.emit('message-sent', {
          id: savedMessage._id,
          timestamp: savedMessage.createdAt.getTime(),
          isDelivered: !!targetSocketId
        });
      } catch (error) {
        console.error('Error saving message:', error);
        socket.emit('message-error', {
          message: 'Failed to send message'
        });
      }
    });

    // Typing indicator
    socket.on('typing', (data) => {
      const { to } = data;
      const targetSocketId = activeUsers.get(to);
      
      if (targetSocketId) {
        io.to(targetSocketId).emit('typing', {
          from: socket.userId
        });
      }
    });

    // Stop typing
    socket.on('stop-typing', (data) => {
      const { to } = data;
      const targetSocketId = activeUsers.get(to);
      
      if (targetSocketId) {
        io.to(targetSocketId).emit('stop-typing', {
          from: socket.userId
        });
      }
    });

    // Handle disconnection
    socket.on('disconnect', () => {
      console.log(`User disconnected: ${socket.username} (${socket.id})`);

      // Remove from active users
      activeUsers.delete(socket.userId);
      socketToUser.delete(socket.id);

      // Update user offline status
      User.findByIdAndUpdate(socket.userId, {
        isOnline: false,
        socketId: '',
        lastSeen: Date.now()
      }).catch(err => console.error('Error updating user status:', err));

      // Notify contacts that user is offline
      socket.broadcast.emit('user-offline', {
        userId: socket.userId,
        username: socket.username,
        lastSeen: Date.now()
      });
    });
  });
};
