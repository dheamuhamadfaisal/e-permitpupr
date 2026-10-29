import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/utils/api_exception.dart';
import '../models/permohonan_model.dart';
import 'permohonan_service.dart';

class PetugasService {
  final Dio _dio;

  PetugasService() : _dio = DioClient.instance;

  /// GET /api/petugas/permohonan
  Future<PaginatedPermohonan> getPermohonan({
    String? status,
    String? jenis,
    String? search,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (jenis != null && jenis.isNotEmpty) queryParams['jenis'] = jenis;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get('/api/petugas/permohonan', queryParameters: queryParams);
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
      throw ApiException(message: 'Gagal Mengambil Daftar Permohonan Petugas');
    }
  }

  /// GET /api/petugas/arsip
  Future<PaginatedPermohonan> getArsip({
    String? kategori,
    String? jenis,
    String? periode,
    String? search,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (kategori != null && kategori.isNotEmpty) queryParams['kategori'] = kategori;
      if (jenis != null && jenis.isNotEmpty) queryParams['jenis'] = jenis;
      if (periode != null && periode.isNotEmpty) queryParams['periode'] = periode;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get('/api/petugas/arsip', queryParameters: queryParams);
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
      throw ApiException(message: 'Gagal Mengambil Arsip Petugas');
    }
  }

  /// GET /api/petugas/permohonan/{id}
  Future<PermohonanModel> getDetail(int id) async {
    try {
      final response = await _dio.get('/api/petugas/permohonan/$id');
      final data = response.data['data']['permohonan'] as Map<String, dynamic>;
      return PermohonanModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Mengambil Detail Permohonan Petugas');
    }
  }

  /// POST /api/petugas/permohonan/{id}/validasi-kelengkapan
  Future<PermohonanModel> validasiKelengkapan({
    required int id,
    required String keputusan, // 'acc' or 'tolak'
    bool? butuhKunjungan,
    String? catatan,
    dynamic fieldBermasalah,
    String? jenisPenolakan,
  }) async {
    try {
      final body = <String, dynamic>{
        'keputusan': keputusan,
        if (butuhKunjungan != null) 'butuh_kunjungan': butuhKunjungan,
        if (catatan != null) 'catatan': catatan,
        if (fieldBermasalah != null) 'field_bermasalah': fieldBermasalah,
        if (jenisPenolakan != null) 'jenis_penolakan': jenisPenolakan,
      };

      final response = await _dio.post('/api/petugas/permohonan/$id/validasi-kelengkapan', data: body);
      final data = response.data['data']['permohonan'] as Map<String, dynamic>;
      return PermohonanModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Memproses Validasi Kelengkapan');
    }
  }

  /// POST /api/petugas/permohonan/{id}/kunjungan-lapangan
  Future<PermohonanModel> kunjunganLapangan({
    required int id,
    required String hasilSurvey,
    String? filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'hasil_survey': hasilSurvey,
      });

      if (filePath != null) {
        formData.files.add(
          MapEntry(
            'file_survey',
            await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
          ),
        );
      }

      final response = await _dio.post(
        '/api/petugas/permohonan/$id/kunjungan-lapangan',
        data: formData,
      );
      final data = response.data['data']['permohonan'] as Map<String, dynamic>;
      return PermohonanModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Menyimpan Hasil Kunjungan Lapangan');
    }
  }

  /// POST /api/petugas/permohonan/{id}/analisis
  Future<PermohonanModel> analisis({
    required int id,
    required String keputusan, // 'acc' or 'tolak'
    String? catatan,
    dynamic fieldBermasalah,
    String? jenisPenolakan,
  }) async {
    try {
      final body = <String, dynamic>{
        'keputusan': keputusan,
        if (catatan != null) 'catatan': catatan,
        if (fieldBermasalah != null) 'field_bermasalah': fieldBermasalah,
        if (jenisPenolakan != null) 'jenis_penolakan': jenisPenolakan,
      };

      final response = await _dio.post('/api/petugas/permohonan/$id/analisis', data: body);
      final data = response.data['data']['permohonan'] as Map<String, dynamic>;
      return PermohonanModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Memproses Analisis');
    }
  }

  /// POST /api/petugas/permohonan/{id}/terbit
  Future<PermohonanModel> terbit({
    required int id,
    required String filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file_surat': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post('/api/petugas/permohonan/$id/terbit', data: formData);
      final data = response.data['data']['permohonan'] as Map<String, dynamic>;
      return PermohonanModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Menerbitkan Surat Perizinan');
    }
  }
}
