import '../models/permohonan_model.dart';
import '../services/permohonan_service.dart';
import '../services/verifikator_service.dart';

class VerifikatorRepository {
  final VerifikatorService _service;

  VerifikatorRepository({VerifikatorService? service})
      : _service = service ?? VerifikatorService();

  Future<PaginatedPermohonan> getPermohonan({
    String? status,
    String? search,
    int page = 1,
  }) {
    return _service.getPermohonan(status: status, search: search, page: page);
  }

  Future<PermohonanModel> getDetail(int id) => _service.getDetail(id);

  Future<PermohonanModel> setujui({
    required int id,
    String? catatan,
  }) {
    return _service.setujui(id: id, catatan: catatan);
  }

  Future<PermohonanModel> tolak({
    required int id,
    required String catatan,
  }) {
    return _service.tolak(id: id, catatan: catatan);
  }

  Future<PermohonanModel> revisi({
    required int id,
    required String catatan,
  }) {
    return _service.revisi(id: id, catatan: catatan);
  }
}
