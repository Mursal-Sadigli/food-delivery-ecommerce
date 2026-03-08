const express = require('express');
const { 
  registerUser, 
  loginUser, 
  forgotPassword, 
  resetPassword,
  socialLogin
} = require('../controllers/authController');

const router = express.Router();

router.post('/register', registerUser);
router.post('/login', loginUser);
router.post('/social', socialLogin);
router.post('/forgot-password', forgotPassword);
router.post('/reset-password', resetPassword);

module.exports = router;
