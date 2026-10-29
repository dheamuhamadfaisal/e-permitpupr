import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/utils/api_exception.dart';
import '../models/jenis_perizinan_model.dart';

class JenisPerizinanService {
  final Dio _dio;

  JenisPerizinanService() : _dio = DioClient.instance;

  /// GET /api/jenis-perizinan - Daftar jenis perizinan aktif (KRK, SITEPLAN)
  Future<List<JenisPerizinanModel>> getJenisPerizinan({bool all = false}) async {
    try {
      final response = await _dio.get('/api/jenis-perizinan', queryParameters: {'all': all});
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final list = data['data'] as List;
        return list
            .whereType<Map<String, dynamic>>()
            .map((j) => JenisPerizinanModel.fromJson(j))
            .toList();
      }
      throw ApiException(
        message: 'Gagal Mengambil Jenis Perizinan.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(
        message: e.message ?? 'Terjadi Kesalahan.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// PUT /api/operator/layanan/{id} - Update informasi layanan publik
  Future<JenisPerizinanModel> updateLayananInfo({
    required int id,
    String? deskripsi,
    String? tentang,
    List<String>? alur,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (deskripsi != null) body['deskripsi'] = deskripsi;
      if (tentang != null) body['tentang'] = tentang;
      if (alur != null) body['alur'] = alur;

      final response = await _dio.put('/api/operator/layanan/$id', data: body);
      final data = response.data['data']['jenis_perizinan'] as Map<String, dynamic>;
      return JenisPerizinanModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(
        message: e.message ?? 'Gagal Memperbarui Informasi Layanan.',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
