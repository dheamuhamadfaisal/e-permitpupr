import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/utils/api_exception.dart';
import '../models/permohonan_model.dart';
import 'permohonan_service.dart';

class VerifikatorService {
  final Dio _dio;

  VerifikatorService() : _dio = DioClient.instance;

  /// GET /api/verifikator/permohonan
  Future<PaginatedPermohonan> getPermohonan({
    String? status,
    String? search,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get('/api/verifikator/permohonan', queryParameters: queryParams);
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
      throw ApiException(message: 'Gagal Mengambil Daftar Permohonan Verifikator');
    }
  }

  /// GET /api/verifikator/permohonan/{id}
  Future<PermohonanModel> getDetail(int id) async {
    try {
      final response = await _dio.get('/api/verifikator/permohonan/$id');
      final data = response.data['data']['permohonan'] as Map<String, dynamic>;
      return PermohonanModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Mengambil Detail Permohonan Verifikator');
    }
  }

  /// POST /api/verifikator/permohonan/{id}/setujui
  Future<PermohonanModel> setujui({
    required int id,
    String? catatan,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (catatan != null && catatan.isNotEmpty) body['catatan'] = catatan;

      final response = await _dio.post('/api/verifikator/permohonan/$id/setujui', data: body);
      final data = response.data['data']['permohonan'] as Map<String, dynamic>;
      return PermohonanModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Menyetujui Permohonan');
    }
  }

  /// POST /api/verifikator/permohonan/{id}/tolak
  Future<PermohonanModel> tolak({
    required int id,
    required String catatan,
  }) async {
    try {
      final response = await _dio.post(
        '/api/verifikator/permohonan/$id/tolak',
        data: {'catatan': catatan},
      );
      final data = response.data['data']['permohonan'] as Map<String, dynamic>;
      return PermohonanModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Menolak Permohonan');
    }
  }

  /// POST /api/verifikator/permohonan/{id}/revisi
  Future<PermohonanModel> revisi({
    required int id,
    required String catatan,
  }) async {
    try {
      final response = await _dio.post(
        '/api/verifikator/permohonan/$id/revisi',
        data: {'catatan': catatan},
      );
      final data = response.data['data']['permohonan'] as Map<String, dynamic>;
      return PermohonanModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Mengembalikan Permohonan untuk Revisi');
    }
  }
}
