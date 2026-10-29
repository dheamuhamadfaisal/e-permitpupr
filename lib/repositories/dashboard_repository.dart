import '../models/dashboard_model.dart';
import '../services/dashboard_service.dart';

class DashboardRepository {
  final DashboardService _service;

  DashboardRepository({DashboardService? service})
      : _service = service ?? DashboardService();

  Future<DashboardPemohonModel> getPemohonDashboard() => _service.getPemohonDashboard();
  Future<DashboardOperatorModel> getOperatorDashboard() => _service.getOperatorDashboard();
  Future<DashboardPetugasModel> getPetugasDashboard() => _service.getPetugasDashboard();
  Future<DashboardVerifikatorModel> getVerifikatorDashboard() => _service.getVerifikatorDashboard();
  Future<DashboardAdminModel> getAdminDashboard() => _service.getAdminDashboard();
}
