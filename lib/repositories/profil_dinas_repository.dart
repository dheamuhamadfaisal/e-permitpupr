import '../models/profil_dinas_model.dart';
import '../services/profil_dinas_service.dart';

class ProfilDinasRepository {
  final ProfilDinasService _service;

  ProfilDinasRepository({ProfilDinasService? service})
      : _service = service ?? ProfilDinasService();

  Future<ProfilDinasModel> getProfilDinas() => _service.getProfilDinas();

  Future<ProfilDinasModel> updateProfilDinas({
    required String namaDinas,
    required String subNama,
    required String visi,
    required List<String> misi,
    required String alamat,
    required String telepon,
    required String email,
    String? fotoPath,
  }) {
    return _service.updateProfilDinas(
      namaDinas: namaDinas,
      subNama: subNama,
      visi: visi,
      misi: misi,
      alamat: alamat,
      telepon: telepon,
      email: email,
      fotoPath: fotoPath,
    );
  }
}
