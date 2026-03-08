const CourierMessage = require('../models/CourierMessage');
const Order = require('../models/Order');
const mongoose = require('mongoose');

// @desc    Get chat messages for an order
// @route   GET /api/courier-chat/:orderId
// @access  Private (User or Courier)
exports.getOrderMessages = async (req, res) => {
  try {
    const orderId = req.params.orderId;
    
    if (orderId === 'simulated_order_123') {
      return res.json([
        { _id: 'mock1', text: 'Salam, yeməyiniz təxminən 10 dəqiqəyə çatacaq.', senderId: 'courier1', senderType: 'courier', createdAt: new Date() }
      ]);
    }

    if (!mongoose.Types.ObjectId.isValid(orderId)) {
      return res.status(400).json({ message: 'Yanlış Sifariş ID' });
    }

    const order = await Order.findById(orderId);
    if (!order) {
      return res.status(404).json({ message: 'Sifariş tapılmadı' });
    }

    // İcazə yoxlanışı
    if (order.user.toString() !== req.user._id.toString() && !req.user.isAdmin) {
      return res.status(403).json({ message: 'İcazəniz yoxdur' });
    }

    const messages = await CourierMessage.find({ order: orderId }).sort({ createdAt: 1 });
    res.json(messages);
  } catch (error) {
    console.error(error);
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

    const senderType = req.user.role === 'courier' ? 'courier' : 'user';

    if (orderId === 'simulated_order_123') {
      const message = {
        _id: new mongoose.Types.ObjectId().toString(),
        order: orderId,
        senderType,
        senderId: req.user._id,
        text,
        createdAt: new Date()
      };
      const io = req.app.get('io');
      if (io) {
        io.to(`order_${orderId}`).emit('newCourierMessage', message);
      }
      return res.status(201).json(message);
    }

    if (!mongoose.Types.ObjectId.isValid(orderId)) {
      return res.status(400).json({ message: 'Yanlış Sifariş ID' });
    }

    const order = await Order.findById(orderId);
    if (!order) {
      return res.status(404).json({ message: 'Sifariş tapılmadı' });
    }

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
    console.error(error);
    res.status(500).json({ message: 'Mesaj göndərilərkən xəta yarandı.' });
  }
};
