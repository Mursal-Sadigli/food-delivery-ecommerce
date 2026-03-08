const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, required: true, ref: 'User' },
  name: { type: String, required: true },
  rating: { type: Number, required: true },
  comment: { type: String, required: true },
  images: [{ type: String }], // Rəy şəkilləri
}, { timestamps: true });

const productSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, required: true, ref: 'User' },
  name: { type: String, required: true },
  image: { type: String, required: true },
  description: { type: String, required: true },
  sellerName: { type: String },
  sellerPhone: { type: String },
  brand: { type: String },
  category: { type: String, required: true },
  price: { type: Number, required: true, default: 0 },
  sizes: [
    {
      name: { type: String, required: true }, // e.g: Small, Medium, Large
      price: { type: Number, required: true }, // e.g: 2.0 (addon price) or base
    }
  ],
  addons: [
    {
      name: { type: String, required: true }, // e.g: Extra Cheese, Ketchup
      price: { type: Number, required: true }, // e.g: 0.50
    }
  ],
  countInStock: { type: Number, required: true, default: 0 },
  reviews: [reviewSchema],
  rating: { type: Number, required: true, default: 0 },
  numReviews: { type: Number, required: true, default: 0 },
  isFlashSale: { type: Boolean, default: false },
  flashSalePrice: { type: Number },
  flashSaleEndDate: { type: Date },
  nutrition: {
    calories: { type: Number, default: 0 },
    protein: { type: Number, default: 0 },
    fat: { type: Number, default: 0 },
    carbs: { type: Number, default: 0 },
  },
  translations: {
    en: { name: String, description: String },
    ru: { name: String, description: String },
    az: { name: String, description: String },
  }
}, { timestamps: true });

module.exports = mongoose.model('Product', productSchema);
