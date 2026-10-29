import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/utils/api_exception.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  final Dio _dio;

  DashboardService() : _dio = DioClient.instance;

  Future<DashboardPemohonModel> getPemohonDashboard() async {
    try {
      final response = await _dio.get('/api/dashboard/pemohon');
      final data = response.data['data'] as Map<String, dynamic>;
      return DashboardPemohonModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Memuat Dashboard Pemohon');
    }
  }

  Future<DashboardOperatorModel> getOperatorDashboard() async {
    try {
      final response = await _dio.get('/api/dashboard/operator');
      final data = response.data['data'] as Map<String, dynamic>;
      return DashboardOperatorModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Memuat Dashboard Operator');
    }
  }

  Future<DashboardPetugasModel> getPetugasDashboard() async {
    try {
      final response = await _dio.get('/api/dashboard/petugas');
      final data = response.data['data'] as Map<String, dynamic>;
      return DashboardPetugasModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Memuat Dashboard Petugas');
    }
  }

  Future<DashboardVerifikatorModel> getVerifikatorDashboard() async {
    try {
      final response = await _dio.get('/api/dashboard/verifikator');
      final data = response.data['data'] as Map<String, dynamic>;
      return DashboardVerifikatorModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Memuat Dashboard Verifikator');
    }
  }

  Future<DashboardAdminModel> getAdminDashboard() async {
    try {
      final response = await _dio.get('/api/dashboard/admin');
      final data = response.data['data'] as Map<String, dynamic>;
      return DashboardAdminModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Memuat Dashboard Admin');
    }
  }
}
