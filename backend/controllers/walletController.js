const User = require('../models/User');

// @desc    Get wallet info
// @route   GET /api/wallet
// @access  Private
const getWalletInfo = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('walletBalance walletTransactions');
    res.json({
      balance: user.walletBalance,
      transactions: user.walletTransactions
    });
  } catch (error) {
    res.status(500).json({ message: 'Cüzdan məlumatları gətirilərkən xəta baş verdi' });
  }
};

// @desc    Deposit funds (Simulation)
// @route   POST /api/wallet/deposit
// @access  Private
const depositFunds = async (req, res) => {
  const { amount } = req.body;

  if (!amount || amount <= 0) {
    return res.status(400).json({ message: 'Düzgün məbləğ daxil edin' });
  }

  try {
    const user = await User.findById(req.user._id);
    
    user.walletBalance += parseFloat(amount);
    user.walletTransactions.unshift({
      amount: parseFloat(amount),
      type: 'deposit',
      description: 'Balans artırılması'
    });

    await user.save();

    res.json({
      balance: user.walletBalance,
      transactions: user.walletTransactions
    });
  } catch (error) {
    res.status(500).json({ message: 'Balans artırılarkən xəta baş verdi' });
  }
};

module.exports = {
  getWalletInfo,
  depositFunds
};
