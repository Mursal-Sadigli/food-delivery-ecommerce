const mongoose = require('mongoose');
const Order = require('../models/Order');
const Product = require('../models/Product');
const User = require('../models/User');
const Review = require('../models/Review');
const Coupon = require('../models/Coupon');
const Setting = require('../models/Setting');
const AuditLog = require('../models/AuditLog');

// Helper: Create Audit Log
const createLog = async (adminId, action, targetType, targetId, details, req) => {
  try {
    await AuditLog.create({
      admin: adminId,
      action,
      targetType,
      targetId,
      details,
      ipAddress: req.ip || req.connection.remoteAddress,
      userAgent: req.get('User-Agent')
    });
  } catch (err) {
    console.error('AuditLog creation failed:', err);
  }
};

// @desc    Get dashboard analytics
// @route   GET /api/admin/analytics
// @access  Private/Admin
exports.getAnalytics = async (req, res) => {
  try {
    // 1. Ümumi Statistikalar
    const totalOrders = await Order.countDocuments();
    const totalProducts = await Product.countDocuments();
    const totalUsers = await User.countDocuments();
    
    const paidOrders = await Order.find({ isPaid: true });
    const totalRevenue = paidOrders.reduce((acc, item) => acc + item.totalPrice, 0);

    // 2. Satış Trendi (Son 7 gün)
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    const salesTrend = await Order.aggregate([
      {
        $match: {
          isPaid: true,
          paidAt: { $gte: sevenDaysAgo }
        }
      },
      {
        $group: {
          _id: { $dateToString: { format: "%Y-%m-%d", date: "$paidAt" } },
          totalSales: { $sum: "$totalPrice" },
          count: { $sum: 1 }
        }
      },
      { $sort: { "_id": 1 } }
    ]);

    // 3. Kateqoriya üzrə məhsul paylanması
    const categoryStats = await Product.aggregate([
      {
        $group: {
          _id: "$category",
          count: { $sum: 1 }
        }
      }
    ]);

    // 4. Ən çox satılan məhsullar (Top 5)
    // Qeyd: Bu, Order modelindəki orderItems-dən hesablanır
    const topProducts = await Order.aggregate([
      { $match: { isPaid: true } },
      { $unwind: "$orderItems" },
      {
        $group: {
          _id: "$orderItems.product",
          name: { $first: "$orderItems.name" },
          totalQty: { $sum: "$orderItems.qty" },
          totalRevenue: { $sum: { $multiply: ["$orderItems.qty", "$orderItems.price"] } }
        }
      },
      { $sort: { totalQty: -1 } },
      { $limit: 5 }
    ]);

    res.json({
      summary: {
        totalOrders,
        totalProducts,
        totalUsers,
        totalRevenue: parseFloat(totalRevenue.toFixed(2))
      },
      salesTrend,
      categoryStats,
      topProducts
    });
  } catch (error) {
    console.error('Analitika xətası:', error);
    res.status(500).json({ message: 'Server xətası' });
  }
};

// @desc    Bütün sifarişləri (Orders) gətir
// @route   GET /api/admin/orders
// @access  Private/Admin
exports.getAllOrders = async (req, res) => {
  try {
    const orders = await Order.find({})
      .populate('user', 'id name email')
      .populate({
        path: 'orderItems.product',
        select: 'name price category user',
        populate: {
          path: 'user',
          select: 'name'
        }
      })
      .populate('courier', 'name email')
      .sort({ createdAt: -1 });
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: 'Sifarişlər yüklənərkən xəta yarandı.' });
  }
};

// @desc    Sifarişin statusunu yenilə
// @route   PUT /api/admin/orders/:id
// @access  Private/Admin
exports.updateOrderStatus = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) {
      return res.status(404).json({ message: 'Sifariş tapılmadı' });
    }

    order.status = req.body.status || order.status;
    const updatedOrder = await order.save();
    
    // Qeydiyyatlı FCM token varsa push göndər
    const orderUser = await User.findById(order.user);
    if (orderUser && orderUser.fcmToken) {
      const { sendPushNotification } = require('../utils/firebase');
      await sendPushNotification(
        orderUser.fcmToken,
        'Sifarişinizin statusu yeniləndi',
        `Sifarişiniz qeydə alındı və hazırda '${updatedOrder.status}' statusundadır.`
      );
    }

    res.json(updatedOrder);
  } catch (error) {
    res.status(500).json({ message: 'Sifariş yenilənərkən xəta yarandı.' });
  }
};

