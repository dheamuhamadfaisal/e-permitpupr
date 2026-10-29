import '../models/jenis_perizinan_model.dart';
import '../services/jenis_perizinan_service.dart';

class JenisPerizinanRepository {
  final JenisPerizinanService _service;

  JenisPerizinanRepository({JenisPerizinanService? service})
      : _service = service ?? JenisPerizinanService();

  Future<List<JenisPerizinanModel>> getJenisPerizinan({bool all = false}) {
    return _service.getJenisPerizinan(all: all);
  }

  Future<JenisPerizinanModel> updateLayananInfo({
    required int id,
    String? deskripsi,
    String? tentang,
    List<String>? alur,
  }) {
    return _service.updateLayananInfo(
      id: id,
      deskripsi: deskripsi,
      tentang: tentang,
      alur: alur,
    );
  }
}
