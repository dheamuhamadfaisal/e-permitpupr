import 'package:flutter/foundation.dart';
import '../core/utils/api_exception.dart';
import '../models/jenis_perizinan_model.dart';
import '../repositories/jenis_perizinan_repository.dart';

class JenisPerizinanProvider extends ChangeNotifier {
  final JenisPerizinanRepository _repository;

  JenisPerizinanProvider({JenisPerizinanRepository? repository})
      : _repository = repository ?? JenisPerizinanRepository();

  List<JenisPerizinanModel> _items = [];
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _error;

  List<JenisPerizinanModel> get items => _items;
  List<JenisPerizinanModel> get activeItems => _items.where((e) => e.status == 'aktif').toList();
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get error => _error;

  Future<void> fetchJenisPerizinan() async {
    if (!_isLoading) {
      _isLoading = true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _repository.getJenisPerizinan(all: true);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Gagal Memuat Jenis Perizinan';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update informasi layanan publik (deskripsi, tentang, alur)
  /// Digunakan oleh Operator di halaman Kelola Informasi Layanan
  Future<bool> updateLayananInfo({
    required int id,
    String? deskripsi,
    String? tentang,
    List<String>? alur,
  }) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _repository.updateLayananInfo(
        id: id,
        deskripsi: deskripsi,
        tentang: tentang,
        alur: alur,
      );

      // Update item lokal agar UI langsung berubah
      final index = _items.indexWhere((e) => e.id == id);
      if (index != -1) {
        _items[index] = updated;
      }

      _isActionLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Gagal Memperbarui Informasi Layanan';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }
}
