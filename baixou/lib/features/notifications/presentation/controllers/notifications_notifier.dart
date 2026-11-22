import 'package:flutter/material.dart';
import 'package:baixou/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:baixou/features/notifications/domain/entities/notification_item.dart';
import 'package:baixou/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsNotifier extends ChangeNotifier {
  final NotificationsRepository _repository;
  List<NotificationItem> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  NotificationsNotifier({NotificationsRepository? repository})
      : _repository = repository ?? NotificationsRepositoryImpl() {
    refresh();
  }

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((item) => !item.isRead).length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> refresh() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _notifications = await _repository.getNotifications();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId) async {
    await _repository.markAsRead(notificationId);
    final index = _notifications.indexWhere((item) => item.id == notificationId);
    if (index >= 0) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
    _notifications = _notifications
        .map((notification) => notification.copyWith(isRead: true))
        .toList();
    notifyListeners();
  }

  void clearNotifications() {
    _notifications = [];
    notifyListeners();
  }

  void addNotification({
    required int productId,
    required String productTitle,
    String? productImageUrl,
    required double oldPrice,
    required double newPrice,
  }) {
    refresh();
  }
}
