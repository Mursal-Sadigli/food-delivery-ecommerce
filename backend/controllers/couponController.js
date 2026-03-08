const Coupon = require('../models/Coupon');

// @desc    Validate a promo code
// @route   POST /api/coupons/validate
// @access  Private
const validateCoupon = async (req, res) => {
  const { code } = req.body;

  try {
    const coupon = await Coupon.findOne({ code: code.toUpperCase(), isActive: true });

    if (!coupon) {
      return res.status(404).json({ message: 'Yanlış və ya aktiv olmayan promo kod' });
    }

    if (new Date() > coupon.expiryDate) {
      return res.status(400).json({ message: 'Promo kodun vaxtı bitib' });
    }

    res.json({
      code: coupon.code,
      discountAmount: coupon.discountAmount,
      discountType: coupon.discountType
    });
  } catch (error) {
    res.status(500).json({ message: 'Sunucu xətası' });
  }
};

// @desc    Create a coupon (Admin only)
// @route   POST /api/coupons
// @access  Private/Admin
const createCoupon = async (req, res) => {
  const { code, discountAmount, discountType, expiryDate } = req.body;

  try {
    const couponExists = await Coupon.findOne({ code: code.toUpperCase() });

    if (couponExists) {
      return res.status(400).json({ message: 'Bu kod artıq mövcuddur' });
    }

    const coupon = await Coupon.create({
      code,
      discountAmount,
      discountType,
      expiryDate: new Date(expiryDate)
    });

    res.status(201).json(coupon);
  } catch (error) {
    res.status(500).json({ message: 'Promo kod yaradılarkən xəta baş verdi' });
  }
};

module.exports = {
  validateCoupon,
  createCoupon
};
