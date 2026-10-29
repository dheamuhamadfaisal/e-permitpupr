import 'package:flutter/foundation.dart';
import '../core/utils/api_exception.dart';
import '../models/dashboard_model.dart';
import '../repositories/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _repository;

  DashboardProvider({DashboardRepository? repository})
      : _repository = repository ?? DashboardRepository();

  bool _isLoading = false;
  String? _error;

  DashboardPemohonModel? _pemohonDashboard;
  DashboardOperatorModel? _operatorDashboard;
  DashboardPetugasModel? _petugasDashboard;
  DashboardVerifikatorModel? _verifikatorDashboard;
  DashboardAdminModel? _adminDashboard;

  bool get isLoading => _isLoading;
  String? get error => _error;

  DashboardPemohonModel? get pemohonDashboard => _pemohonDashboard;
  DashboardOperatorModel? get operatorDashboard => _operatorDashboard;
  DashboardPetugasModel? get petugasDashboard => _petugasDashboard;
  DashboardVerifikatorModel? get verifikatorDashboard => _verifikatorDashboard;
  DashboardAdminModel? get adminDashboard => _adminDashboard;

  Future<void> fetchDashboardForRole(String roleSlug) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      switch (roleSlug) {
        case 'pemohon':
          _pemohonDashboard = await _repository.getPemohonDashboard();
          break;
        case 'operator':
          _operatorDashboard = await _repository.getOperatorDashboard();
          break;
        case 'petugas':
          _petugasDashboard = await _repository.getPetugasDashboard();
          break;
        case 'verifikator':
          _verifikatorDashboard = await _repository.getVerifikatorDashboard();
          break;
        case 'admin':
          _adminDashboard = await _repository.getAdminDashboard();
          break;
        default:
          _error = 'Role Tidak Dikenali: $roleSlug';
      }
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Gagal Memuat Dashboard.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
