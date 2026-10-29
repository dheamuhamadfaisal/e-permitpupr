import '../models/permohonan_model.dart';
import '../services/permohonan_service.dart';

class PermohonanRepository {
  final PermohonanService _service;

  PermohonanRepository({PermohonanService? service})
      : _service = service ?? PermohonanService();

  Future<PaginatedPermohonan> getPermohonan({
    String? status,
    String? search,
    int page = 1,
  }) {
    return _service.getPermohonan(status: status, search: search, page: page);
  }

  Future<PermohonanModel> getPermohonanDetail(int id) {
    return _service.getPermohonanDetail(id);
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
  }) {
    return _service.createPermohonan(
      jenisPerizinanId: jenisPerizinanId,
      krkTerkaitId: krkTerkaitId,
      namaPerusahaan: namaPerusahaan,
      namaDirektur: namaDirektur,
      noHpPenanggungJawab: noHpPenanggungJawab,
      rencanaKegiatan: rencanaKegiatan,
      alamatLengkap: alamatLengkap,
      luasArea: luasArea,
      keterangan: keterangan,
    );
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
  }) {
    return _service.updatePermohonan(
      id: id,
      jenisPerizinanId: jenisPerizinanId,
      krkTerkaitId: krkTerkaitId,
      namaPerusahaan: namaPerusahaan,
      namaDirektur: namaDirektur,
      noHpPenanggungJawab: noHpPenanggungJawab,
      rencanaKegiatan: rencanaKegiatan,
      alamatLengkap: alamatLengkap,
      luasArea: luasArea,
      keterangan: keterangan,
    );
  }

  Future<PermohonanModel> ajukanPermohonan(int id) {
    return _service.ajukanPermohonan(id);
  }
}
