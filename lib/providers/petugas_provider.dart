import 'package:flutter/foundation.dart';
import '../core/utils/api_exception.dart';
import '../models/permohonan_model.dart';
import '../repositories/petugas_repository.dart';

class PetugasProvider extends ChangeNotifier {
  final PetugasRepository _repository;

  PetugasProvider({PetugasRepository? repository})
      : _repository = repository ?? PetugasRepository();

  List<PermohonanModel> _items = [];
  PermohonanModel? _selectedPermohonan;
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _error;

  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;
  String _selectedStatus = '';
  String _selectedJenis = ''; // '' = Semua, 'KRK', 'SITEPLAN'
  String _searchQuery = '';

  // --- Arsip State ---
  List<PermohonanModel> _arsipItems = [];
  int _arsipCurrentPage = 1;
  int _arsipLastPage = 1;
  int _arsipTotal = 0;
  String _arsipKategori = 'survei'; // 'survei' | 'terbit'
  String _arsipPeriode = 'semua'; // 'hari_ini' | 'minggu_ini' | 'bulan_ini' | 'semua'
  String _arsipJenis = ''; // '' = Semua, 'KRK', 'SITEPLAN'
  bool _isArsipLoading = false;

  List<PermohonanModel> get items => _items;
  PermohonanModel? get selectedPermohonan => _selectedPermohonan;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get error => _error;

  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get total => _total;
  String get selectedStatus => _selectedStatus;
  String get selectedJenis => _selectedJenis;
  String get searchQuery => _searchQuery;

  // --- Arsip Getters ---
  List<PermohonanModel> get arsipItems => _arsipItems;
  int get arsipCurrentPage => _arsipCurrentPage;
  int get arsipLastPage => _arsipLastPage;
  int get arsipTotal => _arsipTotal;
  String get arsipKategori => _arsipKategori;
  String get arsipPeriode => _arsipPeriode;
  String get arsipJenis => _arsipJenis;
  bool get isArsipLoading => _isArsipLoading;

  void setFilter({String? status, String? jenis, String? search}) {
    if (status != null) _selectedStatus = status;
    if (jenis != null) _selectedJenis = jenis;
    if (search != null) _searchQuery = search;
    fetchPermohonan(page: 1);
  }

  void setArsipFilter({String? kategori, String? periode, String? jenis, String? search}) {
    if (kategori != null) _arsipKategori = kategori;
    if (periode != null) _arsipPeriode = periode;
    if (jenis != null) _arsipJenis = jenis;
    if (search != null) _arsipSearch = search;
    fetchArsip(page: 1);
  }

  String _arsipSearch = '';
  String get arsipSearch => _arsipSearch;

  Future<void> fetchPermohonan({int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _repository.getPermohonan(
        status: _selectedStatus.isEmpty ? null : _selectedStatus,
        jenis: _selectedJenis.isEmpty ? null : _selectedJenis,
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
      _error = 'Gagal Memuat Permohonan Petugas';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchArsip({int page = 1}) async {
    _isArsipLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _repository.getArsip(
        kategori: _arsipKategori,
        jenis: _arsipJenis.isEmpty ? null : _arsipJenis,
        periode: _arsipPeriode,
        search: _arsipSearch.isEmpty ? null : _arsipSearch,
        page: page,
      );
      _arsipItems = res.items;
      _arsipCurrentPage = res.currentPage;
      _arsipLastPage = res.lastPage;
      _arsipTotal = res.total;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Gagal Memuat Arsip Petugas';
    } finally {
      _isArsipLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDetail(int id) async {
    _isLoading = true;
    _error = null;
    _selectedPermohonan = null;
    notifyListeners();

    try {
      _selectedPermohonan = await _repository.getDetail(id);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Gagal Memuat Detail Permohonan Petugas';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> validasiKelengkapan({
    required int id,
    required String keputusan,
    bool? butuhKunjungan,
    String? catatan,
    dynamic fieldBermasalah,
    String? jenisPenolakan,
  }) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _repository.validasiKelengkapan(
        id: id,
        keputusan: keputusan,
        butuhKunjungan: butuhKunjungan,
        catatan: catatan,
        fieldBermasalah: fieldBermasalah,
        jenisPenolakan: jenisPenolakan,
      );
      _selectedPermohonan = updated;
      _isActionLoading = false;
      fetchPermohonan(page: _currentPage);
      return true;
    } on ApiException catch (e) {
      String msg = e.message;
      if (e.errors != null && e.errors!['exception'] != null) {
        msg += '\nDetail: ${e.errors!['exception']}';
      }
      _error = msg;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (e, stack) {
      _error = 'Error: $e';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> kunjunganLapangan({
    required int id,
    required String hasilSurvey,
    String? filePath,
  }) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _repository.kunjunganLapangan(
        id: id,
        hasilSurvey: hasilSurvey,
        filePath: filePath,
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
      _error = 'Gagal Menyimpan Hasil Kunjungan Lapangan';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> analisis({
    required int id,
    required String keputusan,
    String? catatan,
    dynamic fieldBermasalah,
    String? jenisPenolakan,
  }) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _repository.analisis(
        id: id,
        keputusan: keputusan,
        catatan: catatan,
        fieldBermasalah: fieldBermasalah,
        jenisPenolakan: jenisPenolakan,
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
      _error = 'Gagal Memproses Analisis';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> terbit({
    required int id,
    required String filePath,
  }) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _repository.terbit(id: id, filePath: filePath);
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
      _error = 'Gagal Menerbitkan Surat Perizinan';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }
}
