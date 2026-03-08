import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<dynamic> _products = [];
  List<dynamic> _myProducts = [];
  List<dynamic> _flashSales = [];
  List<dynamic> _recommendations = [];
  bool _isLoading = false;

  List<dynamic> get products => _products;
  List<dynamic> get myProducts => _myProducts;
  List<dynamic> get flashSales => _flashSales;
  List<dynamic> get recommendations => _recommendations;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts({
    String keyword = '',
    String category = '',
    double? minPrice,
    double? maxPrice,
    String sort = '',
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      List<String> queryParams = [];
      if (keyword.isNotEmpty) queryParams.add('keyword=$keyword');
      if (category.isNotEmpty && category != 'All') queryParams.add('category=$category');
      if (minPrice != null) queryParams.add('minPrice=$minPrice');
      if (maxPrice != null) queryParams.add('maxPrice=$maxPrice');
      if (sort.isNotEmpty) queryParams.add('sort=$sort');

      final queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final response = await _apiService.get('/products$queryString');
      
      if (response != null && response is List) {
        _products = response;
      }
    } catch (e) {
      print('Məhsullar gətirilərkən xəta: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFlashSales() async {
    try {
      final response = await _apiService.get('/products/flash-sales');
      if (response != null && response is List) {
        _flashSales = response;
        notifyListeners();
      }
    } catch (e) {
      print('Flash Sales gətirilərkən xəta: $e');
    }
  }

  Future<void> fetchRecommendations({String? category, String? exclude}) async {
    try {
      String query = '';
      if (category != null) query += '?category=$category';
      if (exclude != null) query += (query.isEmpty ? '?' : '&') + 'exclude=$exclude';
      
      final response = await _apiService.get('/products/recommendations$query');
      if (response != null && response is List) {
        _recommendations = response;
        notifyListeners();
      }
    } catch (e) {
      print('Tövsiyələr gətirilərkən xəta: $e');
    }
  }

  Future<void> searchByImage(String imagePath) async {
    _isLoading = true;
    notifyListeners();
    try {
      // In a real app, read file and send as base64 or multipart
      final response = await _apiService.post('/products/search-image', {
        'image': 'base64_placeholder' // Simulation
      });
      if (response != null && response['products'] is List) {
        _products = response['products'];
      }
    } catch (e) {
      print('Şəkil ilə axtarış xətası: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addReview(String productId, double rating, String comment, {List<String>? images}) async {
    try {
      await _apiService.post('/products/$productId/reviews', {
        'rating': rating,
        'comment': comment,
        'images': images ?? [],
      });
      await fetchProducts();
      return true;
    } catch (e) {
      print('Rəy əlavə edilərkən xəta: $e');
      return false;
    }
  }

  Future<bool> addProduct(Map<String, dynamic> productData) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.post('/products', productData);
      if (response != null) {
        await fetchProducts();
        return true;
      }
      return false;
    } catch (e) {
      print('Məhsul əlavə edilərkən xəta: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProduct(String id, Map<String, dynamic> productData) async {
    _isLoading = true;
    notifyListeners();
    try {
      final cleanId = id.trim();
      final response = await _apiService.put('/products/$cleanId', productData);
      if (response != null) {
        await fetchProducts();
        return true;
      }
      return false;
    } catch (e) {
      print('Məhsul yenilənərkən xəta: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final cleanId = id.trim();
      final response = await _apiService.delete('/products/$cleanId');
      if (response != null) {
        await fetchProducts();
        return true;
      }
      return false;
    } catch (e) {
      print('Məhsul silinərkən xəta: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.get('/products/myproducts');
      if (response != null && response is List) {
        _myProducts = response;
      }
    } catch (e) {
      print('Mənim elanlarım gətirilərkən xəta: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tək bir məhsulun mövcud məlumatını tapmaq üçün köməkçi
  Map<String, dynamic>? findById(String id) {
    try {
      return _products.firstWhere((p) => p['_id'] == id);
    } catch (e) {
      return null;
    }
  }
}
