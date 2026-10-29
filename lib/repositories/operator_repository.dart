import '../models/permohonan_model.dart';
import '../services/operator_service.dart';
import '../services/permohonan_service.dart';

class OperatorRepository {
  final OperatorService _service;

  OperatorRepository({OperatorService? service})
      : _service = service ?? OperatorService();

  Future<PaginatedPermohonan> getPermohonan({
    String? status,
    String? search,
    int page = 1,
  }) {
    return _service.getPermohonan(status: status, search: search, page: page);
  }

  Future<PermohonanModel> getDetail(int id) => _service.getDetail(id);

  Future<PermohonanModel> periksaAdministrasi({
    required int id,
    required String status,
    String? catatanOperator,
    List<Map<String, dynamic>>? verifikasiDokumen,
  }) {
    return _service.periksaAdministrasi(
      id: id,
      status: status,
      catatanOperator: catatanOperator,
      verifikasiDokumen: verifikasiDokumen,
    );
  }

  Future<PermohonanModel> teruskan({
    required int id,
    String? catatan,
  }) {
    return _service.teruskan(id: id, catatan: catatan);
  }
}
