const Product = require('../models/Product');
const Review = require('../models/Review');
const cache = require('../utils/cache');
const sharp = require('sharp');

// Get all products + Search req.query.keyword + filters
exports.getProducts = async (req, res) => {
  try {
    // Generate cache key based on query params
    const cacheKey = `products_${JSON.stringify(req.query)}`;
    const cachedData = cache.get(cacheKey);
    
    if (cachedData) {
      return res.json(cachedData);
    }

    const keyword = req.query.keyword
      ? { name: { $regex: req.query.keyword, $options: 'i' } }
      : {};

    const categoryMatch = req.query.category && req.query.category !== 'All' 
      ? { category: req.query.category } 
      : {};

    // Price filters
    const minPrice = req.query.minPrice ? Number(req.query.minPrice) : 0;
    const maxPrice = req.query.maxPrice ? Number(req.query.maxPrice) : 10000;
    const priceMatch = { price: { $gte: minPrice, $lte: maxPrice } };

    // Sorting
    let sortObj = { createdAt: -1 }; // default newest
    if (req.query.sort === 'price_asc') sortObj = { price: 1 };
    if (req.query.sort === 'price_desc') sortObj = { price: -1 };
    if (req.query.sort === 'rating') sortObj = { rating: -1 };

    const products = await Product.find({ ...keyword, ...categoryMatch, ...priceMatch })
                                  .sort(sortObj);

    // Cache the result for 5 minutes
    cache.set(cacheKey, products, 300);

    res.json(products);
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
};

// Get products of logged in user
exports.getMyProducts = async (req, res) => {
  try {
    const products = await Product.find({ user: req.user._id }).sort({ createdAt: -1 });
    res.json(products);
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
};

// Get single product
exports.getProductById = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (product) {
      res.json(product);
    } else {
      res.status(404).json({ message: 'Məhsul tapılmadı' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
};

// Create product (Admin)
exports.createProduct = async (req, res) => {
  try {
    const { name, price, description, image, brand, category, countInStock, sellerName, sellerPhone } = req.body;
    
    let optimizedImage = image || '/images/sample.jpg';

    // Optimize base64 image if provided
    if (image && image.startsWith('data:image')) {
      try {
        const base64Data = image.split(';base64,').pop();
        const imgBuffer = Buffer.from(base64Data, 'base64');
        
        const processedBuffer = await sharp(imgBuffer)
          .resize(800, 800, { fit: 'inside', withoutEnlargement: true })
          .webp({ quality: 80 })
          .toBuffer();
        
        optimizedImage = `data:image/webp;base64,${processedBuffer.toString('base64')}`;
      } catch (sharpError) {
        console.error('Sharp optimization error (create):', sharpError);
        // Fallback to original image if optimization fails
      }
    }

    const product = new Product({
      name: name || 'Adsız Məhsul',
      price: price || 0,
      user: req.user._id,
      image: optimizedImage,
      brand: brand || 'Brendsiz',
      category: category || 'Digər',
      countInStock: countInStock || 1,
      numReviews: 0,
      description: description || 'Təsvir yoxdur',
      sellerName,
      sellerPhone,
      isFlashSale: req.body.isFlashSale || false,
      flashSalePrice: req.body.flashSalePrice,
      flashSaleEndDate: req.body.flashSaleEndDate
    });

    const createdProduct = await product.save();
    
    // Clear cache when new product is added
    cache.clear();
    
    res.status(201).json(createdProduct);
  } catch (error) {
    console.error('Məhsul yaratma xətası:', error);
    res.status(500).json({ message: 'Server xətası' });
  }
};

// Update product (Owner or Admin)
exports.updateProduct = async (req, res) => {
  try {
    const { name, price, description, image, brand, category, countInStock, sellerName, sellerPhone } = req.body;
    const product = await Product.findById(req.params.id);

    if (product) {
      // Check ownership or admin status
      if (product.user.toString() !== req.user._id.toString() && !req.user.isAdmin) {
        return res.status(401).json({ message: 'Bu məhsulu redaktə etməyə icazəniz yoxdur' });
      }

      product.name = name || product.name;
      product.price = price || product.price;
      product.description = description || product.description;
      
      // Optimize image if it's a new base64 string
      if (image && image.startsWith('data:image') && image !== product.image) {
        try {
          const base64Data = image.split(';base64,').pop();
          const imgBuffer = Buffer.from(base64Data, 'base64');
          
          const processedBuffer = await sharp(imgBuffer)
            .resize(800, 800, { fit: 'inside', withoutEnlargement: true })
            .webp({ quality: 80 })
            .toBuffer();
          
          product.image = `data:image/webp;base64,${processedBuffer.toString('base64')}`;
        } catch (sharpError) {
          console.error('Sharp optimization error (update):', sharpError);
          product.image = image;
        }
      } else if (image) {
        product.image = image;
      }

      product.brand = brand || product.brand;
      product.category = category || product.category;
      product.countInStock = countInStock !== undefined ? countInStock : product.countInStock;
      product.sellerName = sellerName || product.sellerName;
      product.sellerPhone = sellerPhone || product.sellerPhone;
      product.isFlashSale = req.body.isFlashSale !== undefined ? req.body.isFlashSale : product.isFlashSale;
      product.flashSalePrice = req.body.flashSalePrice || product.flashSalePrice;
      product.flashSaleEndDate = req.body.flashSaleEndDate || product.flashSaleEndDate;

      const updatedProduct = await product.save();
      
      // Clear cache on update
      cache.clear();
      
      res.json(updatedProduct);
    } else {
      res.status(404).json({ message: 'Məhsul tapılmadı' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
};

// Delete product (Owner or Admin)
exports.deleteProduct = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (product) {
      // Check ownership or admin status
      if (product.user.toString() !== req.user._id.toString() && !req.user.isAdmin) {
        return res.status(401).json({ message: 'Bu məhsulu silməyə icazəniz yoxdur' });
      }

      await product.deleteOne();
      res.json({ message: 'Məhsul silindi' });
    } else {
      res.status(404).json({ message: 'Məhsul tapılmadı' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
};

// Add product review
exports.createProductReview = async (req, res) => {
  try {
    const { rating, comment, images } = req.body;
    const product = await Product.findById(req.params.id);

    if (product) {
      const alreadyReviewed = product.reviews.find(
        (r) => r.user.toString() === req.user._id.toString()
      );

      const reviewImages = [];
      if (images && Array.isArray(images)) {
        for (let img of images) {
          if (img.startsWith('data:image')) {
            try {
              const base64Data = img.split(';base64,').pop();
              const processedBuffer = await sharp(Buffer.from(base64Data, 'base64'))
                .resize(600, 600, { fit: 'inside', withoutEnlargement: true })
                .webp({ quality: 75 })
                .toBuffer();
              reviewImages.push(`data:image/webp;base64,${processedBuffer.toString('base64')}`);
            } catch (e) {
              reviewImages.push(img);
            }
          } else {
            reviewImages.push(img);
          }
        }
      }

      if (alreadyReviewed) {
        // Update existing review in Product model
        alreadyReviewed.rating = Number(rating);
        alreadyReviewed.comment = comment;
        alreadyReviewed.images = reviewImages;
        alreadyReviewed.name = req.user.name;
      } else {
        // Create new review in Product model
        const review = {
          name: req.user.name,
          rating: Number(rating),
          comment,
          user: req.user._id,
          images: reviewImages
        };
        product.reviews.push(review);
      }

      product.numReviews = product.reviews.length;
      product.rating =
        product.reviews.reduce((acc, item) => item.rating + acc, 0) / product.reviews.length;

      await product.save();

      // Upsert separate Review record for the Admin Panel
      try {
        await Review.findOneAndUpdate(
          { user: req.user._id, product: product._id },
          {
            user: req.user._id,
            name: req.user.name,
            rating: Number(rating),
            comment,
            product: product._id,
            images: reviewImages
          },
          { upsert: true, new: true }
        );
      } catch (reviewErr) {
        console.error('Separate Review upsert failed:', reviewErr);
      }

      // Clear cache
      cache.clear();

      return res.status(201).json({ message: alreadyReviewed ? 'Rəy yeniləndi' : 'Rəy əlavə edildi' });
    } else {
      res.status(404).json({ message: 'Məhsul tapılmadı' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
};
// Get recommendations based on current product category or popular
exports.getRecommendations = async (req, res) => {
  try {
    const { category, exclude } = req.query;
    let query = { rating: { $gte: 4 } };
    
    if (category) {
      query = { category, _id: { $ne: exclude } };
    }

    let products = await Product.find(query).limit(6);
    
    // If fewer than 4 recommendations, get general top rated
    if (products.length < 4) {
      const topRated = await Product.find({ _id: { $ne: exclude } })
                                    .sort({ rating: -1 })
                                    .limit(6);
      products = [...products, ...topRated].filter((v, i, a) => a.findIndex(t => (t._id.toString() === v._id.toString())) === i).slice(0, 6);
    }

    res.json(products);
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
};

// Placeholder for Image Search
exports.searchByImage = async (req, res) => {
  try {
    // In a real app, we would use an AI model (like Google Vision or a custom ML model)
    // to analyze req.body.image (base64) and find similar products.
    // For now, we return random products as a simulation.
    const products = await Product.find().limit(4);
    res.json({
      message: 'Şəkil analizi tamamlandı',
      products: products
    });
  } catch (error) {
    res.status(500).json({ message: 'Şəkil analizi zamanı xəta' });
  }
};
// Get current flash sales
exports.getFlashSales = async (req, res) => {
  try {
    const products = await Product.find({ 
      isFlashSale: true,
      flashSaleEndDate: { $gt: new Date() } 
    }).limit(10);
    res.json(products);
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
};

// Get Food Discovery Feed (Instagram Style)
exports.getDiscoveryFeed = async (req, res) => {
  try {
    // 1. Trending Foods (Highest rating)
    const trendingFoods = await Product.find({ rating: { $gte: 4.5 } })
      .sort({ rating: -1 })
      .limit(10);

    // 2. New Restaurants (Users with role 'shop', recently created)
    const User = require('../models/User');
    const newRestaurants = await User.find({ role: 'shop' })
      .sort({ createdAt: -1 })
      .limit(5)
      .select('name profileImage address');

    // 3. Just for you (Based on popularity)
    const popularProducts = await Product.find({})
      .sort({ numReviews: -1 })
      .limit(10);

    res.json({
      trending: trendingFoods,
      restaurants: newRestaurants,
      popular: popularProducts
    });
  } catch (error) {
    console.error('Discovery Feed Error:', error);
    res.status(500).json({ message: 'Discovery feed yüklənərkən xəta' });
  }
};
