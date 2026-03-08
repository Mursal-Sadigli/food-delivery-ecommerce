const Order = require('../models/Order');
const User = require('../models/User');

// Create new order
exports.addOrderItems = async (req, res) => {
  try {
    const { 
      orderItems, 
      shippingAddress, 
      paymentMethod, 
      itemsPrice, 
      shippingPrice, 
      totalPrice,
      scheduledAt 
    } = req.body;

    if (orderItems && orderItems.length === 0) {
      return res.status(400).json({ message: 'Sifariş üçün məhsul yoxdur' });
    } else {
      const user = await User.findById(req.user._id);
      
      // Pro istifadəçilər üçün çatdırılma pulsuzdur
      let finalShippingPrice = shippingPrice;
      if (user && user.isPro && user.subscriptionExpiry > new Date()) {
        finalShippingPrice = 0;
      }

      const order = new Order({
        orderItems,
        user: req.user._id,
        shippingAddress,
        paymentMethod,
        itemsPrice,
        shippingPrice: finalShippingPrice,
        totalPrice: itemsPrice + finalShippingPrice,
        scheduledAt: scheduledAt || null,
        // Ödəniş metodu Cüzdan və ya Kart (Stripe Simulyasiyası) dırsa, ödənilmiş sayılır
        isPaid: (paymentMethod === 'Cüzdan' || paymentMethod === 'Kart'),
        paidAt: (paymentMethod === 'Cüzdan' || paymentMethod === 'Kart') ? Date.now() : null
      });

      const createdOrder = await order.save();
      
      const io = req.app.get('io');
      if (io) {
        io.emit('new_order', createdOrder);
      }
      
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
      
      const io = req.app.get('io');
      if (io) {
        io.emit('order_updated', updatedOrder);
      }
      
      // Referral və Loyalty Points məntiqi
      const user = await User.findById(order.user);
      if (user) {
        // Loyalty points qazanmaq (Sifariş məbləği qədər)
        user.loyaltyPoints += Math.floor(order.totalPrice);
        
        // Referral bonusu (Yalnız ilk uğurlu sifarişdə)
        const orderCount = await Order.countDocuments({ user: user._id, isPaid: true });
        if (orderCount === 1 && user.referredBy) {
          // Referee (Gələn istifadəçi) bonusu - 2 AZN
          user.walletBalance += 2;
          user.walletTransactions.unshift({
            amount: 2,
            type: 'deposit',
            description: 'Referral qeydiyyat bonusu'
          });

          // Referrer (Dəvət edən) bonusu - 5 AZN
          const referrer = await User.findById(user.referredBy);
          if (referrer) {
            referrer.walletBalance += 5;
            referrer.walletTransactions.unshift({
              amount: 5,
              type: 'deposit',
              description: `Referral bonusu (${user.name})`
            });
            await referrer.save();
          }
        }
        await user.save();
      }

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

// Get QR Code Data for Order
exports.getOrderQrCode = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) {
      return res.status(404).json({ message: 'Sifariş tapılmadı' });
    }
    
    // Yalnız admin və ya sifariş sahibi görə bilər
    if (order.user.toString() !== req.user._id.toString() && !req.user.isAdmin) {
      return res.status(403).json({ message: 'İcazəniz yoxdur' });
    }
    
    // Sifariş məlumatlarını JSON kimi birləşdiririk
    const qrData = JSON.stringify({
      orderId: order._id,
      user: order.user,
      totalPrice: order.totalPrice,
      status: order.status,
      timestamp: Date.now()
    });

    res.json({ qrData });
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
