const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, required: true, ref: 'User' },
  orderItems: [
    {
      name: { type: String, required: true },
      qty: { type: Number, required: true },
      image: { type: String, required: true },
      price: { type: Number, required: true },
      product: { type: mongoose.Schema.Types.ObjectId, required: true, ref: 'Product' },
    },
  ],
  shippingAddress: {
    address: { type: String, required: true },
    city: { type: String, required: true },
    postalCode: { type: String, required: true },
    country: { type: String, required: true },
    lat: { type: Number },
    lng: { type: Number },
  },
  paymentMethod: { type: String, required: true },
  status: { type: String, enum: ['Hazırlanır', 'Bişirilir', 'Kuryerə verildi', 'Qapınızdadır', 'Çatdırıldı', 'Ləğv edildi', 'Geri qaytarıldı'], default: 'Hazırlanır' },
  courier: { type: mongoose.Schema.Types.ObjectId, ref: 'User', default: null },
  deliveryFee: { type: Number, default: 2.0 },
  scheduledAt: { type: Date },
  courierLocation: {
    lat: { type: Number },
    lng: { type: Number },
  },
  paymentResult: {
    id: { type: String },
    status: { type: String },
    update_time: { type: String },
    email_address: { type: String },
  },
  itemsPrice: { type: Number, required: true, default: 0.0 },
  shippingPrice: { type: Number, required: true, default: 0.0 },
  totalPrice: { type: Number, required: true, default: 0.0 },
  isPaid: { type: Boolean, required: true, default: false },
  paidAt: { type: Date },
  isDelivered: { type: Boolean, required: true, default: false },
  deliveredAt: { type: Date },
}, { timestamps: true });

module.exports = mongoose.model('Order', orderSchema);
