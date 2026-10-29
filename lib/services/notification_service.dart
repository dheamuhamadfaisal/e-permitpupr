import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/utils/api_exception.dart';
import '../models/notification_model.dart';

class PaginatedNotification {
  final List<NotificationModel> items;
  final int unreadCount;
  final int currentPage;
  final int lastPage;

  const PaginatedNotification({
    required this.items,
    required this.unreadCount,
    required this.currentPage,
    required this.lastPage,
  });
}

class NotificationService {
  final Dio _dio;

  NotificationService() : _dio = DioClient.instance;

  /// GET /api/notifications
  Future<PaginatedNotification> getNotifications({int page = 1}) async {
    try {
      final response = await _dio.get('/api/notifications', queryParameters: {'page': page});
      final data = response.data['data'] as Map<String, dynamic>;
      final unreadCount = data['unread_count'] as int? ?? 0;
      final notifData = data['notifications'] as Map<String, dynamic>;
      final list = notifData['data'] as List;

      final items = list
          .whereType<Map<String, dynamic>>()
          .map((n) => NotificationModel.fromJson(n))
          .toList();

      return PaginatedNotification(
        items: items,
        unreadCount: unreadCount,
        currentPage: notifData['current_page'] as int? ?? 1,
        lastPage: notifData['last_page'] as int? ?? 1,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Mengambil Notifikasi');
    }
  }

  /// POST /api/notifications/{id}/read
  Future<void> markAsRead(String id) async {
    try {
      await _dio.post('/api/notifications/$id/read');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Menandai Notifikasi');
    }
  }

  /// POST /api/notifications/read-all
  Future<void> markAllAsRead() async {
    try {
      await _dio.post('/api/notifications/read-all');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Menandai Semua Notifikasi');
    }
  }
}
