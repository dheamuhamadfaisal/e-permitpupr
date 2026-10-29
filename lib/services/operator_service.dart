import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/utils/api_exception.dart';
import '../models/permohonan_model.dart';
import 'permohonan_service.dart';

class OperatorService {
  final Dio _dio;

  OperatorService() : _dio = DioClient.instance;

  /// GET /api/operator/permohonan
  Future<PaginatedPermohonan> getPermohonan({
    String? status,
    String? search,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get('/api/operator/permohonan', queryParameters: queryParams);
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
      throw ApiException(message: 'Gagal Mengambil Daftar Permohonan Operator');
    }
  }

  /// GET /api/operator/permohonan/{id}
  Future<PermohonanModel> getDetail(int id) async {
    try {
      final response = await _dio.get('/api/operator/permohonan/$id');
      final data = response.data['data']['permohonan'] as Map<String, dynamic>;
      return PermohonanModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Mengambil Detail Permohonan Operator');
    }
  }

  /// POST /api/operator/permohonan/{id}/periksa-administrasi
  Future<PermohonanModel> periksaAdministrasi({
    required int id,
    required String status, // lengkap / tidak_lengkap
    String? catatanOperator,
    List<Map<String, dynamic>>? verifikasiDokumen,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'status': status,
      };
      if (catatanOperator != null && catatanOperator.isNotEmpty) {
        body['catatan_operator'] = catatanOperator;
      }
      if (verifikasiDokumen != null && verifikasiDokumen.isNotEmpty) {
        body['verifikasi_dokumen'] = verifikasiDokumen;
      }

      final response = await _dio.post('/api/operator/permohonan/$id/periksa-administrasi', data: body);
      final data = response.data['data']['permohonan'] as Map<String, dynamic>;
      return PermohonanModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Menyimpan Pemeriksaan Administrasi');
    }
  }

  /// POST /api/operator/permohonan/{id}/teruskan
  Future<PermohonanModel> teruskan({
    required int id,
    String? catatan,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (catatan != null && catatan.isNotEmpty) body['catatan'] = catatan;

      final response = await _dio.post('/api/operator/permohonan/$id/teruskan', data: body);
      final data = response.data['data']['permohonan'] as Map<String, dynamic>;
      return PermohonanModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Meneruskan Permohonan ke Petugas');
    }
  }
}
