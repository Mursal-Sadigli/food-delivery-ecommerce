const express = require('express');
const router = express.Router();
const {
  registerCourier,
  getCourierProfile,
  updateLocation,
  setAvailability,
  getAssignedOrders,
  getOrderHistory,
  updateOrderStatus,
  getEarnings,
  getAllCouriers,
  assignCourier,
  getPendingOrders,
} = require('../controllers/courierController');
const { protect, admin, protectCourier } = require('../middlewares/authMiddleware');

// Kuryer routes
router.post('/register',           protect, registerCourier);
router.get('/profile',             protect, protectCourier, getCourierProfile);
router.post('/location',           protect, protectCourier, updateLocation);
router.put('/availability',        protect, protectCourier, setAvailability);
router.get('/orders',              protect, protectCourier, getAssignedOrders);
router.get('/orders/history',      protect, protectCourier, getOrderHistory);
router.put('/orders/:id/status',   protect, protectCourier, updateOrderStatus);
router.get('/earnings',            protect, protectCourier, getEarnings);

// Admin routes
router.get('/all',                 protect, admin, getAllCouriers);
router.put('/assign/:orderId',     protect, admin, assignCourier);
router.get('/pending-orders',      protect, admin, getPendingOrders);

module.exports = router;
