import '../models/permohonan_model.dart';
import '../services/permohonan_service.dart';
import '../services/petugas_service.dart';

class PetugasRepository {
  final PetugasService _service;

  PetugasRepository({PetugasService? service})
      : _service = service ?? PetugasService();

  Future<PaginatedPermohonan> getPermohonan({
    String? status,
    String? jenis,
    String? search,
    int page = 1,
  }) {
    return _service.getPermohonan(status: status, jenis: jenis, search: search, page: page);
  }

  Future<PaginatedPermohonan> getArsip({
    String? kategori,
    String? jenis,
    String? periode,
    String? search,
    int page = 1,
  }) {
    return _service.getArsip(kategori: kategori, jenis: jenis, periode: periode, search: search, page: page);
  }

  Future<PermohonanModel> getDetail(int id) => _service.getDetail(id);

  Future<PermohonanModel> validasiKelengkapan({
    required int id,
    required String keputusan,
    bool? butuhKunjungan,
    String? catatan,
    dynamic fieldBermasalah,
    String? jenisPenolakan,
  }) {
    return _service.validasiKelengkapan(
      id: id,
      keputusan: keputusan,
      butuhKunjungan: butuhKunjungan,
      catatan: catatan,
      fieldBermasalah: fieldBermasalah,
      jenisPenolakan: jenisPenolakan,
    );
  }

  Future<PermohonanModel> kunjunganLapangan({
    required int id,
    required String hasilSurvey,
    String? filePath,
  }) async {
    return await _service.kunjunganLapangan(
      id: id,
      hasilSurvey: hasilSurvey,
      filePath: filePath,
    );
  }

  Future<PermohonanModel> analisis({
    required int id,
    required String keputusan,
    String? catatan,
    dynamic fieldBermasalah,
    String? jenisPenolakan,
  }) {
    return _service.analisis(
      id: id,
      keputusan: keputusan,
      catatan: catatan,
      fieldBermasalah: fieldBermasalah,
      jenisPenolakan: jenisPenolakan,
    );
  }

  Future<PermohonanModel> terbit({
    required int id,
    required String filePath,
  }) {
    return _service.terbit(id: id, filePath: filePath);
  }
}
