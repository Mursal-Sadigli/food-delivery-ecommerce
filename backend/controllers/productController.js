const Product = require('../models/Product');

// Get all products + Search req.query.keyword + filters
exports.getProducts = async (req, res) => {
  try {
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
    const product = new Product({
      name: 'Nümunə Məhsul',
      price: 0,
      user: req.user._id,
      image: '/images/sample.jpg',
      brand: 'Nümunə Brand',
      category: 'Nümunə Kateqoriya',
      countInStock: 0,
      numReviews: 0,
      description: 'Nümunə açıqlama',
    });

    const createdProduct = await product.save();
    res.status(201).json(createdProduct);
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
};

// Update product (Admin)
exports.updateProduct = async (req, res) => {
  try {
    const { name, price, description, image, brand, category, countInStock } = req.body;
    const product = await Product.findById(req.params.id);

    if (product) {
      product.name = name;
      product.price = price;
      product.description = description;
      product.image = image;
      product.brand = brand;
      product.category = category;
      product.countInStock = countInStock;

      const updatedProduct = await product.save();
      res.json(updatedProduct);
    } else {
      res.status(404).json({ message: 'Məhsul tapılmadı' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
};

// Delete product (Admin)
exports.deleteProduct = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (product) {
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
    const { rating, comment } = req.body;
    const product = await Product.findById(req.params.id);

    if (product) {
      const alreadyReviewed = product.reviews.find(
        (r) => r.user.toString() === req.user._id.toString()
      );

      if (alreadyReviewed) {
        return res.status(400).json({ message: 'Siz artıq rəy bildirmisiniz' });
      }

      const review = {
        name: req.user.name,
        rating: Number(rating),
        comment,
        user: req.user._id,
      };

      product.reviews.push(review);
      product.numReviews = product.reviews.length;
      product.rating =
        product.reviews.reduce((acc, item) => item.rating + acc, 0) / product.reviews.length;

      await product.save();
      res.status(201).json({ message: 'Rəy əlavə edildi' });
    } else {
      res.status(404).json({ message: 'Məhsul tapılmadı' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server xətası' });
  }
};
