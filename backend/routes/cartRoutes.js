const express = require('express');
const { getCart, updateCart, getWishlist } = require('../controllers/cartController');
const { protect } = require('../middlewares/authMiddleware');

const router = express.Router();

router.route('/')
  .get(protect, getCart)
  .put(protect, updateCart);

router.route('/wishlist')
  .get(protect, getWishlist);

module.exports = router;
