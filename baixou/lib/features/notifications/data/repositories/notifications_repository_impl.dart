import '../../../../core/network/api_client.dart';
import '../../domain/entities/notification_item.dart';
import '../../domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final ApiClient _api;

  NotificationsRepositoryImpl({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  @override
  Future<List<NotificationItem>> getNotifications() async {
    final response = await _api.get('/notifications');
    return (response['data'] as List? ?? const [])
        .map((item) => NotificationItem.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }

  @override
  Future<void> markAsRead(int notificationId) =>
      _api.patch('/notifications/$notificationId/read');

  @override
  Future<void> markAllAsRead() => _api.patch('/notifications/read-all');
}
