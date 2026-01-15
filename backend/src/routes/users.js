const express = require('express');
const {
  getMe,
  getUserById,
  searchUsers,
  getQRCode,
  addContact,
  removeContact
} = require('../controllers/userController');
const { protect } = require('../middleware/auth');

const router = express.Router();

// All routes are protected
router.use(protect);

// Routes
router.get('/me', getMe);
router.get('/search', searchUsers);
router.get('/:id', getUserById);
router.get('/:id/qr', getQRCode);
router.post('/contacts/:userId', addContact);
router.delete('/contacts/:userId', removeContact);

module.exports = router;
