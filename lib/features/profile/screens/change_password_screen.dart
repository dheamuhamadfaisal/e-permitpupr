import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/api_exception.dart';
import '../../../features/auth/widgets/auth_text_field.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../widgets/loading_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onChangePassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final profileProvider = context.read<ProfileProvider>();
    final authProvider = context.read<AuthProvider>();

    final success = await profileProvider.updatePassword(
      currentPassword: _currentPasswordController.text,
      password: _newPasswordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Tutup keyboard agar animasi lebih smooth
      FocusManager.instance.primaryFocus?.unfocus();
      
      context.showSuccessMessage('Password Berhasil Diubah. Silakan Login Kembali.');
      
      // Beri jeda agar user membaca notif sebelum di-logout otomatis
      Future.delayed(const Duration(milliseconds: 1500), () async {
        if (mounted) await authProvider.logout();
      });
    } else if (profileProvider.error != null) {
      context.showApiError(ApiException(message: profileProvider.error!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PasswordTextField(
                controller: _currentPasswordController,
                label: 'Password Lama',
                validator: (val) => val == null || val.isEmpty ? 'Password Lama Wajib Diisi' : null,
              ),
              const SizedBox(height: 16),
              PasswordTextField(
                controller: _newPasswordController,
                label: 'Password Baru',
                hint: 'Minimal 8 Karakter',
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Password Baru Wajib Diisi';
                  if (val.length < 8) return 'Password Minimal 8 Karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              PasswordTextField(
                controller: _confirmPasswordController,
                label: 'Konfirmasi Password Baru',
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Konfirmasi Password Baru Wajib Diisi';
                  if (val != _newPasswordController.text) return 'Password Tidak Sama';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              LoadingButton(
                label: 'Simpan Password Baru',
                onPressed: _onChangePassword,
                isLoading: provider.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
