const Order = require('../models/Order');

// Create new order
exports.addOrderItems = async (req, res) => {
  try {
    const { orderItems, shippingAddress, paymentMethod, itemsPrice, shippingPrice, totalPrice } = req.body;

    if (orderItems && orderItems.length === 0) {
      return res.status(400).json({ message: 'Sifariş üçün məhsul yoxdur' });
    } else {
      const order = new Order({
        orderItems,
        user: req.user._id,
        shippingAddress,
        paymentMethod,
        itemsPrice,
        shippingPrice,
        totalPrice,
      });

      const createdOrder = await order.save();
      res.status(201).json(createdOrder);
    }
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
};

// Get order by ID
exports.getOrderById = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id).populate('user', 'name email');
    if (order) {
      res.json(order);
    } else {
      res.status(404).json({ message: 'Sifariş tapılmadı' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
};

// Update order to paid
exports.updateOrderToPaid = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (order) {
      order.isPaid = true;
      order.paidAt = Date.now();
      order.paymentResult = {
        id: req.body.id,
        status: req.body.status,
        update_time: req.body.update_time,
        email_address: req.body.email_address,
      };

      const updatedOrder = await order.save();
      res.json(updatedOrder);
    } else {
      res.status(404).json({ message: 'Sifariş tapılmadı' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
};

// Get logged in user orders
exports.getMyOrders = async (req, res) => {
  try {
    const orders = await Order.find({ user: req.user._id });
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
};

// Implementation for Stripe Payment Intent endpoint
exports.createPaymentIntent = async (req, res) => {
  try {
    const paymentIntent = {
      clientSecret: 'mock_stripe_client_secret_here', // mock response
    };
    res.json(paymentIntent);
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
};

// Update order location & status (For tracking sim/real API)
exports.updateOrderLocation = async (req, res) => {
  try {
    const { lat, lng, status } = req.body;
    const order = await Order.findById(req.params.id);
    if (order) {
      if (lat && lng) {
        order.courierLocation = { lat, lng };
      }
      if (status) {
        order.status = status;
      }
      const updatedOrder = await order.save();
      res.json(updatedOrder);
    } else {
      res.status(404).json({ message: 'Sifariş tapılmadı' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
};
