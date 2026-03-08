const Courier = require('../models/Courier');
const Order = require('../models/Order');
const User = require('../models/User');
const mongoose = require('mongoose');

// ─── Kuryer Qeydiyyatı ────────────────────────────────────────────
exports.registerCourier = async (req, res) => {
  try {
    const { phone, vehicleType, licenseNumber } = req.body;
    const userId = req.user._id;

    const existing = await Courier.findOne({ user: userId });
    if (existing) {
      return res.status(400).json({ message: 'Siz artıq kuryer kimi qeydiyyatdan keçmisiniz.' });
    }

    // User rolunu courier-a yüksəlt
    await User.findByIdAndUpdate(userId, { role: 'courier' });

    const courier = await Courier.create({
      user: userId,
      phone,
      vehicleType: vehicleType || 'motorcycle',
      licenseNumber
    });

    res.status(201).json({ message: 'Kuryer qeydiyyatı uğurlu oldu!', courier });
  } catch (err) {
    res.status(500).json({ message: 'Server xətası', error: err.message });
  }
};

// ─── Kuryer Profili ───────────────────────────────────────────────
exports.getCourierProfile = async (req, res) => {
  try {
    const courier = await Courier.findOne({ user: req.user._id }).populate('user', 'name email profileImage');
    if (!courier) return res.status(404).json({ message: 'Kuryer profili tapılmadı.' });
    res.json(courier);
  } catch (err) {
    res.status(500).json({ message: 'Server xətası', error: err.message });
  }
};

// ─── Konum Yeniləmə ───────────────────────────────────────────────
exports.updateLocation = async (req, res) => {
  try {
    const { lat, lng } = req.body;
    const courier = await Courier.findOneAndUpdate(
      { user: req.user._id },
      { currentLocation: { lat, lng, updatedAt: new Date() }, isOnline: true },
      { new: true }
    );
    if (!courier) return res.status(404).json({ message: 'Kuryer tapılmadı.' });

    // Aktiv sifarişin courierLocation-ını da yenilə
    await Order.updateMany(
      { courier: req.user._id, status: 'Kuryerə verildi' },
      { courierLocation: { lat, lng } }
    );

    // Socket.IO ilə broadcast et (əgər io mövcuddursa)
    if (req.app.get('io')) {
      req.app.get('io').emit(`courier_location_${req.user._id}`, { lat, lng });
    }

    res.json({ message: 'Konum yeniləndi', lat, lng });
  } catch (err) {
    res.status(500).json({ message: 'Server xətası', error: err.message });
  }
};

// ─── Online/Offline Toggle ────────────────────────────────────────
exports.setAvailability = async (req, res) => {
  try {
    const { isOnline } = req.body;
    const courier = await Courier.findOneAndUpdate(
      { user: req.user._id },
      { isOnline, isAvailable: isOnline },
      { new: true }
    );
    if (!courier) return res.status(404).json({ message: 'Kuryer tapılmadı.' });
    res.json({ message: `Kuryer indi ${isOnline ? 'onlayn' : 'oflayn'}`, courier });
  } catch (err) {
    res.status(500).json({ message: 'Server xətası', error: err.message });
  }
};

// ─── Kuryerə Verilmiş Sifarişlər ─────────────────────────────────
exports.getAssignedOrders = async (req, res) => {
  try {
    const orders = await Order.find({
      courier: req.user._id,
      status: { $in: ['Kuryerə verildi', 'Qapınızdadır'] }
    }).populate('user', 'name').sort({ createdAt: -1 });
    res.json(orders);
  } catch (err) {
    res.status(500).json({ message: 'Server xətası', error: err.message });
  }
};

// ─── Bütün Tamamlanmış Sifarişlər (Tarixçə) ──────────────────────
exports.getOrderHistory = async (req, res) => {
  try {
    const orders = await Order.find({
      courier: req.user._id,
      status: 'Çatdırıldı'
    }).populate('user', 'name').sort({ createdAt: -1 });
    res.json(orders);
  } catch (err) {
    res.status(500).json({ message: 'Server xətası', error: err.message });
  }
};

