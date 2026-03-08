const User = require('../models/User');

// @desc    Get user profile
// @route   GET /api/users/profile
// @access  Private
exports.getUserProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('-password');

    if (user) {
      res.json({
        _id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        address: user.address,
        profileImage: user.profileImage,
        addresses: user.addresses,
        paymentMethods: user.paymentMethods,
      });
    } else {
      res.status(404).json({ message: 'İstifadəçi tapılmadı' });
    }
  } catch (error) {
    console.error('getUserProfile Xətası:', error);
    res.status(500).json({ message: 'Server xətası' });
  }
};

// @desc    Update user profile
// @route   PUT /api/users/profile
// @access  Private
exports.updateUserProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);

    if (user) {
      user.name = req.body.name || user.name;
      user.email = req.body.email || user.email;
      user.address = req.body.address || user.address;
      
      if (req.body.profileImage !== undefined) {
        user.profileImage = req.body.profileImage;
      }

      if (req.body.password) {
        user.password = req.body.password;
      }

      const updatedUser = await user.save();

      res.json({
        _id: updatedUser._id,
        name: updatedUser.name,
        email: updatedUser.email,
        role: updatedUser.role,
        address: updatedUser.address,
        profileImage: updatedUser.profileImage,
        addresses: updatedUser.addresses,
        paymentMethods: updatedUser.paymentMethods,
        // token: req.headers.authorization.split(' ')[1] 
        // DİQQƏT: Bu aşağıdakı sətir xətaya səbəb ola bilər, çünki əgər token olmasa .split() funksiya deyil (string yoxdur)
        token: req.headers.authorization ? req.headers.authorization.split(' ')[1] : null,
      });
    } else {
      res.status(404).json({ message: 'İstifadəçi tapılmadı' });
    }
  } catch (error) {
    console.error('updateUserProfile Xətası:', error);
    res.status(500).json({ message: 'Server xətası: ' + error.message });
  }
};

// @desc    Get user wishlist
// @route   GET /api/users/wishlist
// @access  Private
exports.getWishlist = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).populate('wishlist');
    res.json(user.wishlist);
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
};

// @desc    Add/Remove from wishlist
// @route   POST /api/users/wishlist/:id
// @access  Private
exports.toggleWishlist = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    const productId = req.params.id;

    if (user.wishlist.includes(productId)) {
      user.wishlist = user.wishlist.filter(id => id.toString() !== productId);
      await user.save();
      res.json({ message: 'Məhsul istək siyahısından çıxarıldı', isFavorite: false });
    } else {
      user.wishlist.push(productId);
      await user.save();
      res.json({ message: 'Məhsul istək siyahısına əlavə olundu', isFavorite: true });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
};

// @desc    Add user address
// @route   POST /api/users/address
// @access  Private
exports.addUserAddress = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    if (user) {
      const address = {
        title: req.body.title,
        address: req.body.address,
        city: req.body.city,
        postalCode: req.body.postalCode,
        country: req.body.country,
        isDefault: req.body.isDefault || false
      };
      
      if (address.isDefault) {
        user.addresses.forEach(a => { a.isDefault = false; });
      }
      
      user.addresses.push(address);
      await user.save();
      res.json(user.addresses);
    } else {
      res.status(404).json({ message: 'İstifadəçi tapılmadı' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
};

// @desc    Remove user address
// @route   DELETE /api/users/address/:id
// @access  Private
exports.removeUserAddress = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    if (user) {
      user.addresses = user.addresses.filter(a => a._id.toString() !== req.params.id);
      await user.save();
      res.json(user.addresses);
    } else {
      res.status(404).json({ message: 'İstifadəçi tapılmadı' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
};

// @desc    Add user payment method
// @route   POST /api/users/payment
// @access  Private
exports.addUserPaymentMethod = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    if (user) {
      const method = {
        cardHolderName: req.body.cardHolderName,
        cardNumber: req.body.cardNumber,
        expiryDate: req.body.expiryDate,
        isDefault: req.body.isDefault || false
      };
      
      if (method.isDefault) {
        user.paymentMethods.forEach(p => { p.isDefault = false; });
      }
      
      user.paymentMethods.push(method);
      await user.save();
      res.json(user.paymentMethods);
    } else {
      res.status(404).json({ message: 'İstifadəçi tapılmadı' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
};

// @desc    Remove user payment method
// @route   DELETE /api/users/payment/:id
// @access  Private
exports.removeUserPaymentMethod = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    if (user) {
      user.paymentMethods = user.paymentMethods.filter(p => p._id.toString() !== req.params.id);
      await user.save();
      res.json(user.paymentMethods);
    } else {
      res.status(404).json({ message: 'İstifadəçi tapılmadı' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
};
