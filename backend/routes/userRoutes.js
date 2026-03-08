const express = require('express');
const { 
  getUserProfile, 
  updateUserProfile, 
  getWishlist, 
  toggleWishlist,
  addUserAddress,
  removeUserAddress,
  addUserPaymentMethod,
  removeUserPaymentMethod
} = require('../controllers/userController');
const { getNotifications, markAsRead } = require('../controllers/notificationController');
const { protect } = require('../middlewares/authMiddleware');

const router = express.Router();

router.route('/profile')
  .get(protect, getUserProfile)
  .post(protect, updateUserProfile) // Changed to POST here as frontend expects POST in AuthProvider
  .put(protect, updateUserProfile);

router.route('/wishlist')
  .get(protect, getWishlist);

router.post('/wishlist/:id', protect, toggleWishlist);

router.route('/address')
  .post(protect, addUserAddress);
router.delete('/address/:id', protect, removeUserAddress);

router.route('/payment')
  .post(protect, addUserPaymentMethod);
router.delete('/payment/:id', protect, removeUserPaymentMethod);

// Bildirişlər
router.get('/notifications', protect, getNotifications);
router.put('/notifications/:id/read', protect, markAsRead);

module.exports = router;
