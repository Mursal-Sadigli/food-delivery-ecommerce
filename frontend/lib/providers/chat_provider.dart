import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<dynamic> _messages = [];
  bool _isLoading = false;

  List<dynamic> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> fetchMessages() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.get('/chat');
      if (response != null && response is List) {
        _messages = response;
      }
    } catch (e) {
      print('Mesajlar gətirilərkən xəta: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String content) async {
    // Immediately add user message to list for snappy UX
    _messages.add({'content': content, 'sender': '__me__', 'isAdmin': false});
    notifyListeners();

    try {
      await _apiService.post('/chat', {'content': content});
      // Wait 1.5s then refresh to get AI reply
      await Future.delayed(const Duration(milliseconds: 1500));
      await fetchMessages();
    } catch (e) {
      print('Mesaj göndərilərkən xəta: $e');
    }
  }
}
