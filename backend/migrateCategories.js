const mongoose = require('mongoose');
const Product = require('./models/Product');
const dotenv = require('dotenv');

dotenv.config();

const migrateCategories = async () => {
  try {
    const MONGO_URI = 'mongodb+srv://sadiqli2024_db_user:gaYzkzq5LmuieVd6@cluster0.vivh1dz.mongodb.net/smartmarket?retryWrites=true&w=majority&appName=Cluster0';
    await mongoose.connect(MONGO_URI);
    console.log('MongoDB connected for category migration...');

    const mapping = {
      'Qida': 'food',
      'İçki': 'drink',
      'Tərəvəz': 'vegetable',
      'Meyvə': 'fruit',
      'Şirniyyat': 'sweets',
      'Ət və Süd': 'meat_dairy',
      'Fast Food': 'fastfood',
      'Digər': 'other'
    };

    let updatedCount = 0;
    const products = await Product.find({});

    for (const product of products) {
      if (mapping[product.category]) {
        product.category = mapping[product.category];
        await product.save();
        updatedCount++;
      }
    }

    console.log(`Migration completed! ${updatedCount} products updated to technical category names.`);
    process.exit();
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  }
};

migrateCategories();
