const Message = require('../models/Message');

// @desc    Get all messages for current user
// @route   GET /api/chat
// @access  Private
const getMessages = async (req, res) => {
  try {
    // For simplicity, we get messages where user is sender or receiver (if defined)
    // Or just all messages sent by this user and responses to them
    const messages = await Message.find({
      $or: [
        { sender: req.user._id },
        { receiver: req.user._id }
      ]
    }).sort({ createdAt: 1 });
    
    res.json(messages);
  } catch (error) {
    res.status(500).json({ message: 'Mesajlar gətirilərkən xəta baş verdi' });
  }
};

// @desc    Send a message
// @route   POST /api/chat
// @access  Private
const sendMessage = async (req, res) => {
  const { content } = req.body;

  if (!content) {
    return res.status(400).json({ message: 'Mesaj mətni boş ola bilməz' });
  }

  try {
    const message = await Message.create({
      sender: req.user._id,
      content,
      isAdmin: req.user.role === 'admin'
    });

    res.status(201).json(message);
  } catch (error) {
    res.status(500).json({ message: 'Mesaj göndərilərkən xəta baş verdi' });
  }
};

module.exports = {
  getMessages,
  sendMessage,
};