// @desc    Bütün məhsulları/yeməkləri gətir
// @route   GET /api/admin/foods
// @access  Private/Admin
exports.getAllFoods = async (req, res) => {
  try {
    const products = await Product.find({}).populate('user', 'id name'); // user = restaurant/seller
    res.json(products);
  } catch (error) {
    res.status(500).json({ message: 'Yeməklər yüklənərkən xəta yarandı.' });
  }
};

// @desc    Məhsulu sil
// @route   DELETE /api/admin/foods/:id
// @access  Private/Admin
exports.deleteFood = async (req, res) => {
  try {
    const food = await Product.findById(req.params.id);
    if (!food) return res.status(404).json({ message: 'Məhsul tapılmadı' });
    await food.deleteOne();
    await createLog(req.user._id, 'DELETE_FOOD', 'Product', req.params.id, `Məhsul silindi: ${food.name}`, req);
    res.json({ message: 'Məhsul silindi' });
  } catch (error) {
    res.status(500).json({ message: 'Məhsul silinərkən xəta yarandı.' });
  }
};

// @desc    Bütün istifadəçiləri gətir
// @route   GET /api/admin/users
// @access  Private/Admin
exports.getAllUsers = async (req, res) => {
  try {
    // Şifrələri (password) çıxarmaq
    const users = await User.find({}).select('-password').sort({ createdAt: -1 });
    res.json(users);
  } catch (error) {
    res.status(500).json({ message: 'İstifadəçilər yüklənərkən xəta yarandı.' });
  }
};

// @desc    İstifadəçi rolunu yenilə
// @route   PUT /api/admin/users/:id/role
// @access  Private/Admin
exports.updateUserRole = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ message: 'İstifadəçi tapılmadı' });
    }

    user.role = req.body.role;
    await user.save();
    await createLog(req.user._id, 'CHANGE_ROLE', 'User', req.params.id, `Rol dəyişdirildi: ${req.body.role}`, req);
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: 'İstifadəçi rolu yenilənərkən xəta yarandı.' });
  }
};

// @desc    Bütün kuryerləri gətir
// @route   GET /api/admin/couriers
// @access  Private/Admin
exports.getAllCouriers = async (req, res) => {
  try {
    const couriers = await User.find({ role: 'courier' }).select('-password');
    res.json(couriers);
  } catch (error) {
    res.status(500).json({ message: 'Kuryerlər yüklənərkən xəta yarandı.' });
  }
};

// --- Reviews ---
exports.getAllReviews = async (req, res) => {
  try {
    const reviews = await Review.find({})
      .populate('user', 'name email')
      .populate('product', 'name')
      .sort({ createdAt: -1 });
    res.json(reviews);
  } catch (error) {
    res.status(500).json({ message: 'Rəylər yüklənərkən xəta yarandı.' });
  }
};

exports.deleteReview = async (req, res) => {
  try {
    const review = await Review.findById(req.params.id);
    if (!review) return res.status(404).json({ message: 'Rəy tapılmadı' });
    
    // Also remove from Product's reviews array
    await Product.updateOne(
      { _id: review.product },
      { 
        $pull: { reviews: { user: review.user, comment: review.comment } },
        $inc: { numReviews: -1 }
      }
    );

    // Recalculate average rating for the product (optional but recommended)
    const product = await Product.findById(review.product);
    if (product && product.reviews.length > 0) {
      product.rating = product.reviews.reduce((acc, item) => item.rating + acc, 0) / product.reviews.length;
    } else if (product) {
      product.rating = 0;
    }
    if (product) await product.save();

    await review.deleteOne();
    
    // Clear cache
    const cache = require('../utils/cache');
    cache.clear();

    await createLog(req.user._id, 'DELETE_REVIEW', 'Review', req.params.id, `Rəy silindi: ${review.comment.substring(0, 20)}...`, req);
    res.json({ message: 'Rəy silindi' });
  } catch (error) {
    console.error('Admin deleteReview error:', error);
    res.status(500).json({ message: 'Rəy silinərkən xəta yarandı.' });
  }
};

// --- Promotions (Coupons) ---
exports.getAllCoupons = async (req, res) => {
  try {
    const coupons = await Coupon.find({}).sort({ createdAt: -1 });
    res.json(coupons);
  } catch (error) {
    res.status(500).json({ message: 'Kuponlar yüklənərkən xəta yarandı.' });
  }
};

