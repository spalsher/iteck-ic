const User = require('../models/User');
const { generateQRCode } = require('../utils/qrGenerator');

// @desc    Get current user
// @route   GET /api/users/me
// @access  Private
exports.getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).populate('contacts', 'username displayName avatar isOnline lastSeen');
    
    res.status(200).json({
      success: true,
      user
    });
  } catch (error) {
    console.error('Get me error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

// @desc    Get user by ID
// @route   GET /api/users/:id
// @access  Private
exports.getUserById = async (req, res) => {
  try {
    const user = await User.findById(req.params.id).select('-password');
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.status(200).json({
      success: true,
      user
    });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

// @desc    Search users
// @route   GET /api/users/search?username=xxx
// @access  Private
exports.searchUsers = async (req, res) => {
  const { username } = req.query;

  if (!username) {
    return res.status(400).json({
      success: false,
      message: 'Username query parameter is required'
    });
  }

  try {
    const users = await User.find({
      username: { $regex: username, $options: 'i' },
      _id: { $ne: req.user._id } // Exclude current user
    })
    .select('username displayName avatar isOnline lastSeen')
    .limit(20);

    res.status(200).json({
      success: true,
      users
    });
  } catch (error) {
    console.error('Search users error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

// @desc    Generate QR code for user
// @route   GET /api/users/:id/qr
// @access  Private
exports.getQRCode = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Regenerate QR code if not exists
    if (!user.qrCode) {
      const qrData = {
        userId: user._id.toString(),
        username: user.username
      };
      user.qrCode = await generateQRCode(qrData);
      await user.save();
    }

    res.status(200).json({
      success: true,
      qrCode: user.qrCode
    });
  } catch (error) {
    console.error('Get QR code error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

// @desc    Add contact
// @route   POST /api/users/contacts/:userId
// @access  Private
exports.addContact = async (req, res) => {
  try {
    const contactId = req.params.userId;
    
    // Check if contact exists
    const contact = await User.findById(contactId);
    if (!contact) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Check if already a contact
    if (req.user.contacts.includes(contactId)) {
      return res.status(400).json({
        success: false,
        message: 'User is already a contact'
      });
    }

    // Add contact
    req.user.contacts.push(contactId);
    await req.user.save();

    // Optionally add reciprocal contact
    if (!contact.contacts.includes(req.user._id)) {
      contact.contacts.push(req.user._id);
      await contact.save();
    }

    res.status(200).json({
      success: true,
      message: 'Contact added successfully',
      contact: {
        id: contact._id,
        username: contact.username,
        displayName: contact.displayName,
        avatar: contact.avatar,
        isOnline: contact.isOnline
      }
    });
  } catch (error) {
    console.error('Add contact error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

// @desc    Remove contact
// @route   DELETE /api/users/contacts/:userId
// @access  Private
exports.removeContact = async (req, res) => {
  try {
    const contactId = req.params.userId;
    
    // Remove contact
    req.user.contacts = req.user.contacts.filter(id => id.toString() !== contactId);
    await req.user.save();

    res.status(200).json({
      success: true,
      message: 'Contact removed successfully'
    });
  } catch (error) {
    console.error('Remove contact error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};
