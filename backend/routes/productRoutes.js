const express = require('express');
const { getProducts, getProductById, createProduct, updateProduct, deleteProduct, createProductReview } = require('../controllers/productController');
const { protect, admin } = require('../middlewares/authMiddleware');

const router = express.Router();

router.route('/')
  .get(getProducts)
  .post(protect, admin, createProduct);

router.route('/:id/reviews').post(protect, createProductReview);

router.route('/:id')
  .get(getProductById)
  .put(protect, admin, updateProduct)
  .delete(protect, admin, deleteProduct);

module.exports = router;
