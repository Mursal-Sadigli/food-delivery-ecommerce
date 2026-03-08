import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  bool _isLoading = false;
  Map<String, dynamic>? _user;
  String? _socialLoginError;
  String? _authError;
  bool _twoFactorRequired = false;
  String? _twoFactorEmail;

  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _user;
  String? get socialLoginError => _socialLoginError;
  String? get authError => _authError;
  bool get twoFactorRequired => _twoFactorRequired;
  String? get twoFactorEmail => _twoFactorEmail;

  final ApiService _apiService = ApiService();

  AuthProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    notifyListeners();
  }

  void _extractAndSetError(dynamic e) {
    String errorString = e.toString();
    if (errorString.contains('{')) {
      try {
        final jsonPart = errorString.substring(errorString.indexOf('{'));
        final map = jsonDecode(jsonPart);
        if (map['message'] != null) {
          _authError = map['message'];
          return;
        }
      } catch (_) {}
    }
    _authError = 'Xəta baş verdi. Zəhmət olmasa yenidən yoxlayın.';
  }

  Future<bool> register(String name, String email, String password, {String? referralCode}) async {
    _isLoading = true;
    _authError = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        'referralCode': referralCode,
      });

      if (response['token'] != null) {
        _token = response['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _authError = 'Gözlənilməyən server cavabı';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _extractAndSetError(e);
      print('Qeydiyyat xətası API səviyyəsində: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
     _isLoading = true;
     _authError = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response['twoFactorRequired'] == true) {
        _twoFactorRequired = true;
        _twoFactorEmail = response['email'];
        _isLoading = false;
        notifyListeners();
        return false; // Will trigger navigation in UI
      }

      if (response['token'] != null) {
        _token = response['token'];
        _twoFactorRequired = false;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
         _authError = 'Gözlənilməyən server cavabı';
         _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _extractAndSetError(e);
       _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }

  Future<void> fetchProfile() async {
    if (_token == null) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
    }
    
    if (_token == null) {
      _user = {}; // Boş profil göstərmək üçün
      notifyListeners();
      return;
    }

    try {
      final response = await _apiService.get('/users/profile');
      if (response != null && response['_id'] != null) {
        _user = response;
      } else {
        _user = {}; // Yüklənmə prosesinin sonsuz olmaması üçün
      }
      notifyListeners();
    } catch (e) {
      print('Profil yüklənərkən xəta: $e');
      _user = {}; // Yüklənmə prosesinin sonsuz olmaması üçün
      notifyListeners();
    }
  }

  Future<bool> updateProfile(String name, String email, String address, {String? profileImage}) async {
    if (_token == null) return false;
    _isLoading = true;
    notifyListeners();
    try {
      final body = {
        'name': name,
        'email': email,
        'address': address
      };
      if (profileImage != null) body['profileImage'] = profileImage;
      
      final response = await _apiService.post('/users/profile', body);

      if (response != null && response['_id'] != null) {
        _user = response;
        if (response['token'] != null) {
           _token = response['token'];
           final prefs = await SharedPreferences.getInstance();
           await prefs.setString('token', _token!);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Profil güncəllənərkən xəta: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addAddress(Map<String, dynamic> addressData) async {
    if (_token == null) return false;
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.post('/users/address', addressData);
      if (response != null) {
        _user?['addresses'] = response;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Ünvan əlavə edilərkən xəta: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeAddress(String id) async {
    if (_token == null) return false;
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.delete('/users/address/$id');
      if (response != null) {
        _user?['addresses'] = response;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Ünvan silinərkən xəta: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addPaymentMethod(Map<String, dynamic> methodData) async {
    if (_token == null) return false;
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.post('/users/payment', methodData);
      if (response != null) {
        _user?['paymentMethods'] = response;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Ödəniş üsulu əlavə edilərkən xəta: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removePaymentMethod(String id) async {
    if (_token == null) return false;
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.delete('/users/payment/$id');
      if (response != null) {
        _user?['paymentMethods'] = response;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Ödəniş üsulu silinərkən xəta: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _authError = null;
    notifyListeners();
    try {
      final response = await _apiService.post('/auth/forgot-password', {'email': email});
      _isLoading = false;
      notifyListeners();
      return response != null && response['message'] != null;
    } catch (e) {
      _extractAndSetError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verify2FA(String email, String code) async {
    _isLoading = true;
    _authError = null;
    notifyListeners();
    try {
      final response = await _apiService.post('/auth/verify-2fa', {
        'email': email,
        'code': code,
      });

      if (response['token'] != null) {
        _token = response['token'];
        _twoFactorRequired = false;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _extractAndSetError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggle2FA() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.post('/auth/toggle-2fa', {});
      if (response != null && response['isTwoFactorEnabled'] != null) {
        if (_user != null) {
          _user!['isTwoFactorEnabled'] = response['isTwoFactorEnabled'];
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email, String token, String newPassword) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.post('/auth/reset-password', {
        'email': email,
        'token': token,
        'newPassword': newPassword,
      });
      _isLoading = false;
      notifyListeners();
      return response != null && response['message'] != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> socialLogin(String provider) async {
    _isLoading = true;
    _socialLoginError = null;
    notifyListeners();

    // Platform yoxlaması: Google/Apple Sign-In yalnız mobil platformalarda işləyir
    bool isMobile = false;
    if (!kIsWeb) {
      try {
        isMobile = Platform.isAndroid || Platform.isIOS;
      } catch (_) {
        isMobile = false;
      }
    }

    if (!isMobile) {
      _socialLoginError = '$provider login is only available on mobile devices (Android/iOS). Please test on a real device or emulator.';
      print(_socialLoginError);
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      String? email;
      String? name;
      String? idToken;

      if (provider == 'Google') {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? account = await googleSignIn.signIn();
        if (account == null) {
          _isLoading = false;
          notifyListeners();
          return false;
        }
        email = account.email;
        name = account.displayName;
        final authentication = await account.authentication;
        idToken = authentication.idToken;
      } else if (provider == 'Apple') {
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [],
        );
        email = credential.email;
        name = '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim();
        idToken = credential.identityToken;
      }

      if (email == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Backend-ə göndər
      final response = await _apiService.post('/auth/social', {
        'email': email,
        'name': name ?? 'Sosial İstifadəçi',
        'provider': provider,
        'idToken': idToken,
      });

      if (response != null && response['token'] != null) {
        _token = response['token'];
        _user = response;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _socialLoginError = 'Social login error: $e';
      print('Sosial giriş xətası: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

