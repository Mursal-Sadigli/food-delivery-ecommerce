import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricProvider with ChangeNotifier {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isBiometricEnabled = false;
  bool _isAvailable = false;

  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isAvailable => _isAvailable;

  BiometricProvider() {
    _loadSettings();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    try {
      // Windows-da bəzən kanal tapılmaya bilər, ona görə try-catch vacibdir
      final bool canCheck = await _auth.canCheckBiometrics;
      final bool isSupported = await _auth.isDeviceSupported();
      _isAvailable = canCheck || isSupported;
      notifyListeners();
    } catch (e) {
      print('Biometrik dəstək yoxlanarkən xəta (Bəlkə bu platformada dəstəklənmir): $e');
      _isAvailable = false;
      notifyListeners();
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    notifyListeners();
  }

  Future<void> toggleBiometric(bool value) async {
    _isBiometricEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', value);
    notifyListeners();
  }

  Future<bool> authenticate() async {
    if (!_isBiometricEnabled || !_isAvailable) return true;

    try {
      return await _auth.authenticate(
        localizedReason: 'Tətbiqə giriş üçün identifikasiyadan keçin',
        // Bazalı istifadə edirik, çünki versiyaya görə options dərsi fərqli ola bilər
      );
    } catch (e) {
      print('Autentifikasiya xətası: $e');
      return false;
    }
  }
}
