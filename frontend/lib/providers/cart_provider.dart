import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CartItem {
  final String id; // unique id generated from name + variations
  final String productId; // Real product ID from MongoDB
  final String name;
  final String price;
  final String image;
  int quantity;
  final String? size;
  final String? addons;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.image,
    this.quantity = 1,
    this.size,
    this.addons,
  });
}

class CartProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final List<CartItem> _items = [];
  Map<String, dynamic>? _appliedCoupon;

  List<CartItem> get items => _items;
  Map<String, dynamic>? get appliedCoupon => _appliedCoupon;


  int get itemCount => _items.length;

  double get totalPrice {
    double total = 0;
    for (var item in _items) {
      total += (double.tryParse(item.price) ?? 0) * item.quantity;
    }
    return total;
  }

  double get discount {
    if (_appliedCoupon == null) return 0;
    
    final discountAmount = double.tryParse(_appliedCoupon!['discountAmount']?.toString() ?? '0') ?? 0;
    final discountType = _appliedCoupon!['discountType'];

    if (discountType == 'percent') {
      return (totalPrice * discountAmount) / 100;
    } else {
      return discountAmount;
    }
  }

  double get finalPrice {
    return totalPrice - discount;
  }


  void addItem(String productId, String name, String price, String image, {int quantity = 1, String? size, String? addons}) {
    // Generate a unique ID based on name + variations to avoid merging e.g. a Small Pizza with a Large Pizza
    final uniqueId = '${name}_${size ?? ''}_${addons ?? ''}';
    final existingIndex = _items.indexWhere((item) => item.id == uniqueId);
    
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(
        id: uniqueId, 
        productId: productId,
        name: name, 
        price: price, 
        image: image, 
        quantity: quantity,
        size: size,
        addons: addons,
      ));
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void increaseQuantity(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decreaseQuantity(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    _appliedCoupon = null;
    notifyListeners();
  }

  Future<String?> applyPromoCode(String code) async {
    try {
      final response = await _apiService.post('/coupons/validate', {'code': code});
      if (response != null) {
        _appliedCoupon = response;
        notifyListeners();
        return null; // Success, no error message
      }
      return 'Bilinməyən xəta';
    } catch (e) {
      final errorMsg = e.toString().contains('message') 
          ? e.toString().split('message:').last.split('}').first.trim()
          : 'Bağlantı xətası';
      return errorMsg;
    }
  }

  void removeCoupon() {
    _appliedCoupon = null;
    notifyListeners();
  }

  // Create Order in backend
  Future<Map<String, dynamic>?> createOrder({
    required Map<String, dynamic> shippingAddress,
    required String paymentMethod,
    DateTime? scheduledAt,
  }) async {
    try {
      final orderItems = _items.map((item) => {
        'name': item.name,
        'qty': item.quantity,
        'image': item.image,
        'price': double.tryParse(item.price) ?? 0.0,
        'product': item.productId,
      }).toList();

      final response = await _apiService.post('/orders', {
        'orderItems': orderItems,
        'shippingAddress': shippingAddress,
        'paymentMethod': paymentMethod,
        'itemsPrice': finalPrice,
        'shippingPrice': 8.0, // Default shipping price
        'totalPrice': finalPrice + 8.0,
        'scheduledAt': scheduledAt?.toIso8601String(),
      });

      if (response != null) {
        clear();
        return response;
      }
      return null;
    } catch (e) {
      debugPrint('Sifariş yaradılarkən xəta: $e');
      rethrow;
    }
  }
}
