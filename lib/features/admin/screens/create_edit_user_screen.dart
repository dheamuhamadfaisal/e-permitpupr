import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/api_exception.dart';
import '../../../features/auth/widgets/auth_text_field.dart';
import '../../../models/user_model.dart';
import '../../../providers/admin_provider.dart';
import '../../../widgets/loading_button.dart';

class CreateEditUserScreen extends StatefulWidget {
  final UserModel? user;

  const CreateEditUserScreen({
    super.key,
    this.user,
  });

  @override
  State<CreateEditUserScreen> createState() => _CreateEditUserScreenState();
}

class _CreateEditUserScreenState extends State<CreateEditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _alamatController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  String _selectedRole = 'operator';
  bool _isActive = true;

  final List<Map<String, String>> _roleItems = [
    {'value': 'admin', 'label': 'Admin IT'},
    {'value': 'operator', 'label': 'Operator Bagian Umum'},
    {'value': 'petugas', 'label': 'Petugas Tata Ruang'},
    {'value': 'pemohon', 'label': 'Pemohon (Warga)'},
  ];

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nameController = TextEditingController(text: u?.name ?? '');
    _alamatController = TextEditingController(text: u?.alamat ?? '');
    _phoneController = TextEditingController(text: u?.phone ?? '');
    _emailController = TextEditingController(text: u?.email ?? '');
    _passwordController = TextEditingController();

    if (u != null) {
      final slug = u.primaryRoleSlug;
      _selectedRole = (slug != null && slug.isNotEmpty) ? slug : 'operator';
      _isActive = u.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _alamatController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final provider = context.read<AdminProvider>();
    bool success = false;

    if (widget.user == null) {
      // Create User
      if (_passwordController.text.isEmpty) {
        context.showApiError(const ApiException(message: 'Password Wajib Diisi Untuk User Baru'));
        return;
      }

      success = await provider.createUser(
        name: _nameController.text.trim(),
        alamat: _alamatController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
        isActive: _isActive,
      );
    } else {
      // Update User
      success = await provider.updateUser(
        id: widget.user!.id,
        name: _nameController.text.trim(),
        alamat: _alamatController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
        role: _selectedRole,
        isActive: _isActive,
      );
    }

    if (!mounted) return;

    if (success) {
      // Tutup keyboard agar animasi lebih smooth
      FocusManager.instance.primaryFocus?.unfocus();
      
      context.showSuccessMessage(
        widget.user == null ? 'User Baru Berhasil Dibuat' : 'Data User Berhasil Diperbarui',
      );
      
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) Navigator.pop(context);
      });
    } else if (provider.error != null) {
      context.showApiError(ApiException(message: provider.error!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final isEdit = widget.user != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit User Internal' : 'Tambah User Internal Baru'),
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
                validator: (val) => val == null || val.trim().isEmpty ? 'Nama Wajib Diisi' : null,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _alamatController,
                label: 'Alamat',
                prefixIcon: Icons.home_work_outlined,
              ),
              const SizedBox(height: 16),
              if (_selectedRole == 'pemohon') ...[
                AuthTextField(
                  controller: _phoneController,
                  label: 'No. Handphone',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
              ],
              AuthTextField(
                controller: _emailController,
                label: 'Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val == null || val.trim().isEmpty ? 'Email Wajib Diisi' : null,
              ),
              const SizedBox(height: 16),
              PasswordTextField(
                controller: _passwordController,
                label: isEdit ? 'Password (Kosongkan Jika Tidak Diubah)' : 'Password Baru',
                validator: (val) {
                  if (!isEdit && (val == null || val.isEmpty)) return 'Password Wajib Diisi';
                  if (val != null && val.isNotEmpty && val.length < 8) return 'Password Minimal 8 Karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role Hak Akses',
                  border: OutlineInputBorder(),
                ),
                items: _roleItems.map((r) {
                  return DropdownMenuItem<String>(
                    value: r['value'],
                    child: Text(r['label']!),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedRole = val!),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Status Akun Aktif'),
                subtitle: Text(_isActive ? 'User Dapat Login' : 'User Dinonaktifkan'),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),
              const SizedBox(height: 32),
              LoadingButton(
                label: isEdit ? 'Simpan Perubahan User' : 'Buat User Baru',
                isLoading: provider.isActionLoading,
                onPressed: _onSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
