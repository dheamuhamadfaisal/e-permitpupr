import 'dart:io';
import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/utils/api_exception.dart';
import '../models/jenis_perizinan_model.dart';
import '../models/permohonan_model.dart';
import '../models/user_model.dart';
import 'permohonan_service.dart';

class PaginatedUsers {
  final List<UserModel> items;
  final int currentPage;
  final int lastPage;
  final int total;

  const PaginatedUsers({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
}

class AdminService {
  final Dio _dio;

  AdminService() : _dio = DioClient.instance;

  // ---------------------------------------------------------------------------
  // User Management Endpoints
  // ---------------------------------------------------------------------------

  /// GET /api/admin/users
  Future<PaginatedUsers> getUsers({
    String? role,
    bool? isActive,
    String? search,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (role != null && role.isNotEmpty) queryParams['role'] = role;
      if (isActive != null) queryParams['is_active'] = isActive;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get('/api/admin/users', queryParameters: queryParams);
      final data = response.data['data'] as Map<String, dynamic>;
      final list = data['data'] as List;

      final items = list
          .whereType<Map<String, dynamic>>()
          .map((u) => UserModel.fromJson(u))
          .toList();

      return PaginatedUsers(
        items: items,
        currentPage: data['current_page'] as int? ?? 1,
        lastPage: data['last_page'] as int? ?? 1,
        total: data['total'] as int? ?? 0,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Mengambil Daftar Pengguna Admin');
    }
  }

  /// POST /api/admin/users
  Future<UserModel> createUser({
    required String name,
    required String alamat,
    required String phone,
    required String email,
    required String password,
    required String role,
    bool isActive = true,
  }) async {
    try {
      final response = await _dio.post('/api/admin/users', data: {
        'name': name,
        'alamat': alamat,
        'phone': phone,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'role': role,
        'is_active': isActive,
      });

      final data = response.data['data']['user'] as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Membuat Pengguna Baru');
    }
  }

  /// PUT /api/admin/users/{id}
  Future<UserModel> updateUser({
    required int id,
    String? name,
    String? alamat,
    String? phone,
    String? email,
    String? password,
    String? role,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (alamat != null) body['alamat'] = alamat;
      if (phone != null) body['phone'] = phone;
      if (email != null) body['email'] = email;
      if (password != null && password.isNotEmpty) {
        body['password'] = password;
        body['password_confirmation'] = password;
      }
      if (role != null) body['role'] = role;
      if (isActive != null) body['is_active'] = isActive;

      final response = await _dio.put('/api/admin/users/$id', data: body);
      final data = response.data['data']['user'] as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Memperbarui Pengguna');
    }
  }

  /// DELETE /api/admin/users/{id}
  Future<void> deleteUser(int id) async {
    try {
      await _dio.delete('/api/admin/users/$id');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Menghapus Pengguna');
    }
  }

  // ---------------------------------------------------------------------------
  // Master Jenis Perizinan Endpoints
  // ---------------------------------------------------------------------------

  /// GET /api/admin/jenis-perizinan
  Future<List<JenisPerizinanModel>> getMasterJenisPerizinan() async {
    try {
      final response = await _dio.get('/api/admin/jenis-perizinan');
      final data = response.data['data']['data'] as List;
      return data
          .whereType<Map<String, dynamic>>()
          .map((j) => JenisPerizinanModel.fromJson(j))
          .toList();
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Mengambil Master Jenis Perizinan');
    }
  }

  /// POST /api/admin/jenis-perizinan
  Future<JenisPerizinanModel> createJenisPerizinan({
    required String kode,
    required String nama,
    String? deskripsi,
    List<PersyaratanModel>? persyaratan,
    int estimasiWaktu = 14,
    int maxFileSizeMb = 5,
    String status = 'aktif',
    File? logoFile,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'kode': kode,
        'nama': nama,
        'estimasi_waktu': estimasiWaktu,
        'max_file_size_mb': maxFileSizeMb,
        'status': status,
      };

      if (deskripsi != null) body['deskripsi'] = deskripsi;
      if (persyaratan != null) {
        for (int i = 0; i < persyaratan.length; i++) {
          body['persyaratan[$i][nama]'] = persyaratan[i].nama;
          body['persyaratan[$i][is_opsional]'] = persyaratan[i].isOpsional ? 1 : 0;
          body['persyaratan[$i][max_size_mb]'] = persyaratan[i].maxSizeMb;
          if (persyaratan[i].linkUrl != null) {
            body['persyaratan[$i][link_url]'] = persyaratan[i].linkUrl;
          }
          if (persyaratan[i].allowedTypes != null) {
            body['persyaratan[$i][allowed_types]'] = persyaratan[i].allowedTypes;
          }
          body['persyaratan[$i][allow_link]'] = persyaratan[i].allowLink ? 1 : 0;
        }
      }

      if (logoFile != null) {
        body['logo'] = await MultipartFile.fromFile(logoFile.path);
      }

      final formData = FormData.fromMap(body);
      final response = await _dio.post('/api/admin/jenis-perizinan', data: formData);
      final data = response.data['data']['jenis_perizinan'] as Map<String, dynamic>;
      return JenisPerizinanModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Membuat Jenis Perizinan');
    }
  }

  /// PUT /api/admin/jenis-perizinan/{id}
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
  }) async {
    try {
      final Map<String, dynamic> body = {};
      
      // Karena kita bisa saja mengirim file, lebih aman menggunakan POST dengan _method=PUT
      body['_method'] = 'PUT';
      
      if (kode != null) body['kode'] = kode;
      if (nama != null) body['nama'] = nama;
      if (deskripsi != null) body['deskripsi'] = deskripsi;
      
      if (persyaratan != null) {
        for (int i = 0; i < persyaratan.length; i++) {
          body['persyaratan[$i][nama]'] = persyaratan[i].nama;
          body['persyaratan[$i][is_opsional]'] = persyaratan[i].isOpsional ? 1 : 0;
          body['persyaratan[$i][max_size_mb]'] = persyaratan[i].maxSizeMb;
          if (persyaratan[i].linkUrl != null) {
            body['persyaratan[$i][link_url]'] = persyaratan[i].linkUrl;
          }
          if (persyaratan[i].allowedTypes != null) {
            body['persyaratan[$i][allowed_types]'] = persyaratan[i].allowedTypes;
          }
          body['persyaratan[$i][allow_link]'] = persyaratan[i].allowLink ? 1 : 0;
        }
      }
      
      if (estimasiWaktu != null) body['estimasi_waktu'] = estimasiWaktu;
      if (maxFileSizeMb != null) body['max_file_size_mb'] = maxFileSizeMb;
      if (status != null) body['status'] = status;

      if (logoFile != null) {
        body['logo'] = await MultipartFile.fromFile(logoFile.path);
      }

      final formData = FormData.fromMap(body);
      final response = await _dio.post('/api/admin/jenis-perizinan/$id', data: formData);
      final data = response.data['data']['jenis_perizinan'] as Map<String, dynamic>;
      return JenisPerizinanModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Mengupdate Jenis Perizinan');
    }
  }

