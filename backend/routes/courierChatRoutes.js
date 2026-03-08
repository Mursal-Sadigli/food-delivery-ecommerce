const express = require('express');
const { getOrderMessages, sendMessage } = require('../controllers/courierChatController');
const { protect } = require('../middlewares/authMiddleware');

const router = express.Router({ mergeParams: true });

router.route('/:orderId')
  .get(protect, getOrderMessages)
  .post(protect, sendMessage);

module.exports = router;