exports.createCoupon = async (req, res) => {
  try {
    const coupon = await Coupon.create(req.body);
    res.status(201).json(coupon);
  } catch (error) {
    res.status(500).json({ message: 'Kupon yaradılarkən xəta yarandı.' });
  }
};

exports.deleteCoupon = async (req, res) => {
  try {
    const coupon = await Coupon.findById(req.params.id);
    if (!coupon) return res.status(404).json({ message: 'Kupon tapılmadı' });
    await coupon.deleteOne();
    await createLog(req.user._id, 'DELETE_COUPON', 'Coupon', req.params.id, `Coupon ${coupon.code} deleted`, req);
    res.json({ message: 'Kupon silindi' });
  } catch (error) {
    res.status(500).json({ message: 'Kupon silinərkən xəta yarandı.' });
  }
};

// --- Settings ---
exports.getSettings = async (req, res) => {
  try {
    let settings = await Setting.findOne();
    if (!settings) {
      settings = await Setting.create({});
    }
    res.json(settings);
  } catch (error) {
    res.status(500).json({ message: 'Tənzimləmələr yüklənərkən xəta yarandı.' });
  }
};

exports.updateSettings = async (req, res) => {
  try {
    let settings = await Setting.findOne();
    if (!settings) {
      settings = new Setting(req.body);
    } else {
      Object.assign(settings, req.body);
    }
    await settings.save();
    await createLog(req.user._id, 'UPDATE_SETTINGS', 'Setting', settings._id, `System settings updated`, req);
    res.json(settings);
  } catch (error) {
    res.status(500).json({ message: 'Tənzimləmələr yenilənərkən xəta yarandı.' });
  }
};

// --- Payments ---
exports.getAllPayments = async (req, res) => {
  try {
    const payments = await Order.find({ isPaid: true })
      .populate('user', 'name email')
      .select('totalPrice paidAt paymentMethod _id')
      .sort({ paidAt: -1 });
    res.json(payments);
  } catch (error) {
    res.status(500).json({ message: 'Ödənişlər yüklənərkən xəta yarandı.' });
  }
};

// --- Audit Logs ---
exports.getAuditLogs = async (req, res) => {
  try {
    const logs = await AuditLog.find({})
      .populate('admin', 'name email')
      .sort({ createdAt: -1 })
      .limit(100);
    res.json(logs);
  } catch (error) {
    res.status(500).json({ message: 'Audit loqları yüklənərkən xəta yarandı.' });
  }
};

// --- Order Actions (Cancel / Refund) ---
exports.cancelOrder = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ message: 'Sifariş tapılmadı' });
    
    order.status = req.body.status; // Changed from 'Ləğv edildi' to req.body.status
    await order.save();
    
    const io = req.app.get('io');
    if (io) {
      io.emit('order_updated', order);
    }
    
    await createLog(req.user._id, 'CANCEL_ORDER', 'Order', order._id, `Order cancelled`, req);
    res.json(order);
  } catch (error) {
    res.status(500).json({ message: 'Sifariş ləğv edilərkən xəta yarandı.' });
  }
};

exports.refundOrder = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ message: 'Sifariş tapılmadı' });
    
    order.status = 'Geri qaytarıldı';
    await order.save();
    
    const io = req.app.get('io');
    if (io) {
      io.emit('order_updated', order);
    }
    
    await createLog(req.user._id, 'REFUND_ORDER', 'Order', order._id, `Order refunded`, req);
    res.json(order);
  } catch (error) {
    res.status(500).json({ message: 'Ödəniş geri qaytarılarkən xəta yarandı.' });
  }
};

// --- Global Search ---
exports.globalSearch = async (req, res) => {
  const { query } = req.query;
  if (!query || query.length < 2) return res.json({ orders: [], restaurants: [], foods: [] });

  try {
    const regex = new RegExp(query, 'i');

    const orders = await Order.find({
      $or: [
        { _id: mongoose.isValidObjectId(query) ? (query.length === 24 ? query : null) : null },
        { status: regex }
      ]
    }).populate('user', 'name').limit(5);

    const restaurants = await User.find({
      role: 'shop',
      $or: [{ name: regex }, { email: regex }]
    }).limit(5);

    const foods = await Product.find({
      $or: [{ name: regex }, { category: regex }]
    }).limit(5);

    res.json({ orders, restaurants, foods });
  } catch (error) {
    res.status(500).json({ message: 'Axtarış zamanı xəta yarandı.' });
  }
};

