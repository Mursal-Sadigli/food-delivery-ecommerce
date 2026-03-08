const mongoose = require('mongoose');
const Product = require('./models/Product');
const Review = require('./models/Review');
const User = require('./models/User');
const dotenv = require('dotenv');

dotenv.config();

const syncReviews = async () => {
  try {
    const MONGO_URI = 'mongodb+srv://sadiqli2024_db_user:gaYzkzq5LmuieVd6@cluster0.vivh1dz.mongodb.net/smartmarket?retryWrites=true&w=majority&appName=Cluster0';
    await mongoose.connect(MONGO_URI);
    console.log('MongoDB connected for sync...');

    const products = await Product.find({});
    let syncedCount = 0;

    for (const product of products) {
      if (product.reviews && product.reviews.length > 0) {
        for (const rev of product.reviews) {
          // Check if it exists in Review model
          const exists = await Review.findOne({ user: rev.user, product: product._id });
          if (!exists) {
            await Review.create({
              user: rev.user,
              name: rev.name,
              rating: rev.rating,
              comment: rev.comment,
              product: product._id,
              images: rev.images || [],
              createdAt: rev.createdAt || new Date()
            });
            syncedCount++;
          }
        }
      }
    }

    console.log(`Sync completed! ${syncedCount} reviews migrated to Review collection.`);
    process.exit();
  } catch (error) {
    console.error('Sync failed:', error);
    process.exit(1);
  }
};

syncReviews();
