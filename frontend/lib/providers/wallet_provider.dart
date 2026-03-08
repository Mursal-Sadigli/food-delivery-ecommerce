import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WalletProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  double _balance = 0;
  List<dynamic> _transactions = [];
  bool _isLoading = false;

  double get balance => _balance;
  List<dynamic> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<void> fetchWalletInfo() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.get('/wallet');
      if (response != null) {
        _balance = double.tryParse(response['balance']?.toString() ?? '0') ?? 0;
        _transactions = response['transactions'] ?? [];
      }
    } catch (e) {
      print('Cüzdan məlumatları gətirilərkən xəta: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deposit(double amount) async {
    try {
      final response = await _apiService.post('/wallet/deposit', {'amount': amount});
      if (response != null) {
        _balance = double.tryParse(response['balance']?.toString() ?? '0') ?? 0;
        _transactions = response['transactions'] ?? [];
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Balans artırılarkən xəta: $e');
      return false;
    }
  }
}
