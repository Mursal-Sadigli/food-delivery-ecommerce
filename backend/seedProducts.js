const mongoose = require('mongoose');
const dotenv = require('dotenv');
const Product = require('./models/Product');
const User = require('./models/User');

dotenv.config();

const mockProducts = [
  {
    name: 'Pendirli Pizza',
    price: 12.50,
    image: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?q=80&w=2069&auto=format&fit=crop',
    rating: 4.8,
    numReviews: 1,
    description: 'Təzə mozarella və xüsusi pomidor sousu ilə bişmiş klassik pizza.',
    category: 'pizza',
    brand: 'SmartFood',
    countInStock: 50,
    reviews: [
      {
        name: 'Admin User',
        rating: 5,
        comment: 'Əla pizza!',
        user: null // Will be assigned
      }
    ],
    sizes: [
      { name: 'Kiçik', price: 0 }, // base price
      { name: 'Orta', price: 4.0 }, // +4 AZN
      { name: 'Böyük', price: 8.0 }  // +8 AZN
    ],
    addons: [
      { name: 'Əlavə Pendir', price: 1.50 },
      { name: 'Zeytun', price: 1.00 },
      { name: 'Sosiska Kənarı', price: 2.50 }
    ]
  },
  {
    name: 'Double Burger',
    price: 8.90,
    image: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=1899&auto=format&fit=crop',
    rating: 4.5,
    numReviews: 1,
    description: 'İkiqat mal əti, çedar pendiri və karamelizə soğanlı xüsusi burger.',
    category: 'burger',
    brand: 'SmartFood',
    countInStock: 30,
    reviews: [
      {
        name: 'Admin User',
        rating: 4.5,
        comment: 'Çox dadlı.',
        user: null
      }
    ],
    sizes: [
      { name: 'Standart', price: 0 },
      { name: 'Meqa', price: 3.50 }
    ],
    addons: [
      { name: 'Karamelizə Soğan', price: 0.80 },
      { name: 'Ekstra Çedar Pendiri', price: 1.20 },
      { name: 'Acı Jalapeno', price: 0.50 }
    ]
  },
  {
    name: 'Toyuqlu Roll',
    price: 5.50,
    image: 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?q=80&w=2064&auto=format&fit=crop',
    rating: 4.2,
    numReviews: 0,
    description: 'Qızardılmış toyuq parçaları və xüsusi souslu ləzzətli roll.',
    category: 'snack',
    brand: 'SmartFood',
    countInStock: 20
  },
  {
    name: 'Coca Cola 0.5L',
    price: 2.00,
    image: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?q=80&w=2070&auto=format&fit=crop',
    rating: 4.9,
    numReviews: 0,
    description: 'Buz kimi sərinləşdirici Coca Cola buzlu stəkanda.',
    category: 'drink',
    brand: 'SmartFood',
    countInStock: 100
  },
  {
    name: 'Sezar Salat',
    price: 9.00,
    image: 'https://images.unsplash.com/photo-1550304943-4f24f54ddde9?q=80&w=2070&auto=format&fit=crop',
    rating: 4.6,
    numReviews: 0,
    description: 'Xırtıldayan aysberq, qril toyuq və parmesanlı sezar salatı.',
    category: 'other',
    brand: 'SmartFood',
    countInStock: 35
  },
  {
    name: 'Margarita Pizza',
    price: 10.00,
    image: 'https://images.unsplash.com/photo-1604068549290-dea0e4a305ca?q=80&w=1974&auto=format&fit=crop',
    rating: 4.7,
    numReviews: 0,
    description: 'Sadə və ləzzətli ənənəvi Margarita pizzası.',
    category: 'pizza',
    brand: 'SmartFood',
    countInStock: 45
  },
];

const seedData = async () => {
  try {
    console.log('URI Length:', process.env.MONGO_URI.trim().length);
    await mongoose.connect(process.env.MONGO_URI.trim());
    console.log('MongoDB qoşuldu.');

    let adminUser = await User.findOne({});
    if (!adminUser) {
      console.log('İstifadəçi tapılmadı. Yeni Admin istifadəçisi yaradılır...');
      const salt = await require('bcryptjs').genSalt(10);
      const hashedPassword = await require('bcryptjs').hash('admin123', salt);
      adminUser = await User.create({
        name: 'Admin User',
        email: 'admin@smartfood.com',
        password: hashedPassword,
        role: 'admin',
      });
      console.log('Admin istifadəçisi yaradıldı (admin@smartfood.com / admin123).');
    }

    // Clear existing products
    await Product.deleteMany();
    console.log('Köhnə məhsullar silindi.');

    const sampleProducts = mockProducts.map(p => {
      return { 
        ...p, 
        user: adminUser._id,
        reviews: p.reviews ? p.reviews.map(r => ({ ...r, user: adminUser._id })) : []
      };
    });

    await Product.insertMany(sampleProducts);
    console.log('Yeni məhsullar əlavə olundu!');
    process.exit();

  } catch (error) {
    console.error('Xəta: ', error);
    process.exit(1);
  }
};

seedData();
