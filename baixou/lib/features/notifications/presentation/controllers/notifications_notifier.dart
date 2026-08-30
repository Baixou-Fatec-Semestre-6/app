import 'dart:math';
import 'package:flutter/material.dart';
import 'package:baixou/features/notifications/domain/entities/notification_item.dart';

class NotificationsNotifier extends ChangeNotifier {
  final List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationsNotifier() {
    _loadMockNotifications();
  }

  void _loadMockNotifications() {
    _notifications.addAll([
      NotificationItem(
        id: 301,
        userId: 1,
        productId: 101,
        productTitle: 'Kindle 11ª Geração (Lançamento 2022) - Mais leve, tela de 300 ppi',
        productImageUrl: 'https://m.media-amazon.com/images/I/71X0PGbcVRL._AC_SL1500_.jpg',
        oldPrice: 499.00,
        newPrice: 474.05,
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      NotificationItem(
        id: 302,
        userId: 1,
        productId: 102,
        productTitle: 'Apple iPhone 15 Pro (128 GB) - Titânio Natural',
        productImageUrl: 'https://m.media-amazon.com/images/I/81SigupXmOL._AC_SL1500_.jpg',
        oldPrice: 7599.00,
        newPrice: 7299.00,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);
  }

  void addNotification({
    required int productId,
    required String productTitle,
    String? productImageUrl,
    required double oldPrice,
    required double newPrice,
  }) {
    final newNotification = NotificationItem(
      id: Random().nextInt(10000) + 3000,
      userId: 1,
      productId: productId,
      productTitle: productTitle,
      productImageUrl: productImageUrl,
      oldPrice: oldPrice,
      newPrice: newPrice,
      isRead: false,
      createdAt: DateTime.now(),
    );

    _notifications.insert(0, newNotification); // Add to the top
    notifyListeners();
  }

  Future<void> markAsRead(int notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}
