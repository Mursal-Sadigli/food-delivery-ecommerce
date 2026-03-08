const mongoose = require('mongoose');

const courierSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true
  },
  phone: { type: String, required: true },
  vehicleType: {
    type: String,
    enum: ['bicycle', 'motorcycle', 'car'],
    default: 'motorcycle'
  },
  isOnline: { type: Boolean, default: false },
  isAvailable: { type: Boolean, default: true },
  currentLocation: {
    lat: { type: Number, default: 0 },
    lng: { type: Number, default: 0 },
    updatedAt: { type: Date, default: Date.now }
  },
  earnings: {
    total: { type: Number, default: 0 },
    thisMonth: { type: Number, default: 0 },
    thisWeek:  { type: Number, default: 0 }
  },
  earningHistory: [
    {
      orderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order' },
      amount:  { type: Number, required: true },
      date:    { type: Date, default: Date.now }
    }
  ],
  totalDeliveries: { type: Number, default: 0 },
  rating:          { type: Number, default: 5.0 },
  ratingCount:     { type: Number, default: 0 },
  isApproved:      { type: Boolean, default: true },
  licenseNumber:   { type: String }
}, { timestamps: true });

module.exports = mongoose.model('Courier', courierSchema);
