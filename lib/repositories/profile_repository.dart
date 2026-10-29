import '../models/user_model.dart';
import '../services/profile_service.dart';

class ProfileRepository {
  final ProfileService _service;

  ProfileRepository({ProfileService? service})
      : _service = service ?? ProfileService();

  Future<UserModel> getProfile() => _service.getProfile();

  Future<UserModel> updateProfile({
    String? name,
    String? alamat,
    String? phone,
    String? email,
  }) {
    return _service.updateProfile(
      name: name,
      alamat: alamat,
      phone: phone,
      email: email,
    );
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) {
    return _service.updatePassword(
      currentPassword: currentPassword,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}
