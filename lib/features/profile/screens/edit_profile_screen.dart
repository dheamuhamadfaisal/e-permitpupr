import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/api_exception.dart';
import '../../../features/auth/widgets/auth_text_field.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/loading_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _alamatController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  String _initialName = '';
  String _initialAlamat = '';
  String _initialPhone = '';
  String _initialEmail = '';

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _initialName = profile?.name ?? '';
    _initialAlamat = profile?.alamat ?? '';
    _initialPhone = profile?.phone ?? '';
    _initialEmail = profile?.email ?? '';

    _nameController = TextEditingController(text: _initialName);
    _alamatController = TextEditingController(text: _initialAlamat);
    _phoneController = TextEditingController(text: _initialPhone);
    _emailController = TextEditingController(text: _initialEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _alamatController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final provider = context.read<ProfileProvider>();

    // Hanya kirim field yang memang diubah (Partial Update)
    String? newName = _nameController.text.trim() != _initialName ? _nameController.text.trim() : null;
    String? newAlamat = _alamatController.text.trim() != _initialAlamat ? _alamatController.text.trim() : null;
    String? newPhone = _phoneController.text.trim() != _initialPhone ? _phoneController.text.trim() : null;
    String? newEmail = _emailController.text.trim() != _initialEmail ? _emailController.text.trim() : null;

    if (newName == null && newAlamat == null && newPhone == null && newEmail == null) {
      context.showSuccessMessage('Tidak Ada Perubahan Data');
      context.pop();
      return;
    }

    final success = await provider.updateProfile(
      name: newName,
      alamat: newAlamat,
      phone: newPhone,
      email: newEmail,
    );

    if (!mounted) return;

    if (success) {
      if (provider.profile != null) {
        context.read<AuthProvider>().updateUser(provider.profile!);
      }
      
      // Tutup keyboard agar animasi lebih smooth
      FocusManager.instance.primaryFocus?.unfocus();
      
      context.showSuccessMessage('Profil Berhasil Diperbarui');
      
      // Beri jeda agar user bisa melihat pesan berhasil & keyboard selesai turun
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) context.pop();
      });
    } else if (provider.error != null) {
      context.showApiError(ApiException(message: provider.error!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                controller: _nameController,
                label: 'Nama Lengkap',
                prefixIcon: Icons.person_outline,
                validator: (val) => val == null || val.isEmpty ? 'Nama Tidak Boleh Kosong' : null,
              ),
              if (provider.profile?.isPemohon == true) ...[
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _alamatController,
                  label: 'Alamat',
                  prefixIcon: Icons.home_work_outlined,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _phoneController,
                  label: 'No. Handphone',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val != null && val.isNotEmpty) {
                      if (val.length < 10) return 'Nomor HP Minimal 10 Digit';
                      if (val.length > 13) return 'Nomor HP Maksimal 13 Digit';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              AuthTextField(
                controller: _emailController,
                label: 'Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val == null || val.isEmpty ? 'Email Tidak Boleh Kosong' : null,
              ),
              const SizedBox(height: 32),
              LoadingButton(
                label: 'Simpan Perubahan',
                onPressed: _onSave,
                isLoading: provider.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
