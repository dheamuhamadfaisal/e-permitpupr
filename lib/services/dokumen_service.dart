import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/utils/api_exception.dart';
import '../models/permohonan_dokumen_model.dart';

class DokumenService {
  final Dio _dio;

  DokumenService() : _dio = DioClient.instance;

  /// GET /api/permohonan/{id}/dokumen
  Future<List<PermohonanDokumenModel>> getDokumen(int permohonanId) async {
    try {
      final response = await _dio.get('/api/permohonan/$permohonanId/dokumen');
      final data = response.data['data']['dokumen'] as List;
      return data
          .whereType<Map<String, dynamic>>()
          .map((d) => PermohonanDokumenModel.fromJson(d))
          .toList();
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Mengambil Dokumen');
    }
  }

  /// POST /api/permohonan/{id}/dokumen (multipart/form-data)
  Future<PermohonanDokumenModel> uploadDokumen({
    required int permohonanId,
    required String jenisDokumen,
    String? filePath,
    String? fileName,
    String? linkUrl,
    Uint8List? fileBytes,
  }) async {
    try {
      final mapData = <String, dynamic>{
        'jenis_dokumen': jenisDokumen,
      };

      if (linkUrl != null && linkUrl.isNotEmpty) {
        mapData['link_url'] = linkUrl;
      } else if (fileBytes != null && fileName != null) {
        mapData['file'] = MultipartFile.fromBytes(fileBytes, filename: fileName);
      } else if (filePath != null && fileName != null) {
        mapData['file'] = await MultipartFile.fromFile(filePath, filename: fileName);
      }

      final formData = FormData.fromMap(mapData);

      final response = await _dio.post(
        '/api/permohonan/$permohonanId/dokumen',
        data: formData,
      );

      final data = response.data['data']['dokumen'] as Map<String, dynamic>;
      return PermohonanDokumenModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Mengupload Dokumen');
    }
  }

  /// DELETE /api/permohonan/{id}/dokumen/{dokumenId}
  Future<void> deleteDokumen({
    required int permohonanId,
    required int dokumenId,
  }) async {
    try {
      await _dio.delete('/api/permohonan/$permohonanId/dokumen/$dokumenId');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Menghapus Dokumen');
    }
  }
}
