import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/informasi_layanan_model.dart';

class InformasiLayananService {
  final Dio _dio;

  InformasiLayananService() : _dio = DioClient.instance;

  Future<List<InformasiLayananModel>> fetchInformasiLayanan() async {
    try {
      // Endpoint is open to public, but we can just use _dio
      // Usually it's /api/informasi-layanan
      final response = await _dio.get('/api/informasi-layanan');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> itemsJson = data['data'];
          return itemsJson.map((e) => InformasiLayananModel.fromJson(e)).toList();
        }
        throw Exception(data['message'] ?? 'Gagal mengambil data informasi layanan');
      }
      throw Exception('Server error: ${response.statusCode}');
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? 'Gagal menghubungi server');
      }
      throw Exception('Gagal menghubungi server: $e');
    }
  }

  Future<InformasiLayananModel> updateInformasiLayanan(
      int id, String? deskripsi, String? tentang, List<String>? alur) async {
    try {
      final body = <String, dynamic>{};
      if (deskripsi != null) body['deskripsi'] = deskripsi;
      if (tentang != null) body['tentang'] = tentang;
      if (alur != null) body['alur'] = alur;

      final response = await _dio.put(
        '/api/operator/informasi-layanan/$id',
        data: body,
      );

      final data = response.data;
      if (response.statusCode == 200 && data['success'] == true) {
        return InformasiLayananModel.fromJson(data['data']['informasi_layanan']);
      }
      throw Exception(data['message'] ?? 'Gagal memperbarui informasi layanan');
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? 'Gagal memperbarui informasi layanan');
      }
      throw Exception('Gagal memperbarui informasi layanan: $e');
    }
  }
}
