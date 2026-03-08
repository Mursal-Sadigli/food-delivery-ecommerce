const mongoose = require('mongoose');
const dotenv = require('dotenv');
const User = require('./models/User');

dotenv.config();

const createDoubleAdmin = async () => {
  try {
    const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/smartmarket';
    await mongoose.connect(MONGO_URI.trim());
    console.log('MongoDB qoşuldu.');

    const password = 'admin123';
    const emails = ['admin@smartfood.com', 'admin@smartmarket.com'];

    for (const email of emails) {
      await User.deleteOne({ email });
      const admin = new User({
        name: 'Admin User',
        email: email,
        password: password,
        role: 'admin',
        isTwoFactorEnabled: false
      });
      await admin.save();
      console.log(`Admin yaradıldı: ${email}`);
    }

    console.log('--- Giriş Məlumatları ---');
    console.log('Emaillər:', emails.join(', '));
    console.log('Şifrə:', password);
    
    process.exit();
  } catch (error) {
    console.error('Xəta:', error);
    process.exit(1);
  }
};

createDoubleAdmin();