// --- Advanced Analytics & Command Center ---
exports.getAdvancedAnalytics = async (req, res) => {
  try {
    // 1. Order Funnel (Stages)
    const funnel = await Order.aggregate([
      {
        $group: {
          _id: "$status",
          count: { $sum: 1 }
        }
      }
    ]);

    // 2. Courier Leaderboard
    const courierLeaderboard = await Order.aggregate([
      { $match: { courier: { $ne: null } } },
      {
        $group: {
          _id: "$courier",
          orderCount: { $sum: 1 },
          avgRating: { $avg: 5 }, // Ideal halda Review modelindən gəlməlidir
          totalRevenue: { $sum: "$totalPrice" }
        }
      },
      {
        $lookup: {
          from: "users",
          localField: "_id",
          foreignField: "_id",
          as: "courierDetails"
        }
      },
      { $unwind: "$courierDetails" },
      {
        $project: {
          name: "$courierDetails.name",
          orderCount: 1,
          avgRating: 1,
          totalRevenue: 1
        }
      },
      { $sort: { orderCount: -1 } },
      { $limit: 10 }
    ]);

    // 3. Revenue Flow (Hourly/Daily for line chart)
    const revenueFlow = await Order.aggregate([
      { $match: { isPaid: true } },
      {
        $group: {
          _id: { $dateToString: { format: "%Y-%m-%d %H:00", date: "$paidAt" } },
          revenue: { $sum: "$totalPrice" },
          orders: { $sum: 1 }
        }
      },
      { $sort: { "_id": 1 } },
      { $limit: 24 }
    ]);

    // 4. Map Data (Simplified)
    const mapData = {
      orders: await Order.find({ status: { $ne: 'Çatdırıldı' } }).select('status shippingAddress').populate('user', 'name'),
      couriers: await User.find({ role: 'courier' }).select('name status'), // Coordinates dummy for now if missing
      restaurants: await User.find({ role: 'shop' }).select('name address')
    };

    // 5. Cohort Analytics (New vs Returning)
    const totalUsers = await User.countDocuments({ role: 'user' });
    const usersWithOrders = await Order.distinct('user');
    const returningUsers = await Order.aggregate([
      { $group: { _id: "$user", count: { $sum: 1 } } },
      { $match: { count: { $gt: 1 } } }
    ]);

    const cohortData = {
      total: totalUsers,
      active: usersWithOrders.length,
      returning: returningUsers.length
    };

    // 6. Alert Timeline (Recent critical events)
    const alerts = await AuditLog.find({
      action: { $in: ['REFUND_ORDER', 'CANCEL_ORDER', 'USER_ROLE_CHANGE'] }
    }).sort({ createdAt: -1 }).limit(10).populate('admin', 'name');

    res.json({
      funnel,
      courierLeaderboard,
      revenueFlow,
      mapData,
      cohortData,
      alerts
    });
  } catch (error) {
    console.error('Advanced Analytics Error:', error);
    res.status(500).json({ message: 'Qabaqcıl analitika məlumatları toplana bilmədi.' });
  }
};

// @desc    Create a new restaurant (seller)
// @route   POST /api/admin/restaurants
// @access  Private/Admin
exports.createRestaurant = async (req, res) => {
  try {
    const { name, email, password, address, city, district, lat, lng } = req.body;

    const userExists = await User.findOne({ email });
    if (userExists) {
      return res.status(400).json({ message: 'Bu email ilə artıq istifadəçi mövcuddur.' });
    }

    const restaurant = await User.create({
      name,
      email,
      password,
      role: 'seller', // Restoranlar sistemdə seller rolunda olur
      address,
      city,
      district,
      location: { lat, lng }
    });

    if (restaurant) {
      await createLog(req.user._id, 'CREATE_RESTAURANT', 'User', restaurant._id, `Yeni restoran yaradıldı: ${name}`, req);
      res.status(201).json({
        _id: restaurant._id,
        name: restaurant.name,
        email: restaurant.email,
        role: restaurant.role,
        city: restaurant.city,
        district: restaurant.district,
        location: restaurant.location
      });
    } else {
      res.status(400).json({ message: 'Yanlış restoran məlumatları' });
    }
  } catch (error) {
    console.error('Create Restaurant Error:', error);
    res.status(500).json({ message: 'Server xətası yarandı.' });
  }
};