  /// DELETE /api/admin/jenis-perizinan/{id}
  Future<void> deleteJenisPerizinan(int id) async {
    try {
      await _dio.delete('/api/admin/jenis-perizinan/$id');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Menghapus Jenis Perizinan');
    }
  }

  // ---------------------------------------------------------------------------
  // Monitoring Endpoints
  // ---------------------------------------------------------------------------

  /// GET /api/admin/monitoring
  Future<PaginatedPermohonan> getMonitoring({
    String? status,
    int? jenisPerizinanId,
    String? startDate,
    String? endDate,
    String? search,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (jenisPerizinanId != null) queryParams['jenis_perizinan_id'] = jenisPerizinanId;
      if (startDate != null && startDate.isNotEmpty) queryParams['start_date'] = startDate;
      if (endDate != null && endDate.isNotEmpty) queryParams['end_date'] = endDate;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get('/api/admin/monitoring', queryParameters: queryParams);
      final data = response.data['data'] as Map<String, dynamic>;
      final list = data['data'] as List;

      final items = list
          .whereType<Map<String, dynamic>>()
          .map((p) => PermohonanModel.fromJson(p))
          .toList();

      return PaginatedPermohonan(
        items: items,
        currentPage: data['current_page'] as int? ?? 1,
        lastPage: data['last_page'] as int? ?? 1,
        total: data['total'] as int? ?? 0,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Mengambil Data Monitoring Admin');
    }
  }

  /// DELETE /api/admin/monitoring/{id}
  Future<void> deleteMonitoring(int id) async {
    try {
      await _dio.delete('/api/admin/monitoring/$id');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Menghapus Permohonan');
    }
  }

  /// GET /api/admin/monitoring/{id}
  Future<PermohonanModel> getMonitoringDetail(int id) async {
    try {
      final response = await _dio.get('/api/admin/monitoring/$id');
      return PermohonanModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Mengambil Detail Monitoring');
    }
  }
}
