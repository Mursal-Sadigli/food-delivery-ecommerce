const Cart = require('../models/Cart');
const User = require('../models/User');

// Get User Cart
exports.getCart = async (req, res) => {
  try {
    let cart = await Cart.findOne({ user: req.user._id });
    if (!cart) {
      cart = await Cart.create({ user: req.user._id, cartItems: [] });
    }
    res.json(cart);
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
};

// Update User Cart (Add, Update qty, Remove item combined in one sync endpoint or explicitly)
exports.updateCart = async (req, res) => {
  try {
    const { cartItems } = req.body;
    let cart = await Cart.findOne({ user: req.user._id });

    if (!cart) {
      cart = await Cart.create({ user: req.user._id, cartItems });
    } else {
      cart.cartItems = cartItems;
      await cart.save();
    }

    res.json(cart);
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
};

// Wishlist methods (using User model)
exports.getWishlist = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('-password');
    // Assuming wishlist will be an array of product IDs inside User schema
    // Since we didn't add it initially, let's just return a placeholder or implement it here
    res.json({ wishlist: [] });
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
};
