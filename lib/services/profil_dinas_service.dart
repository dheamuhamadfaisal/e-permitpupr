import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/utils/api_exception.dart';
import '../models/profil_dinas_model.dart';

class ProfilDinasService {
  final Dio _dio;

  ProfilDinasService() : _dio = DioClient.instance;

  /// GET /api/profil-dinas
  Future<ProfilDinasModel> getProfilDinas() async {
    try {
      final response = await _dio.get('/api/profil-dinas');
      final data = response.data['data']['profil'] as Map<String, dynamic>;
      return ProfilDinasModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Mengambil Profil Dinas');
    }
  }

  /// POST /api/operator/profil-dinas
  Future<ProfilDinasModel> updateProfilDinas({
    required String namaDinas,
    required String subNama,
    required String visi,
    required List<String> misi,
    required String alamat,
    required String telepon,
    required String email,
    String? fotoPath,
  }) async {
    try {
      final Map<String, dynamic> map = {
        'nama_dinas': namaDinas,
        'sub_nama': subNama,
        'visi': visi,
        'alamat': alamat,
        'telepon': telepon,
        'email': email,
      };

      for (int i = 0; i < misi.length; i++) {
        map['misi[$i]'] = misi[i];
      }

      if (fotoPath != null && fotoPath.isNotEmpty) {
        map['foto'] = await MultipartFile.fromFile(fotoPath);
      }

      final formData = FormData.fromMap(map);
      final response = await _dio.post('/api/operator/profil-dinas', data: formData);
      final data = response.data['data']['profil'] as Map<String, dynamic>;
      return ProfilDinasModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Mengedit Profil Dinas');
    }
  }
}
