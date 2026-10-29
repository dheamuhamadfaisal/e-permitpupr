import 'package:flutter/foundation.dart';
import '../core/utils/api_exception.dart';
import '../models/permohonan_model.dart';
import '../repositories/verifikator_repository.dart';

class VerifikatorProvider extends ChangeNotifier {
  final VerifikatorRepository _repository;

  VerifikatorProvider({VerifikatorRepository? repository})
      : _repository = repository ?? VerifikatorRepository();

  List<PermohonanModel> _items = [];
  PermohonanModel? _selectedPermohonan;
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _error;

  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;
  String _selectedStatus = '';
  String _searchQuery = '';

  List<PermohonanModel> get items => _items;
  PermohonanModel? get selectedPermohonan => _selectedPermohonan;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get error => _error;

  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get total => _total;
  String get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;

  void setFilter({String? status, String? search}) {
    if (status != null) _selectedStatus = status;
    if (search != null) _searchQuery = search;
    fetchPermohonan(page: 1);
  }

  Future<void> fetchPermohonan({int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _repository.getPermohonan(
        status: _selectedStatus.isEmpty ? null : _selectedStatus,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        page: page,
      );
      _items = res.items;
      _currentPage = res.currentPage;
      _lastPage = res.lastPage;
      _total = res.total;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Gagal Memuat Permohonan Verifikator';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDetail(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedPermohonan = await _repository.getDetail(id);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Gagal Memuat Detail Permohonan Verifikator';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> setujui({required int id, String? catatan}) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _repository.setujui(id: id, catatan: catatan);
      _selectedPermohonan = updated;
      _isActionLoading = false;
      fetchPermohonan(page: _currentPage);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Gagal Menyetujui Permohonan';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> tolak({required int id, required String catatan}) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _repository.tolak(id: id, catatan: catatan);
      _selectedPermohonan = updated;
      _isActionLoading = false;
      fetchPermohonan(page: _currentPage);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Gagal Menolak Permohonan';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> revisi({required int id, required String catatan}) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _repository.revisi(id: id, catatan: catatan);
      _selectedPermohonan = updated;
      _isActionLoading = false;
      fetchPermohonan(page: _currentPage);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Gagal Mengembalikan Permohonan untuk Revisi';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }
}
