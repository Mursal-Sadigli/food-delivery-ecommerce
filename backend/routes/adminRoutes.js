const express = require('express');
const { getAnalytics } = require('../controllers/adminController');
const { protect, admin } = require('../middlewares/authMiddleware');

const router = express.Router();

router.get('/analytics', protect, admin, getAnalytics);

module.exports = router;
