const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const app = express();

// Middleware
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));
app.use(cors());
app.use(helmet());
app.use(morgan('dev'));

// Routers
const authRoutes = require('./routes/authRoutes');
const productRoutes = require('./routes/productRoutes');
const cartRoutes = require('./routes/cartRoutes');
const orderRoutes = require('./routes/orderRoutes');
const userRoutes = require('./routes/userRoutes');
const chatRoutes = require('./routes/chatRoutes');
const couponRoutes = require('./routes/couponRoutes');
const referralRoutes = require('./routes/referralRoutes');
const subscriptionRoutes = require('./routes/subscriptionRoutes');
const walletRoutes = require('./routes/walletRoutes');
const adminRoutes = require('./routes/adminRoutes');
const courierRoutes = require('./routes/courierRoutes');
const settingRoutes = require('./routes/settingRoutes');
const maintenanceMiddleware = require('./middlewares/maintenanceMiddleware');

// Routing (əsas səhifə)
app.use('/api/settings', settingRoutes); // Public settings (MUST be before middleware)

// Maintenance Middleware - Sifariş, məhsul və digər bütün API-ləri qoruyur
app.use(maintenanceMiddleware);

app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/users', userRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/coupons', couponRoutes);
app.use('/api/wallet', walletRoutes);
app.use('/api/referral', referralRoutes);
app.use('/api/subscriptions', subscriptionRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/courier', courierRoutes);
app.get('/', (req, res) => {
  res.send('SmartMarket API işləyir...');
});

// Verilənlər bazasına qoşulma
const PORT = process.env.PORT || 5000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/smartmarket';

const http = require('http');
const { Server } = require('socket.io');
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: '*' } });
app.set('io', io);

io.on('connection', (socket) => {
  console.log('🔌 Socket qoşuldu:', socket.id);
  socket.on('disconnect', () => console.log('🔌 Socket ayrıldı:', socket.id));
});

mongoose
  .connect(MONGO_URI)
  .then(() => {
    console.log('MongoDB Mongoose ilə uğurla qoşuldu.');
    server.listen(PORT, () => {
      console.log(`Server ${PORT} portunda işə düşdü...`);
    });
  })
  .catch((err) => {
    console.error('MongoDB-yə qoşulma xətası:', err);
  });
