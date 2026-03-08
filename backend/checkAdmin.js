const mongoose = require('mongoose');
const dotenv = require('dotenv');
const User = require('./models/User');

dotenv.config();

const checkAdmin = async () => {
  try {
    const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/smartmarket';
    await mongoose.connect(MONGO_URI.trim());
    console.log('MongoDB qoşuldu.');

    const email = 'admin@smartfood.com';
    const admin = await User.findOne({ email });

    if (admin) {
      console.log('--- Admin Detalları ---');
      console.log('ID:', admin._id);
      console.log('Ad:', admin.name);
      console.log('Email:', admin.email);
      console.log('Rol:', admin.role);
      console.log('2FA Aktivdir:', admin.isTwoFactorEnabled);
      console.log('Yaradılma tarixi:', admin.createdAt);
      
      // Şifrə hash-ini də yoxlayaq (sırf şübhə üçün)
      console.log('Şifrə Hash-i:', admin.password);
    } else {
      console.log('Admin istifadəçisi tapılmadı!');
    }
    
    process.exit();
  } catch (error) {
    console.error('Xəta:', error);
    process.exit(1);
  }
};

checkAdmin();
