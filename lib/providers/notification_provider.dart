import 'package:flutter/foundation.dart';
import '../core/utils/api_exception.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;

  NotificationProvider({NotificationRepository? repository})
      : _repository = repository ?? NotificationRepository();

  List<NotificationModel> _items = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  int _currentPage = 1;
  int _lastPage = 1;

  List<NotificationModel> get items => _items;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;

  Future<void> fetchNotifications({int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _repository.getNotifications(page: page);
      _items = res.items;
      _unreadCount = res.unreadCount;
      _currentPage = res.currentPage;
      _lastPage = res.lastPage;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Gagal Memuat Notifikasi';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      final idx = _items.indexWhere((n) => n.id == id);
      if (idx != -1) {
        if (!_items[idx].isRead && _unreadCount > 0) {
          _unreadCount--;
        }
        _items[idx] = NotificationModel(
          id: _items[idx].id,
          type: _items[idx].type,
          data: _items[idx].data,
          readAt: DateTime.now().toIso8601String(),
          createdAt: _items[idx].createdAt,
        );
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      _unreadCount = 0;
      _items = _items.map((n) {
        return NotificationModel(
          id: n.id,
          type: n.type,
          data: n.data,
          readAt: DateTime.now().toIso8601String(),
          createdAt: n.createdAt,
        );
      }).toList();
      notifyListeners();
    } catch (_) {}
  }
}
