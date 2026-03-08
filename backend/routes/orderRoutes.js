const express = require('express');
const { addOrderItems, getOrderById, updateOrderToPaid, getMyOrders, createPaymentIntent, updateOrderLocation, getOrderQrCode } = require('../controllers/orderController');
const { protect } = require('../middlewares/authMiddleware');

const router = express.Router();

router.route('/').post(protect, addOrderItems);
router.route('/myorders').get(protect, getMyOrders);
router.route('/create-payment-intent').post(protect, createPaymentIntent);
router.route('/:id').get(protect, getOrderById);
router.route('/:id/pay').put(protect, updateOrderToPaid);
router.route('/:id/location').put(protect, updateOrderLocation);
router.route('/:id/qr').get(protect, getOrderQrCode);

module.exports = router;
