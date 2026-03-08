const User = require('../models/User');

// @desc    Purchase Pro subscription
// @route   POST /api/subscriptions/purchase
// @access  Private
exports.purchaseSubscription = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    
    // Simulyasiya: Cüzdandan çıxılır
    const subscriptionPrice = 9.99;
    
    if (user.walletBalance < subscriptionPrice) {
      return res.status(400).json({ message: 'Cüzdanınızda kifayət qədər vəsait yoxdur' });
    }

    user.walletBalance -= subscriptionPrice;
    user.isPro = true;
    
    // 30 günlük abunəlik
    const expiryDate = new Date();
    expiryDate.setDate(expiryDate.getDate() + 30);
    user.subscriptionExpiry = expiryDate;

    user.walletTransactions.unshift({
      amount: -subscriptionPrice,
      type: 'payment',
      description: 'SmartMarket Pro Abunəliyi'
    });

    await user.save();

    res.json({
      message: 'Abunəlik uğurla alındı',
      isPro: user.isPro,
      subscriptionExpiry: user.subscriptionExpiry,
      balance: user.walletBalance
    });
  } catch (error) {
    res.status(500).json({ message: 'Abunəlik alınarkən xəta baş verdi' });
  }
};

// @desc    Get subscription status
// @route   GET /api/subscriptions/status
// @access  Private
exports.getSubscriptionStatus = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('isPro subscriptionExpiry');
    
    // Vaxtı keçibsə yenilə
    if (user.isPro && user.subscriptionExpiry < new Date()) {
      user.isPro = false;
      await user.save();
    }

    res.json({
      isPro: user.isPro,
      subscriptionExpiry: user.subscriptionExpiry
    });
  } catch (error) {
    res.status(500).json({ message: 'Məlumat gətirilərkən xəta baş verdi' });
  }
};