// ─── Sifarişin Statusunu Yenilə ───────────────────────────────────
exports.updateOrderStatus = async (req, res) => {
  try {
    const { status } = req.body;
    const order = await Order.findById(req.params.id);

    if (!order) return res.status(404).json({ message: 'Sifariş tapılmadı.' });
    if (order.courier?.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Bu sifarişi dəyişdirmək icazəniz yoxdur.' });
    }

    order.status = status;
    if (status === 'Çatdırıldı') {
      order.isDelivered = true;
      order.deliveredAt = new Date();

      // Qazancı hesabla (deliveryFee)
      const fee = order.deliveryFee || 2.0;
      const now = new Date();
      const weekStart = new Date(now);
      weekStart.setDate(now.getDate() - now.getDay());
      const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);

      await Courier.findOneAndUpdate(
        { user: req.user._id },
        {
          $inc: {
            'earnings.total': fee,
            'earnings.thisMonth': fee,
            'earnings.thisWeek': fee,
            totalDeliveries: 1
          },
          $push: {
            earningHistory: { orderId: order._id, amount: fee }
          }
        }
      );
    }

    await order.save();

    if (req.app.get('io')) {
      req.app.get('io').emit(`order_status_${order._id}`, { status });
    }

    res.json({ message: 'Sifariş statusu yeniləndi', order });
  } catch (err) {
    res.status(500).json({ message: 'Server xətası', error: err.message });
  }
};

// ─── Qazanc Məlumatları ───────────────────────────────────────────
exports.getEarnings = async (req, res) => {
  try {
    const courier = await Courier.findOne({ user: req.user._id });
    if (!courier) return res.status(404).json({ message: 'Kuryer tapılmadı.' });

    // Haftalıq/aylıq sıfırla logikası (sadə versiya)
    res.json({
      total: courier.earnings.total,
      thisMonth: courier.earnings.thisMonth,
      thisWeek: courier.earnings.thisWeek,
      totalDeliveries: courier.totalDeliveries,
      rating: courier.rating,
      history: courier.earningHistory.slice(-20).reverse()
    });
  } catch (err) {
    res.status(500).json({ message: 'Server xətası', error: err.message });
  }
};

// ─── Admin: Bütün Kuryerlər ───────────────────────────────────────
exports.getAllCouriers = async (req, res) => {
  try {
    const couriers = await Courier.find().populate('user', 'name email profileImage');
    res.json(couriers);
  } catch (err) {
    res.status(500).json({ message: 'Server xətası', error: err.message });
  }
};

// ─── Admin: Sifarişə Kuryer Təyin Et ─────────────────────────────
exports.assignCourier = async (req, res) => {
  try {
    const { courierId } = req.body;
    const order = await Order.findByIdAndUpdate(
      req.params.orderId,
      { courier: courierId, status: 'Kuryerə verildi' },
      { new: true }
    );
    if (!order) return res.status(404).json({ message: 'Sifariş tapılmadı.' });

    if (req.app.get('io')) {
      req.app.get('io').emit(`new_order_${courierId}`, { order });
    }

    res.json({ message: 'Kuryer təyin edildi', order });
  } catch (err) {
    res.status(500).json({ message: 'Server xətası', error: err.message });
  }
};

// ─── Admin: Gözləyən Sifarişlər (kuryer yox) ─────────────────────
exports.getPendingOrders = async (req, res) => {
  try {
    const orders = await Order.find({
      courier: null,
      status: { $in: ['Hazırlanır', 'Bişirilir'] }
    }).populate('user', 'name').sort({ createdAt: -1 });
    res.json(orders);
  } catch (err) {
    res.status(500).json({ message: 'Server xətası', error: err.message });
  }
};
