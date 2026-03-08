import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WalletProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  double _balance = 0;
  List<dynamic> _transactions = [];
  bool _isLoading = false;
  int _loyaltyPoints = 0;
  String _referralCode = "";
  bool _isPro = false;
  DateTime? _subscriptionExpiry;

  double get balance => _balance;
  List<dynamic> get transactions => _transactions;
  bool get isLoading => _isLoading;
  int get loyaltyPoints => _loyaltyPoints;
  String get referralCode => _referralCode;
  bool get isPro => _isPro;
  DateTime? get subscriptionExpiry => _subscriptionExpiry;

  Future<void> fetchWalletInfo() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.get('/wallet');
      if (response != null) {
        _balance = double.tryParse(response['balance']?.toString() ?? '0') ?? 0;
        _transactions = response['transactions'] ?? [];
      }
      
      // Referral və Loyalty statusunu gətir
      final refResponse = await _apiService.get('/referral/status');
      if (refResponse != null) {
        _referralCode = refResponse['referralCode'] ?? "";
        _loyaltyPoints = refResponse['loyaltyPoints'] ?? 0;
      }

      // Abunəlik statusunu gətir
      final subResponse = await _apiService.get('/subscriptions/status');
      if (subResponse != null) {
        _isPro = subResponse['isPro'] ?? false;
        if (subResponse['subscriptionExpiry'] != null) {
          _subscriptionExpiry = DateTime.parse(subResponse['subscriptionExpiry']);
        }
      }

    } catch (e) {
      print('Məlumatlar gətirilərkən xəta: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> convertPoints(int points) async {
    try {
      final response = await _apiService.post('/referral/convert', {'points': points});
      if (response != null) {
        await fetchWalletInfo();
        return true;
      }
      return false;
    } catch (e) {
      print('Xallar çevrilərkən xəta: $e');
      return false;
    }
  }

  Future<bool> purchasePro() async {
    try {
      final response = await _apiService.post('/subscriptions/purchase', {});
      if (response != null) {
        await fetchWalletInfo();
        return true;
      }
      return false;
    } catch (e) {
      print('Abunəlik alınarkən xəta: $e');
      return false;
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
