import 'package:flutter/material.dart';

class WishlistProvider with ChangeNotifier {
  final Set<String> _favorites = {};

  Set<String> get favorites => _favorites;

  bool isFavorite(String productName) => _favorites.contains(productName);

  void toggle(String productName) {
    if (_favorites.contains(productName)) {
      _favorites.remove(productName);
    } else {
      _favorites.add(productName);
    }
    notifyListeners();
  }
}
