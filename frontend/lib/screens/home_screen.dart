import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/product_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/voice_search_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'notifications_screen.dart';
import 'dart:async';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../widgets/countdown_timer.dart';

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
  
  final PageController _promoController = PageController();
  Timer? _promoTimer;

  final List<Map<String, dynamic>> _promos = [
    {
      'title': 'SmartMarket PRO',
      'subtitle': 'Hər sifarişdə 5% Cashback qazan!',
      'color': const Color(0xFFFF5722),
      'icon': Icons.rocket_launch_rounded,
    },
    {
      'title': 'Yalnız Bu Gün!',
      'subtitle': 'Bütün burgerlərə 20% endirim',
      'color': Colors.blueAccent,
      'icon': Icons.local_offer_rounded,
    },
    {
      'title': 'Dostunu Dəvət Et',
      'subtitle': 'Hər dost üçün 5 AZN bonus qazan',
      'color': Colors.green,
      'icon': Icons.card_giftcard_rounded,
    },
  ];
  
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
      Provider.of<ProductProvider>(context, listen: false).fetchFlashSales();
    });

    _promoTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_promoController.hasClients) {
        int next = (_promoController.page?.toInt() ?? 0) + 1;
        if (next >= _promos.length) next = 0;
        _promoController.animateToPage(
          next,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  Widget _buildCountdownTimer(String? endDateStr) {
    if (endDateStr == null) return const SizedBox.shrink();
    
    return CountdownTimerWidget(endDate: DateTime.parse(endDateStr));
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
    _promoController.dispose();
    _promoTimer?.cancel();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: source);
      
      if (!mounted) return;
      
      if (image != null) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Şəkil üzrə axtarış başladılır...')),
        );
        await productProvider.searchByImage(image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        String errorMsg = 'Şəkil seçilərkən xəta baş verdi.';
        if (e.toString().contains('cameraDelegate')) {
          errorMsg = 'Bu cihazda kamera dəstəklənmir. Zəhmət olmasa qalereyadan istifadə edin.';
        }
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Şəkil mənbəyini seçin',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Kamera',
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildSourceOption(
                  icon: Icons.photo_library,
                  label: 'Qalereya',
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 32),
            ),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
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
          IconButton(
            onPressed: () => _showImageSourceDialog(),
            icon: Icon(Icons.camera_alt_outlined, color: isDark ? Colors.white : Colors.black),
            tooltip: 'Axtarış (Şəkil)',
          ),
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

              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (_searchQuery == value) _applyFilters();
                          });
                        },
                        onSubmitted: (_) => _applyFilters(),
                        decoration: InputDecoration(
                          hintText: 'Yemək və ya restoran axtar...',
                          hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400], fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey[400] : Colors.grey[400]),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_searchQuery.isNotEmpty)
                                IconButton(
                                  icon: Icon(Icons.close, size: 18, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                    _applyFilters();
                                  },
                                ),
                              VoiceSearchWidget(
                                onResult: (text) {
                                  _searchController.text = text;
                                  setState(() => _searchQuery = text);
                                  _applyFilters();
                                },
                              ),
                            ],
                          ),
                          filled: false,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _showFilterDialog,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.tune, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildPromoCarousel(isDark),
              const SizedBox(height: 32),

              // Flash Sales Section
              if (productProvider.flashSales.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('Flash Sales', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        _buildCountdownTimer(productProvider.flashSales.first['flashSaleEndDate']),
                      ],
                    ),
                    TextButton(onPressed: () {}, child: Text('Hamısı', style: TextStyle(color: Theme.of(context).colorScheme.primary))),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: productProvider.flashSales.length,
                    itemBuilder: (context, index) {
                      final product = productProvider.flashSales[index];
                      return Container(
                        width: 180,
                        margin: const EdgeInsets.only(right: 16, bottom: 10),
                        child: ProductCard(
                          product: product,
                          isFavorite: wishlistProvider.isFavorite(product['name']),
                          onFavoriteToggle: () => wishlistProvider.toggle(product['name']),
                          onAddToCart: () {
                            cartProvider.addItem(product['_id'], product['name'], product['flashSalePrice']?.toString() ?? product['price'].toString(), product['image']);
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],

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
                  ? GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.53,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) => const SkeletonProductCard(),
                    )
                  : filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Lottie.network(
                              'https://lottie.host/809f6111-92b0-4bf6-8e5c-7d722ef5e921/Cq2C5X7O8v.json',
                              width: 150,
                              height: 150,
                            ),
                            const SizedBox(height: 12),
                            const Text('Nəticə tapılmadı', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
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
                            cartProvider.addItem(product['_id'], title, product['price']?.toString() ?? '0', product['image']?.toString() ?? '');
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

  Widget _buildPromoCarousel(bool isDark) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _promoController,
            itemCount: _promos.length,
            itemBuilder: (context, index) {
              final promo = _promos[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      promo['color'] as Color,
                      (promo['color'] as Color).withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (promo['color'] as Color).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(
                        promo['icon'] as IconData,
                        size: 140,
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            promo['title'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            promo['subtitle'] as String,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'İndi Yoxla',
                              style: TextStyle(
                                color: promo['color'] as Color,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SmoothPageIndicator(
          controller: _promoController,
          count: _promos.length,
          effect: ExpandingDotsEffect(
            dotHeight: 6,
            dotWidth: 6,
            activeDotColor: Theme.of(context).colorScheme.primary,
            dotColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          ),
        ),
      ],
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
