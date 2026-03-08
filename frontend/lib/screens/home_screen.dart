import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/product_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/product_card.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> categories = ['Hamısı', 'Pizza', 'Burger', 'Qəlyanaltı', 'İçkilər', 'Digər'];
  int selectedCategoryIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  double _minPrice = 0;
  double _maxPrice = 10000;
  String _sortOption = '';
  
  void _applyFilters() {
    final catMap = {1: 'pizza', 2: 'burger', 3: 'snack', 4: 'drink', 5: 'other'};
    final category = selectedCategoryIndex > 0 ? (catMap[selectedCategoryIndex] ?? '') : '';
    
    Provider.of<ProductProvider>(context, listen: false).fetchProducts(
      keyword: _searchQuery,
      category: category,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      sort: _sortOption,
    );
  }

  List<dynamic> get _filteredProducts {
    // Backend handles everything now, so we just return the provider's list.
    return Provider.of<ProductProvider>(context).products;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  void _showFilterDialog() {
    double tempMin = _minPrice;
    double tempMax = _maxPrice;
    String tempSort = _sortOption;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text('Filtrlər', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                  ),
                  const SizedBox(height: 20),
                  Text('Qiymət aralığı (₼)', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: RangeValues(tempMin, tempMax > 100 ? 100 : tempMax), // Cap UI slider at 100 for visual
                    min: 0,
                    max: 100,
                    divisions: 20,
                    labels: RangeLabels('${tempMin.toInt()} ₼', tempMax > 100 ? '100+ ₼' : '${tempMax.toInt()} ₼'),
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (values) {
                      setModalState(() {
                        tempMin = values.start;
                        tempMax = values.end >= 100 ? 10000 : values.end; // If maxed on UI, basically no limit
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Sıralama', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Ən yenilər'),
                        selected: tempSort == '',
                        onSelected: (val) => setModalState(() => tempSort = ''),
                      ),
                      ChoiceChip(
                        label: const Text('Ucuzdan Bahaya'),
                        selected: tempSort == 'price_asc',
                        onSelected: (val) => setModalState(() => tempSort = 'price_asc'),
                      ),
                      ChoiceChip(
                        label: const Text('Bahadan Ucuza'),
                        selected: tempSort == 'price_desc',
                        onSelected: (val) => setModalState(() => tempSort = 'price_desc'),
                      ),
                      ChoiceChip(
                        label: const Text('Reytinqə Görə'),
                        selected: tempSort == 'rating',
                        onSelected: (val) => setModalState(() => tempSort = 'rating'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() {
                          _minPrice = tempMin;
                          _maxPrice = tempMax;
                          _sortOption = tempSort;
                        });
                        _applyFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Tətbiq et', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getLocationText() {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    if (user != null) {
      final addresses = user['addresses'] as List<dynamic>? ?? [];
      final defaultAddr = addresses.firstWhere(
        (a) => a['isDefault'] == true,
        orElse: () => addresses.isNotEmpty ? addresses.first : null,
      );
      if (defaultAddr != null) {
        final city = defaultAddr['city'] ?? '';
        final country = defaultAddr['country'] ?? '';
        if (city.isNotEmpty && country.isNotEmpty) {
          return '$city, $country';
        } else if (city.isNotEmpty) {
          return city;
        } else if (country.isNotEmpty) {
          return country;
        }
      }
    }
    return 'Ünvan əlavə edin';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationText = _getLocationText();
    final productProvider = Provider.of<ProductProvider>(context);
    final filtered = _filteredProducts;
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leadingWidth: 200,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Yerləşmə',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, size: 14, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      locationText,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, size: 16, color: isDark ? Colors.white : Colors.black87),
                ],
              ),
            ],
          ),
        ),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                onPressed: () => themeProvider.toggleTheme(),
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: isDark ? Colors.white : Colors.black,
                ),
              );
            },
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey.shade200),
              ),
              child: Stack(
                children: [
                  Icon(Icons.notifications_none, color: isDark ? Colors.white : Colors.black),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                  children: [
                    const TextSpan(text: 'Hər Günü\n'),
                    TextSpan(text: 'Ləzzətli Et', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Axtarış
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                        // Qısa gecikmə ilə axtarış funksiyası (debounce effect)
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (_searchQuery == value) _applyFilters();
                        });
                      },
                      onSubmitted: (_) => _applyFilters(),
                      decoration: InputDecoration(
                        hintText: 'Yemək və ya restoran axtar...',
                        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(icon: Icon(Icons.close, size: 18, color: isDark ? Colors.white : Colors.black), onPressed: () { 
                                _searchController.clear(); 
                                setState(() => _searchQuery = ''); 
                                _applyFilters();
                              })
                            : null,
                        filled: true,
                        fillColor: isDark ? Colors.grey[800] : Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _showFilterDialog,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.tune, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Kateqoriyalar
              const Text('Populyar Kateqoriyalar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final categoryIcons = [Icons.restaurant, Icons.local_pizza_outlined, Icons.lunch_dining_outlined, Icons.fastfood_outlined, Icons.local_drink_outlined, Icons.more_horiz];
                    final isSelected = index == selectedCategoryIndex;
                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedCategoryIndex = index);
                        _applyFilters();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 24),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? Theme.of(context).colorScheme.primary : (isDark ? Colors.grey[800] : Colors.grey.shade100),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(categoryIcons[index % categoryIcons.length], color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black)),
                            ),
                            const SizedBox(height: 8),
                            Text(categories[index], style: TextStyle(fontSize: 12, color: isSelected ? (isDark ? Colors.white : Colors.black) : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ən Çox Tövsiyə Olunan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () {}, child: Text('Hamısı', style: TextStyle(color: Theme.of(context).colorScheme.primary))),
                ],
              ),
              const SizedBox(height: 12),
              
                  productProvider.isLoading
                  ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                  : filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(Icons.search_off, size: 60, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            const Text('Nəticə tapılmadı', style: TextStyle(color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.53,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final product = filtered[index];
                        final title = product['name']?.toString() ?? '';
                        final isFav = wishlistProvider.isFavorite(title);
                        return ProductCard(
                          product: product as Map<String, dynamic>,
                          isFavorite: isFav,
                          onFavoriteToggle: () {
                            wishlistProvider.toggle(title);
                            final nowFav = wishlistProvider.isFavorite(title);
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(nowFav ? '$title sevimlilərə əlavə edildi ❤️' : '$title sevimlilərdən silindi'),
                                duration: const Duration(seconds: 1),
                                backgroundColor: nowFav ? Colors.redAccent : Colors.grey.shade700,
                              ),
                            );
                          },
                          onAddToCart: () {
                            cartProvider.addItem(title, product['price']?.toString() ?? '0', product['image']?.toString() ?? '');
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$title səbətə əlavə edildi 🛒'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

final List<Map<String, String>> mockProducts = [
  {'name': 'Toyuq Burger', 'price': '36.50', 'image': 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?q=80&w=1000&auto=format&fit=crop', 'rating': '4.8', 'reviews': '142', 'description': 'Ləzzətli xırtıldayan toyuq burgeri, ərimiş pendirlə.', 'category': 'burger'},
  {'name': 'Pendirli Burger', 'price': '36.50', 'image': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=1000&auto=format&fit=crop', 'rating': '4.9', 'reviews': '89', 'description': 'Xırtıldayan toyuq dolu böyük burger, üstündə ərimiş pendir.', 'category': 'burger'},
  {'name': 'Pepperoni Pizza', 'price': '42.00', 'image': 'https://images.unsplash.com/photo-1628840042765-356cda07504e?q=80&w=1000&auto=format&fit=crop', 'rating': '4.7', 'reviews': '210', 'description': 'Klassik pepperoni pizza, əlavə mozzarella ilə.', 'category': 'pizza'},
  {'name': 'Mal Əti Burger', 'price': '45.00', 'image': 'https://images.unsplash.com/photo-1553979459-d2229ba7433b?q=80&w=1000&auto=format&fit=crop', 'rating': '4.5', 'reviews': '67', 'description': 'Premium mal əti burgeri, karamelləşmiş soğan ilə.', 'category': 'burger'},
  {'name': 'Kola', 'price': '5.00', 'image': 'https://images.unsplash.com/photo-1554866585-cd94860890b7?q=80&w=1000&auto=format&fit=crop', 'rating': '4.3', 'reviews': '50', 'description': 'Soyuq və təravətli Coca-Cola.', 'category': 'drink'},
  {'name': 'Kartof Qızartması', 'price': '8.50', 'image': 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?q=80&w=1000&auto=format&fit=crop', 'rating': '4.6', 'reviews': '120', 'description': 'Xırtıldayan qızılı kartof qızartması, xüsusi sous ilə.', 'category': 'snack'},
];
