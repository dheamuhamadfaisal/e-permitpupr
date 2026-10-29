import 'dart:io';
import '../models/jenis_perizinan_model.dart';
import '../models/permohonan_model.dart';
import '../models/user_model.dart';
import '../services/admin_service.dart';
import '../services/permohonan_service.dart';

class AdminRepository {
  final AdminService _service;

  AdminRepository({AdminService? service})
      : _service = service ?? AdminService();

  // Users
  Future<PaginatedUsers> getUsers({
    String? role,
    bool? isActive,
    String? search,
    int page = 1,
  }) {
    return _service.getUsers(
      role: role,
      isActive: isActive,
      search: search,
      page: page,
    );
  }

  Future<UserModel> createUser({
    required String name,
    required String alamat,
    required String phone,
    required String email,
    required String password,
    required String role,
    bool isActive = true,
  }) {
    return _service.createUser(
      name: name,
      alamat: alamat,
      phone: phone,
      email: email,
      password: password,
      role: role,
      isActive: isActive,
    );
  }

  Future<UserModel> updateUser({
    required int id,
    String? name,
    String? alamat,
    String? phone,
    String? email,
    String? password,
    String? role,
    bool? isActive,
  }) {
    return _service.updateUser(
      id: id,
      name: name,
      alamat: alamat,
      phone: phone,
      email: email,
      password: password,
      role: role,
      isActive: isActive,
    );
  }

  Future<void> deleteUser(int id) => _service.deleteUser(id);

  // Master Jenis Perizinan
  Future<List<JenisPerizinanModel>> getMasterJenisPerizinan() =>
      _service.getMasterJenisPerizinan();

  Future<JenisPerizinanModel> createJenisPerizinan({
    required String kode,
    required String nama,
    String? deskripsi,
    List<PersyaratanModel>? persyaratan,
    int estimasiWaktu = 14,
    int maxFileSizeMb = 5,
    String status = 'aktif',
    File? logoFile,
  }) {
    return _service.createJenisPerizinan(
      kode: kode,
      nama: nama,
      deskripsi: deskripsi,
      persyaratan: persyaratan,
      estimasiWaktu: estimasiWaktu,
      maxFileSizeMb: maxFileSizeMb,
      status: status,
      logoFile: logoFile,
    );
  }

  Future<JenisPerizinanModel> updateJenisPerizinan({
    required int id,
    String? kode,
    String? nama,
    String? deskripsi,
    List<PersyaratanModel>? persyaratan,
    int? estimasiWaktu,
    int? maxFileSizeMb,
    String? status,
    File? logoFile,
  }) {
    return _service.updateJenisPerizinan(
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
  }

  Future<void> deleteJenisPerizinan(int id) => _service.deleteJenisPerizinan(id);

  // Monitoring
  Future<PaginatedPermohonan> getMonitoring({
    String? status,
    int? jenisPerizinanId,
    String? startDate,
    String? endDate,
    String? search,
    int page = 1,
  }) {
    return _service.getMonitoring(
      status: status,
      jenisPerizinanId: jenisPerizinanId,
      startDate: startDate,
      endDate: endDate,
      search: search,
      page: page,
    );
  }

  Future<void> deleteMonitoring(int id) {
    return _service.deleteMonitoring(id);
  }

  Future<PermohonanModel> getMonitoringDetail(int id) {
    return _service.getMonitoringDetail(id);
  }
}
