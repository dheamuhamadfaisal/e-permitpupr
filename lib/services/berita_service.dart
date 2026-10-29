import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/utils/api_exception.dart';
import '../models/berita_model.dart';

class PaginatedBerita {
  final List<BeritaModel> items;
  final int currentPage;
  final int lastPage;
  final int total;

  const PaginatedBerita({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
}

class BeritaService {
  final Dio _dio;

  BeritaService() : _dio = DioClient.instance;

  /// GET /api/berita
  Future<PaginatedBerita> getBerita({
    String? kategori,
    String? search,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      if (kategori != null && kategori.isNotEmpty) queryParams['kategori'] = kategori;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get('/api/berita', queryParameters: queryParams);
      final data = response.data['data'] as Map<String, dynamic>;
      final list = data['data'] as List;

      final items = list
          .whereType<Map<String, dynamic>>()
          .map((b) => BeritaModel.fromJson(b))
          .toList();

      return PaginatedBerita(
        items: items,
        currentPage: data['current_page'] as int? ?? 1,
        lastPage: data['last_page'] as int? ?? 1,
        total: data['total'] as int? ?? 0,
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Mengambil Berita & Informasi');
    }
  }

  /// POST /api/operator/berita
  Future<BeritaModel> createBerita({
    required String judul,
    String? ringkasan,
    required String konten,
    required String kategori,
    String? imagePath,
    String? linkUrl,
  }) async {
    try {
      final Map<String, dynamic> map = {
        'judul': judul,
        if (ringkasan != null && ringkasan.isNotEmpty) 'ringkasan': ringkasan,
        'konten': konten,
        'kategori': kategori,
      };

      if (linkUrl != null && linkUrl.isNotEmpty) {
        map['link_url'] = linkUrl;
      }

      if (imagePath != null && imagePath.isNotEmpty) {
        map['gambar'] = await MultipartFile.fromFile(imagePath);
      }

      final formData = FormData.fromMap(map);
      final response = await _dio.post('/api/operator/berita', data: formData);
      final data = response.data['data']['berita'] as Map<String, dynamic>;
      return BeritaModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Menerbitkan Berita');
    }
  }

  /// POST /api/operator/berita/{id} (Update)
  Future<BeritaModel> updateBerita(
    int id, {
    String? judul,
    String? ringkasan,
    String? konten,
    String? kategori,
    String? imagePath,
    String? linkUrl,
  }) async {
    try {
      final Map<String, dynamic> map = {};
      if (judul != null) map['judul'] = judul;
      if (ringkasan != null) map['ringkasan'] = ringkasan;
      if (konten != null) map['konten'] = konten;
      if (kategori != null) map['kategori'] = kategori;
      if (linkUrl != null) map['link_url'] = linkUrl;

      if (imagePath != null && imagePath.isNotEmpty) {
        map['gambar'] = await MultipartFile.fromFile(imagePath);
      }

      final formData = FormData.fromMap(map);
      final response = await _dio.post('/api/operator/berita/$id', data: formData);
      final data = response.data['data']['berita'] as Map<String, dynamic>;
      return BeritaModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Memperbarui Berita');
    }
  }

  /// DELETE /api/operator/berita/{id}
  Future<void> deleteBerita(int id) async {
    try {
      await _dio.delete('/api/operator/berita/$id');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Menghapus Berita');
    }
  }
}
