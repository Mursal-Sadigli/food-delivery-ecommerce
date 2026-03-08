import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CourierProvider with ChangeNotifier {
  Map<String, dynamic>? _profile;
  List<dynamic> _assignedOrders = [];
  List<dynamic> _orderHistory = [];
  Map<String, dynamic>? _earnings;
  bool _isOnline = false;
  bool _isLoading = false;
  Timer? _locationTimer;

  Map<String, dynamic>? get profile => _profile;
  List<dynamic> get assignedOrders => _assignedOrders;
  List<dynamic> get orderHistory => _orderHistory;
  Map<String, dynamic>? get earnings => _earnings;
  bool get isOnline => _isOnline;
  bool get isLoading => _isLoading;

  Future<void> fetchProfile() async {
    try {
      _profile = await ApiService().get('/courier/profile');
      _isOnline = _profile?['isOnline'] ?? false;
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> registerCourier({
    required String phone,
    required String vehicleType,
    String? licenseNumber,
  }) async {
    try {
      await ApiService().post('/courier/register', {
        'phone': phone,
        'vehicleType': vehicleType,
        'licenseNumber': licenseNumber ?? '',
      });
      await fetchProfile();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> fetchAssignedOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService().get('/courier/orders');
      _assignedOrders = res is List ? res : [];
    } catch (_) {
      _assignedOrders = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchOrderHistory() async {
    try {
      final res = await ApiService().get('/courier/orders/history');
      _orderHistory = res is List ? res : [];
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchEarnings() async {
    try {
      _earnings = await ApiService().get('/courier/earnings');
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> setAvailability(bool online) async {
    try {
      await ApiService().put('/courier/availability', {'isOnline': online});
      _isOnline = online;
      notifyListeners();
      if (online) {
        _startLocationUpdates();
      } else {
        _stopLocationUpdates();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await ApiService().put('/courier/orders/$orderId/status', {'status': status});
      await fetchAssignedOrders();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _startLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _sendMockLocation();
    });
  }

  void _stopLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  Future<void> _sendMockLocation() async {
    try {
      // Real app-da GPS istifadə edilər; burada mock koordinatlar
      await ApiService().post('/courier/location', {
        'lat': 40.4093 + (DateTime.now().millisecond * 0.000001),
        'lng': 49.8671 + (DateTime.now().millisecond * 0.000001),
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }
}
