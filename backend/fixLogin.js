const mongoose = require('mongoose');
const dotenv = require('dotenv');
const bcrypt = require('bcryptjs');
const User = require('./models/User');

dotenv.config();

const fixAndTest = async () => {
  try {
    const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/smartmarket';
    await mongoose.connect(MONGO_URI.trim());
    console.log('MongoDB qoşuldu.');

    const email = 'admin@smartfood.com';
    const rawPassword = 'admin123';

    // 1. Köhnəni silək və tam təzə yaradaq (Double hashing-dən qaçmaq üçün)
    await User.deleteOne({ email });
    console.log('Köhnə admin silindi.');

    // 2. Yeni Admin yaradaq. 
    // DİQQƏT: User.js-də pre-save hook var, ona görə biz RAW şifrə veririk.
    const admin = new User({
      name: 'Admin User',
      email: email,
      password: rawPassword, // Raw string - pre-save bunu hash-ləyəcək
      role: 'admin',
      isTwoFactorEnabled: false
    });

    await admin.save();
    console.log('Yeni Admin yaradıldı.');

    // 3. İndi dərhal test edək
    const testUser = await User.findOne({ email });
    const isMatch = await testUser.matchPassword(rawPassword);
    
    console.log('--- Test Nəticəsi ---');
    console.log('Email:', testUser.email);
    console.log('Şifrə Uyğundurmu?:', isMatch ? 'BƏLİ' : 'XEYR');
    console.log('Hash:', testUser.password);
    
    process.exit();
  } catch (error) {
    console.error('Xəta:', error);
    process.exit(1);
  }
};

fixAndTest();
