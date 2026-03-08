const express = require('express');
const router = express.Router();
const { getReferralStatus, convertPoints } = require('../controllers/referralController');
const { protect } = require('../middlewares/authMiddleware');

router.route('/status').get(protect, getReferralStatus);
router.route('/convert').post(protect, convertPoints);

module.exports = router;
