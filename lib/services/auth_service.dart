import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../core/utils/api_exception.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio;

  AuthService() : _dio = DioClient.instance;

  Future<AuthResponse> register({
    required String name,
    required String alamat,
    required String phone,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'alamat': alamat,
          'phone': phone,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      return _parseAuthResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      return _parseAuthResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<AuthResponse> googleLogin({
    required String email,
    required String name,
    required String googleId,
    String? avatar,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.googleLogin,
        data: {
          'email': email,
          'name': name,
          'google_id': googleId,
          if (avatar != null) 'avatar': avatar,
        },
      );
      return _parseAuthResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<UserModel> me() async {
    try {
      final response = await _dio.get(ApiConstants.me);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final userData = data['data']['user'] as Map<String, dynamic>;
        return UserModel.fromJson(userData);
      }

      throw ApiException(
        message: 'Gagal Mengambil Data User.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        final apiError = e.error as ApiException;
        if (!apiError.isUnauthorized) {
          throw _handleDioError(e);
        }
      }
    }
  }

  Future<UserModel> uploadAvatar(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dio.post('/api/profile/avatar', data: formData);
      final userData = response.data['data']['user'] as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AuthResponse _parseAuthResponse(Response response) {
    final statusCode = response.statusCode;
    final data = response.data as Map<String, dynamic>;

    if (statusCode == 200 || statusCode == 201) {
      final responseData = data['data'] as Map<String, dynamic>;
      final user = UserModel.fromJson(
        responseData['user'] as Map<String, dynamic>,
      );
      final token = responseData['token'] as String;

      return AuthResponse(user: user, token: token);
    }

    throw ApiException(
      message: data['message'] as String? ?? 'Terjadi Kesalahan.',
      statusCode: statusCode,
    );
  }

  ApiException _handleDioError(DioException e) {
    if (e.error is ApiException) return e.error as ApiException;
    return ApiException(
      message: e.message ?? 'Terjadi Kesalahan.',
      statusCode: e.response?.statusCode,
    );
  }
}

class AuthResponse {
  final UserModel user;
  final String token;

  const AuthResponse({
    required this.user,
    required this.token,
  });
}
