const express = require('express');
const {
  sendMessage,
  getConversation,
  markAsRead,
  getUnreadCount,
  deleteMessage
} = require('../controllers/messageController');
const { protect } = require('../middleware/auth');

const router = express.Router();

// All routes are protected
router.use(protect);

// Routes
router.post('/', sendMessage);
router.get('/conversation/:userId', getConversation);
router.put('/read/:userId', markAsRead);
router.get('/unread', getUnreadCount);
router.delete('/:messageId', deleteMessage);

module.exports = router;
