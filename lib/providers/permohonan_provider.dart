import 'package:flutter/foundation.dart';
import '../core/utils/api_exception.dart';
import '../models/permohonan_model.dart';
import '../repositories/permohonan_repository.dart';

class PermohonanProvider extends ChangeNotifier {
  final PermohonanRepository _repository;

  PermohonanProvider({PermohonanRepository? repository})
      : _repository = repository ?? PermohonanRepository();

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
      _error = 'Gagal Memuat Permohonan';
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
      _selectedPermohonan = await _repository.getPermohonanDetail(id);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Gagal Memuat Detail Permohonan';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PermohonanModel?> createPermohonan({
    required int jenisPerizinanId,
    int? krkTerkaitId,
    String? namaPerusahaan,
    String? namaDirektur,
    String? noHpPenanggungJawab,
    String? rencanaKegiatan,
    String? alamatLengkap,
    String? luasArea,
    required String keterangan,
  }) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newPermohonan = await _repository.createPermohonan(
        jenisPerizinanId: jenisPerizinanId,
        krkTerkaitId: krkTerkaitId,
        namaPerusahaan: namaPerusahaan,
        namaDirektur: namaDirektur,
        noHpPenanggungJawab: noHpPenanggungJawab,
        rencanaKegiatan: rencanaKegiatan,
        alamatLengkap: alamatLengkap,
        luasArea: luasArea,
        keterangan: keterangan,
      );
      _isActionLoading = false;
      fetchPermohonan(page: 1); // Refresh list
      return newPermohonan;
    } on ApiException catch (e) {
      _error = e.message;
      _isActionLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = 'Gagal Membuat Permohonan';
      _isActionLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updatePermohonan({
    required int id,
    int? jenisPerizinanId,
    int? krkTerkaitId,
    String? namaPerusahaan,
    String? namaDirektur,
    String? noHpPenanggungJawab,
    String? rencanaKegiatan,
    String? alamatLengkap,
    String? luasArea,
    String? keterangan,
  }) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _repository.updatePermohonan(
        id: id,
        jenisPerizinanId: jenisPerizinanId,
        krkTerkaitId: krkTerkaitId,
        namaPerusahaan: namaPerusahaan,
        namaDirektur: namaDirektur,
        noHpPenanggungJawab: noHpPenanggungJawab,
        rencanaKegiatan: rencanaKegiatan,
        alamatLengkap: alamatLengkap,
        luasArea: luasArea,
        keterangan: keterangan,
      );
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
      _error = 'Gagal Mengupdate Permohonan';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> ajukanPermohonan(int id) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      final submitted = await _repository.ajukanPermohonan(id);
      _selectedPermohonan = submitted;
      _isActionLoading = false;
      fetchPermohonan(page: _currentPage);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Gagal Mengajukan Permohonan';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }
}
