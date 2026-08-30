import '../entities/notification_item.dart';

abstract class NotificationsRepository {
  Future<List<NotificationItem>> getNotifications();
  Future<void> markAsRead(int notificationId);
  Future<void> markAllAsRead();
}
