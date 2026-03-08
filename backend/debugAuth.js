const mongoose = require('mongoose');
const dotenv = require('dotenv');
const User = require('./models/User');

dotenv.config();

const verifyAll = async () => {
  try {
    const rawUri = process.env.MONGO_URI;
    console.log('--- Bağlantı Məlumatı ---');
    console.log('MONGO_URI (ilk 20 simvol):', rawUri ? rawUri.substring(0, 20) + '...' : 'TAPILMADI');
    
    await mongoose.connect(rawUri.trim());
    console.log('Bağlantı uğurludur.');

    const email = 'admin@smartfood.com';
    const admin = await User.findOne({ email });

    if (admin) {
      console.log('--- Admin Detalları ---');
      console.log('ID:', admin._id);
      console.log('Email:', admin.email);
      console.log('Rol:', admin.role);
      console.log('2FA:', admin.isTwoFactorEnabled);
      console.log('Şifrə Hash:', admin.password);
    } else {
      console.log('XƏTA: admin@smartfood.com tapılmadı!');
    }
    
    process.exit();
  } catch (error) {
    console.error('Xəta:', error);
    process.exit(1);
  }
};

verifyAll();
