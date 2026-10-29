import 'package:flutter/foundation.dart';
import '../core/utils/api_exception.dart';
import '../models/profil_dinas_model.dart';
import '../repositories/profil_dinas_repository.dart';

class ProfilDinasProvider extends ChangeNotifier {
  final ProfilDinasRepository _repository;

  ProfilDinasProvider({ProfilDinasRepository? repository})
      : _repository = repository ?? ProfilDinasRepository();

  ProfilDinasModel? _profil;
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _error;

  ProfilDinasModel? get profil => _profil;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get error => _error;

  Future<void> fetchProfilDinas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profil = await _repository.getProfilDinas();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Gagal Memuat Profil Dinas';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfilDinas({
    required String namaDinas,
    required String subNama,
    required String visi,
    required List<String> misi,
    required String alamat,
    required String telepon,
    required String email,
    String? fotoPath,
  }) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profil = await _repository.updateProfilDinas(
        namaDinas: namaDinas,
        subNama: subNama,
        visi: visi,
        misi: misi,
        alamat: alamat,
        telepon: telepon,
        email: email,
        fotoPath: fotoPath,
      );
      _isActionLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Gagal Mengedit Profil Dinas';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }
}
