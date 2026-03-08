const express = require('express');
const { 
  getAnalytics,
  getAllOrders,
  updateOrderStatus,
  getAllFoods,
  getAllUsers,
  getAllCouriers,
  getAllReviews,
  deleteReview,
  getAllCoupons,
  createCoupon,
  deleteCoupon,
  getSettings,
  updateSettings,
  getAllPayments,
  getAuditLogs,
  cancelOrder,
  refundOrder,
  globalSearch
} = require('../controllers/adminController');
const { protect, admin } = require('../middlewares/authMiddleware');

const router = express.Router();

router.route('/analytics').get(protect, admin, getAnalytics);
router.route('/orders').get(protect, admin, getAllOrders);
router.route('/orders/:id').put(protect, admin, updateOrderStatus);
router.route('/orders/:id/cancel').put(protect, admin, cancelOrder);
router.route('/orders/:id/refund').put(protect, admin, refundOrder);
router.route('/foods').get(protect, admin, getAllFoods);
router.route('/foods/:id').delete(protect, admin, deleteFood);
router.route('/users').get(protect, admin, getAllUsers);
router.route('/users/:id').put(protect, admin, updateUserRole);
router.route('/couriers').get(protect, admin, getAllCouriers);

// New Routes
router.route('/reviews').get(protect, admin, getAllReviews);
router.route('/reviews/:id').delete(protect, admin, deleteReview);

router.route('/promotions')
  .get(protect, admin, getAllCoupons)
  .post(protect, admin, createCoupon);
router.route('/promotions/:id').delete(protect, admin, deleteCoupon);

router.route('/settings')
  .get(protect, admin, getSettings)
  .put(protect, admin, updateSettings);

router.route('/payments').get(protect, admin, getAllPayments);
router.route('/audit-logs').get(protect, admin, getAuditLogs);
router.route('/search').get(protect, admin, globalSearch);

module.exports = router;
