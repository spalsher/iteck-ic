const express = require('express');
const { uploadMedia, getMedia, deleteMedia } = require('../controllers/mediaController');
const { protect } = require('../middleware/auth');
const upload = require('../utils/fileUpload');

const router = express.Router();

// Routes
router.post('/upload', protect, upload.single('file'), uploadMedia);
router.get('/:filename', getMedia);
router.delete('/:filename', protect, deleteMedia);

module.exports = router;
