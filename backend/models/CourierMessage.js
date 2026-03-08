const mongoose = require('mongoose');

const courierMessageSchema = new mongoose.Schema({
  order: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Order',
    required: true
  },
  senderType: {
    type: String,
    enum: ['user', 'courier'],
    required: true
  },
  senderId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  text: {
    type: String,
    required: true
  },
  isRead: {
    type: Boolean,
    default: false
  }
}, { timestamps: true });

const CourierMessage = mongoose.model('CourierMessage', courierMessageSchema);

module.exports = CourierMessage;
