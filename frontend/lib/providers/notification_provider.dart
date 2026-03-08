import 'package:flutter/material.dart';
import '../services/api_service.dart';

class Notification {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime date;

  Notification({
    required this.id,
    required this.title,
    required this.body,
    this.type = 'general',
    this.isRead = false,
    required this.date,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['_id'],
      title: json['title'],
      body: json['body'],
      type: json['type'] ?? 'general',
      isRead: json['isRead'] ?? false,
      date: DateTime.parse(json['date']),
    );
  }
}

class NotificationProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Notification> _notifications = [];
  bool _isLoading = false;

  List<Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.get('/users/notifications');
      if (response != null && response is List) {
        _notifications = response.map((n) => Notification.fromJson(n)).toList();
      }
    } catch (e) {
      print('Bildirişlər gətirilərkən xəta: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _apiService.put('/users/notifications/$id/read', {});
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index >= 0) {
        _notifications[index] = Notification(
          id: _notifications[index].id,
          title: _notifications[index].title,
          body: _notifications[index].body,
          type: _notifications[index].type,
          isRead: true,
          date: _notifications[index].date,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Bildiriş oxunmuş kimi qeyd edilərkən xəta: $e');
    }
  }

  // Simulating receiving a notification locally + sending to backend
  // In a real app, FCM would trigger this
  void simulateNotification({required String title, required String body, String type = 'general'}) {
    // This is just for UI simulation. In a real flow, the backend would persist this.
    // For this demo, we assume the backend already has it or we just refresh.
    fetchNotifications();
  }
}
