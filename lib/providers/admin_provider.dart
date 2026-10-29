import 'dart:io';
import 'package:flutter/foundation.dart';
import '../core/utils/api_exception.dart';
import '../models/jenis_perizinan_model.dart';
import '../models/permohonan_model.dart';
import '../models/user_model.dart';
import '../repositories/admin_repository.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepository _repository;

  AdminProvider({AdminRepository? repository})
      : _repository = repository ?? AdminRepository();

  // Users State
  List<UserModel> _users = [];
  bool _isUsersLoading = false;
  int _userCurrentPage = 1;
  int _userLastPage = 1;
  String _userRoleFilter = '';
  bool? _userActiveFilter;
  String _userSearchQuery = '';

  // Master Jenis Perizinan State
  List<JenisPerizinanModel> _jenisList = [];
  bool _isJenisLoading = false;

  // Monitoring State
  List<PermohonanModel> _monitoringList = [];
  bool _isMonitoringLoading = false;
  int _monCurrentPage = 1;
  int _monLastPage = 1;

  bool _isActionLoading = false;
  String? _error;

  // Getters
  List<UserModel> get users => _users;
  bool get isUsersLoading => _isUsersLoading;
  int get userCurrentPage => _userCurrentPage;
  int get userLastPage => _userLastPage;
  String get userRoleFilter => _userRoleFilter;

  List<JenisPerizinanModel> get jenisList => _jenisList;
  bool get isJenisLoading => _isJenisLoading;

  List<PermohonanModel> get monitoringList => _monitoringList;
  bool get isMonitoringLoading => _isMonitoringLoading;
  int get monCurrentPage => _monCurrentPage;
  int get monLastPage => _monLastPage;

  bool get isActionLoading => _isActionLoading;
  String? get error => _error;

  // ---------------------------------------------------------------------------
  // User Management
  // ---------------------------------------------------------------------------

  void setUserFilter({String? role, bool? isActive, String? search}) {
    if (role != null) _userRoleFilter = role;
    if (isActive != null) _userActiveFilter = isActive;
    if (search != null) _userSearchQuery = search;
    fetchUsers(page: 1);
  }

  Future<void> fetchUsers({int page = 1}) async {
    _isUsersLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _repository.getUsers(
        role: _userRoleFilter.isEmpty ? null : _userRoleFilter,
        isActive: _userActiveFilter,
        search: _userSearchQuery.isEmpty ? null : _userSearchQuery,
        page: page,
      );
      _users = res.items;
      _userCurrentPage = res.currentPage;
      _userLastPage = res.lastPage;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Gagal Memuat Daftar Pengguna';
    } finally {
      _isUsersLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUser({
    required String name,
    required String alamat,
    required String phone,
    required String email,
    required String password,
    required String role,
    bool isActive = true,
  }) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.createUser(
        name: name,
        alamat: alamat,
        phone: phone,
        email: email,
        password: password,
        role: role,
        isActive: isActive,
      );
      _isActionLoading = false;
      fetchUsers(page: 1);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Gagal Membuat Pengguna Baru';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser({
    required int id,
    String? name,
    String? alamat,
    String? phone,
    String? email,
    String? password,
    String? role,
    bool? isActive,
  }) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateUser(
        id: id,
        name: name,
        alamat: alamat,
        phone: phone,
        email: email,
        password: password,
        role: role,
        isActive: isActive,
      );
      _isActionLoading = false;
      fetchUsers(page: _userCurrentPage);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Gagal Memperbarui Pengguna';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteUser(id);
      _users.removeWhere((u) => u.id == id);
      _isActionLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Gagal Menghapus Pengguna';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Master Jenis Perizinan
  // ---------------------------------------------------------------------------

  Future<void> fetchMasterJenisPerizinan() async {
    _isJenisLoading = true;
    _error = null;
    notifyListeners();

    try {
      _jenisList = await _repository.getMasterJenisPerizinan();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Gagal Memuat Jenis Perizinan';
    } finally {
      _isJenisLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createJenisPerizinan({
    required String kode,
    required String nama,
    String? deskripsi,
    List<PersyaratanModel>? persyaratan,
    int estimasiWaktu = 14,
    int maxFileSizeMb = 5,
    String status = 'aktif',
    File? logoFile,
  }) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.createJenisPerizinan(
        kode: kode,
        nama: nama,
        deskripsi: deskripsi,
        persyaratan: persyaratan,
        estimasiWaktu: estimasiWaktu,
        maxFileSizeMb: maxFileSizeMb,
        status: status,
        logoFile: logoFile,
      );
      _isActionLoading = false;
      fetchMasterJenisPerizinan();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Gagal Membuat Jenis Perizinan';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateJenisPerizinan({
    required int id,
    String? kode,
    String? nama,
    String? deskripsi,
    List<PersyaratanModel>? persyaratan,
    int? estimasiWaktu,
    int? maxFileSizeMb,
    String? status,
    File? logoFile,
  }) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateJenisPerizinan(
        id: id,
        kode: kode,
        nama: nama,
        deskripsi: deskripsi,
        persyaratan: persyaratan,
        estimasiWaktu: estimasiWaktu,
        maxFileSizeMb: maxFileSizeMb,
        status: status,
        logoFile: logoFile,
      );
      _isActionLoading = false;
      fetchMasterJenisPerizinan();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Gagal Mengupdate Jenis Perizinan';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteJenisPerizinan(int id) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteJenisPerizinan(id);
      _jenisList.removeWhere((j) => j.id == id);
      _isActionLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Gagal Menghapus Jenis Perizinan';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Monitoring
  // ---------------------------------------------------------------------------

  Future<void> fetchMonitoring({
    String? status,
    int? jenisPerizinanId,
    String? startDate,
    String? endDate,
    String? search,
    int page = 1,
  }) async {
    _isMonitoringLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _repository.getMonitoring(
        status: status,
        jenisPerizinanId: jenisPerizinanId,
        startDate: startDate,
        endDate: endDate,
        search: search,
        page: page,
      );
      _monitoringList = res.items;
      _monCurrentPage = res.currentPage;
      _monLastPage = res.lastPage;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Gagal Memuat Data Monitoring';
    } finally {
      _isMonitoringLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteMonitoring(int id) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteMonitoring(id);
      _monitoringList.removeWhere((p) => p.id == id);
      _isActionLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Gagal Menghapus Permohonan';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  PermohonanModel? _selectedMonitoring;
  PermohonanModel? get selectedMonitoring => _selectedMonitoring;

  Future<void> fetchMonitoringDetail(int id) async {
    _isMonitoringLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedMonitoring = await _repository.getMonitoringDetail(id);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Gagal Mengambil Detail Monitoring';
    } finally {
      _isMonitoringLoading = false;
      notifyListeners();
    }
  }
}
