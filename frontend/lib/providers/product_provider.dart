import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<dynamic> _products = [];
  bool _isLoading = false;

  List<dynamic> get products => _products;
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

  Future<bool> addReview(String productId, double rating, String comment) async {
    try {
      await _apiService.post('/products/$productId/reviews', {
        'rating': rating,
        'comment': comment,
      });
      // Rəy bildirildikdən sonra məhsulları yenilə ki, rəy data-da görünsün
      await fetchProducts();
      return true;
    } catch (e) {
      print('Rəy əlavə edilərkən xəta: $e');
      return false;
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
