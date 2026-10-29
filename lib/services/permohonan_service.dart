import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/utils/api_exception.dart';
import '../models/permohonan_model.dart';

class PaginatedPermohonan {
  final List<PermohonanModel> items;
  final int currentPage;
  final int lastPage;
  final int total;

  const PaginatedPermohonan({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
}

class PermohonanService {
  final Dio _dio;

  PermohonanService() : _dio = DioClient.instance;

  /// GET /api/permohonan
  Future<PaginatedPermohonan> getPermohonan({
    String? status,
    String? search,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get('/api/permohonan', queryParameters: queryParams);
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
      throw ApiException(message: 'Gagal Mengambil Daftar Permohonan');
    }
  }

  /// GET /api/permohonan/{id}
  Future<PermohonanModel> getPermohonanDetail(int id) async {
    try {
      final response = await _dio.get('/api/permohonan/$id');
      final data = response.data['data']['permohonan'] as Map<String, dynamic>;
      return PermohonanModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Mengambil Detail Permohonan');
    }
  }

  /// GET /api/permohonan/my-krk-terbit
  Future<List<PermohonanModel>> getMyKrkTerbitList() async {
    try {
      final response = await _dio.get('/api/permohonan/my-krk-terbit');
      final list = response.data['data']['krk_list'] as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map((p) => PermohonanModel.fromJson(p))
          .toList();
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Mengambil Daftar KRK Terbit');
    }
  }

  Future<PermohonanModel> createPermohonan({
    required int jenisPerizinanId,
    int? krkTerkaitId,
    String? namaPerusahaan,
    String? namaDirektur,
    String? noHpPenanggungJawab,
    String? rencanaKegiatan,
    String? alamatLengkap,
    String? luasArea,
    required String keterangan,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'jenis_perizinan_id': jenisPerizinanId,
        'keterangan': keterangan,
      };
      if (krkTerkaitId != null) body['krk_terkait_id'] = krkTerkaitId;
      if (namaPerusahaan != null) body['nama_perusahaan'] = namaPerusahaan;
      if (namaDirektur != null) body['nama_direktur'] = namaDirektur;
      if (noHpPenanggungJawab != null) body['no_hp_penanggung_jawab'] = noHpPenanggungJawab;
      if (rencanaKegiatan != null) body['rencana_kegiatan'] = rencanaKegiatan;
      if (alamatLengkap != null) body['alamat_lengkap'] = alamatLengkap;
      if (luasArea != null) body['luas_area'] = luasArea;

      final response = await _dio.post('/api/permohonan', data: body);
      final data = response.data['data']['permohonan'] as Map<String, dynamic>;
      return PermohonanModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Membuat Permohonan');
    }
  }

  Future<PermohonanModel> updatePermohonan({
    required int id,
    int? jenisPerizinanId,
    int? krkTerkaitId,
    String? namaPerusahaan,
    String? namaDirektur,
    String? noHpPenanggungJawab,
    String? rencanaKegiatan,
    String? alamatLengkap,
    String? luasArea,
    String? keterangan,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (jenisPerizinanId != null) body['jenis_perizinan_id'] = jenisPerizinanId;
      if (krkTerkaitId != null) body['krk_terkait_id'] = krkTerkaitId;
      if (namaPerusahaan != null) body['nama_perusahaan'] = namaPerusahaan;
      if (namaDirektur != null) body['nama_direktur'] = namaDirektur;
      if (noHpPenanggungJawab != null) body['no_hp_penanggung_jawab'] = noHpPenanggungJawab;
      if (rencanaKegiatan != null) body['rencana_kegiatan'] = rencanaKegiatan;
      if (alamatLengkap != null) body['alamat_lengkap'] = alamatLengkap;
      if (luasArea != null) body['luas_area'] = luasArea;
      if (keterangan != null) body['keterangan'] = keterangan;

      final response = await _dio.put('/api/permohonan/$id', data: body);
      final data = response.data['data']['permohonan'] as Map<String, dynamic>;
      return PermohonanModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Memperbarui Permohonan');
    }
  }

  /// POST /api/permohonan/{id}/ajukan
  Future<PermohonanModel> ajukanPermohonan(int id) async {
    try {
      final response = await _dio.post('/api/permohonan/$id/ajukan');
      final data = response.data['data']['permohonan'] as Map<String, dynamic>;
      return PermohonanModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: 'Gagal Mengajukan Permohonan');
    }
  }
}
