const express = require('express');
const { 
  getProducts, 
  getProductById, 
  createProduct, 
  updateProduct, 
  deleteProduct, 
  createProductReview,
  getRecommendations,
  searchByImage,
  getMyProducts,
  getFlashSales
} = require('../controllers/productController');
const { protect, admin } = require('../middlewares/authMiddleware');

const router = express.Router();

router.route('/').get(getProducts).post(protect, createProduct);
router.route('/flash-sales').get(getFlashSales);
router.route('/recommendations').get(getRecommendations);
router.route('/search-image').post(searchByImage);
router.route('/myproducts').get(protect, getMyProducts);

router.route('/:id/reviews').post(protect, createProductReview);

router.route('/:id')
  .get(getProductById)
  .put(protect, updateProduct)
  .delete(protect, deleteProduct);

module.exports = router;
