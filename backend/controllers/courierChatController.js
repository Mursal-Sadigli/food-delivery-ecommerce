const CourierMessage = require('../models/CourierMessage');
const Order = require('../models/Order');

// @desc    Get chat messages for an order
// @route   GET /api/courier-chat/:orderId
// @access  Private (User or Courier)
exports.getOrderMessages = async (req, res) => {
  try {
    const order = await Order.findById(req.params.orderId);
    if (!order) {
      return res.status(404).json({ message: 'Sifariş tapılmadı' });
    }

    // İcazə yoxlanışı
    if (order.user.toString() !== req.user._id.toString() && !req.user.isAdmin) {
      return res.status(403).json({ message: 'İcazəniz yoxdur' });
    }

    const messages = await CourierMessage.find({ order: req.params.orderId }).sort({ createdAt: 1 });
    res.json(messages);
  } catch (error) {
    res.status(500).json({ message: 'Mesajlar yüklənərkən xəta yarandı.' });
  }
};

// @desc    Send a message to courier or user
// @route   POST /api/courier-chat/:orderId
// @access  Private (User or Courier)
exports.sendMessage = async (req, res) => {
  try {
    const { text, receiverType } = req.body;
    const orderId = req.params.orderId;

    if (!text) {
      return res.status(400).json({ message: 'Mesaj mətni boş ola bilməz' });
    }

    const order = await Order.findById(orderId);
    if (!order) {
      return res.status(404).json({ message: 'Sifariş tapılmadı' });
    }

    const senderType = req.user.role === 'courier' ? 'courier' : 'user';

    const message = await CourierMessage.create({
      order: orderId,
      senderType,
      senderId: req.user._id,
      text
    });

    // Real time emission happens in Socket.io layer
    const io = req.app.get('io');
    if (io) {
      io.to(`order_${orderId}`).emit('newCourierMessage', message);
    }

    res.status(201).json(message);
  } catch (error) {
    res.status(500).json({ message: 'Mesaj göndərilərkən xəta yarandı.' });
  }
};
