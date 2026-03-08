const mongoose = require('mongoose');
const dotenv = require('dotenv');
const bcrypt = require('bcryptjs');
const User = require('./models/User');

dotenv.config();

const createAdmin = async () => {
  try {
    const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/smartmarket';
    await mongoose.connect(MONGO_URI.trim());
    console.log('MongoDB qoşuldu.');

    const email = 'admin@smartfood.com';
    const password = 'admin123';

    // Mövcud admini tap və ya yeni yarat
    let admin = await User.findOne({ email });

    if (admin) {
      console.log('Admin istifadəçisi artıq var. Şifrə yenilənir...');
      admin.password = password;
      admin.role = 'admin';
      await admin.save();
      console.log('Şifrə uğurla yeniləndi: admin123');
    } else {
      console.log('Admin tapılmadı. Yeni Admin yaradılır...');
      admin = await User.create({
        name: 'Admin User',
        email,
        password,
        role: 'admin'
      });
      console.log('Admin uğurla yaradıldı!');
    }

    console.log('Giriş məlumatları:');
    console.log(`Email: ${email}`);
    console.log(`Şifrə: ${password}`);
    
    process.exit();
  } catch (error) {
    console.error('Xəta:', error);
    process.exit(1);
  }
};

createAdmin();
