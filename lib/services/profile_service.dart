import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/utils/api_exception.dart';
import '../models/user_model.dart';

class ProfileService {
  final Dio _dio;

  ProfileService() : _dio = DioClient.instance;

  /// GET /api/profile
  Future<UserModel> getProfile() async {
    try {
      final response = await _dio.get('/api/profile');
      final data = response.data['data']['user'] as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal memuat profil');
    }
  }

  /// PUT /api/profile
  Future<UserModel> updateProfile({
    String? name,
    String? alamat,
    String? phone,
    String? email,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (alamat != null) body['alamat'] = alamat;
      if (phone != null) body['phone'] = phone;
      if (email != null) body['email'] = email;

      final response = await _dio.put('/api/profile', data: body);
      final data = response.data['data']['user'] as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Mengupdate Profil');
    }
  }

  /// PUT /api/profile/password
  Future<void> updatePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _dio.put('/api/profile/password', data: {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Mengubah Password');
    }
  }
}
