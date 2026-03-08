const express = require('express');
const router = express.Router();
const { purchaseSubscription, getSubscriptionStatus } = require('../controllers/subscriptionController');
const { protect } = require('../middlewares/authMiddleware');

router.route('/purchase').post(protect, purchaseSubscription);
router.route('/status').get(protect, getSubscriptionStatus);

module.exports = router;
