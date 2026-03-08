const mongoose = require('mongoose');
const Coupon = require('./models/Coupon');
require('dotenv').config();

const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/smartmarket';

const coupons = [
  {
    code: 'SMART10',
    discountAmount: 10,
    discountType: 'fixed',
    expiryDate: new Date('2026-12-31'),
    isActive: true
  },
  {
    code: 'SAVE20',
    discountAmount: 20,
    discountType: 'percent',
    expiryDate: new Date('2026-12-31'),
    isActive: true
  }
];

const seedCoupons = async () => {
  try {
    await mongoose.connect(MONGO_URI);
    await Coupon.deleteMany();
    await Coupon.insertMany(coupons);
    console.log('Kuponlar uğurla əlavə edildi!');
    process.exit();
  } catch (error) {
    console.error('Xəta:', error);
    process.exit(1);
  }
};

seedCoupons();
