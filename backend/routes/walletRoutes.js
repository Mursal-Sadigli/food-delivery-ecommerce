const express = require('express');
const router = express.Router();
const { getWalletInfo, depositFunds } = require('../controllers/walletController');
const { protect } = require('../middlewares/authMiddleware');

router.get('/', protect, getWalletInfo);
router.post('/deposit', protect, depositFunds);

module.exports = router;
