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
    try {
      final response = await _apiService.post('/chat', {'content': content});
      if (response != null) {
        _messages.add(response);
        notifyListeners();
      }
    } catch (e) {
      print('Mesaj göndərilərkən xəta: $e');
    }
  }

  // Polling for new messages (simulating real-time)
  void startPolling() {
    // In a real app, use WebSockets. Here we poll every 5 seconds for simulation.
    Future.delayed(const Duration(seconds: 5), () async {
      await fetchMessages();
      startPolling();
    });
  }
}
