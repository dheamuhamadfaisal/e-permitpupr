import '../services/notification_service.dart';

class NotificationRepository {
  final NotificationService _service;

  NotificationRepository({NotificationService? service})
      : _service = service ?? NotificationService();

  Future<PaginatedNotification> getNotifications({int page = 1}) {
    return _service.getNotifications(page: page);
  }

  Future<void> markAsRead(String id) => _service.markAsRead(id);

  Future<void> markAllAsRead() => _service.markAllAsRead();
}
