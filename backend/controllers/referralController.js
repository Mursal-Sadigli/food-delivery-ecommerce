const User = require('../models/User');

// @desc    Get referral status
// @route   GET /api/referral/status
// @access  Private
exports.getReferralStatus = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('referralCode loyaltyPoints');
    
    // Tapılan referral sayını hesabla
    const referralCount = await User.countDocuments({ referredBy: req.user._id });
    
    res.json({
      referralCode: user.referralCode,
      loyaltyPoints: user.loyaltyPoints,
      referralCount: referralCount
    });
  } catch (error) {
    res.status(500).json({ message: 'Referral məlumatları gətirilərkən xəta baş verdi' });
  }
};

// @desc    Convert points to wallet balance
// @route   POST /api/referral/convert
// @access  Private
exports.convertPoints = async (req, res) => {
  const { points } = req.body;
  
  if (!points || points < 100) {
    return res.status(400).json({ message: 'Minimum 100 SmartPoint çevirə bilərsiniz' });
  }

  try {
    const user = await User.findById(req.user._id);
    
    if (user.loyaltyPoints < points) {
      return res.status(400).json({ message: 'Kifayət qədər xalınız yoxdur' });
    }

    // Məzənnə: 100 xal = 1 AZN
    const amount = points / 100;
    
    user.loyaltyPoints -= points;
    user.walletBalance += amount;
    user.walletTransactions.unshift({
      amount: amount,
      type: 'deposit',
      description: 'SmartPoint çevrilməsi'
    });

    await user.save();

    res.json({
      message: 'Xallar uğurla pula çevrildi',
      balance: user.walletBalance,
      loyaltyPoints: user.loyaltyPoints
    });
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
};
