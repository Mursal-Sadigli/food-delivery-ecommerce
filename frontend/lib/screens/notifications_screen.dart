import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Bildirişlər', 
          style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: notificationProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificationProvider.notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text('Bildiriş yoxdur', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notificationProvider.notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notificationProvider.notifications[index];
                    final isRead = notif.isRead;

                    return GestureDetector(
                      onTap: () {
                        if (!isRead) {
                          notificationProvider.markAsRead(notif.id);
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isRead 
                            ? (isDark ? Colors.grey[800] : Colors.white) 
                            : (isDark ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Theme.of(context).colorScheme.primary.withOpacity(0.04)),
                          borderRadius: BorderRadius.circular(16),
                          border: isRead ? null : Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.15)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getIcon(notif.type), 
                                color: Theme.of(context).colorScheme.primary, 
                                size: 24
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notif.title,
                                          style: TextStyle(
                                            fontWeight: isRead ? FontWeight.w500 : FontWeight.bold, 
                                            fontSize: 15,
                                            color: isDark ? Colors.white : Colors.black,
                                          ),
                                        ),
                                      ),
                                      if (!isRead)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    notif.body,
                                    style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, height: 1.4),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _formatDate(notif.date),
                                    style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'order': return Icons.delivery_dining;
      case 'wallet': return Icons.account_balance_wallet;
      case 'promo': return Icons.local_offer;
      default: return Icons.notifications;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
