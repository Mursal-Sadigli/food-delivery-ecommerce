const express = require('express');
const router = express.Router();
const { validateCoupon, createCoupon } = require('../controllers/couponController');
const { protect } = require('../middlewares/authMiddleware');

router.post('/validate', protect, validateCoupon);
router.post('/', protect, createCoupon); // Admin check could be added here if needed

module.exports = router;
