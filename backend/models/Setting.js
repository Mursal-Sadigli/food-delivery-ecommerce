const mongoose = require('mongoose');

const settingSchema = new mongoose.Schema({
  deliveryFee: { type: Number, default: 0 },
  platformCommission: { type: Number, default: 10 }, // Faizle
  tax: { type: Number, default: 0 },
  minOrderAmount: { type: Number, default: 0 },
  supportedCities: [{ type: String }],
  contactEmail: { type: String },
  contactPhone: { type: String },
  isMaintenanceMode: { type: Boolean, default: false }
}, { timestamps: true });

module.exports = mongoose.model('Setting', settingSchema);
