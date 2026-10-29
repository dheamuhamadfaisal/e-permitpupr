import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/api_exception.dart';
import '../../../core/widgets/global_error_bottom_sheet.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/loading_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _alamatController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _alamatController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();

    final success = authProvider.isLoading
        ? false
        : await authProvider.register(
            name: _nameController.text.trim(),
            alamat: _alamatController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            passwordConfirmation: _passwordConfirmController.text,
          );

    if (!mounted) return;

    if (!success) {
      final error = authProvider.errorMessage ?? 'Registrasi gagal.';
      showGlobalErrorBottomSheet(
        context,
        errorMessage: error,
        onRetry: () {
          // Hanya tutup sheet
        },
      );
    } else {
      context.showSuccessMessage('Registrasi berhasil! Silakan login.');
      context.go('/login'); // Kembali ke halaman Login secara eksplisit
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top White Header (Teks di Kiri, Logo di Kanan)
            Padding(
              padding: const EdgeInsets.only(left: 32, right: 32, top: 16, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'e-PERMIT PUPR',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Penyedia Perijinan KRK\ndan SitePlan PUPR Garut',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Image.asset(
                    'assets/images/LOGO_LOGIN.png',
                    width: 54,
                    height: 54,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/logo.png',
                      width: 54,
                      height: 54,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Yellow Curved Container (Memenuhi Seluruh Sisa Layar Sampai Ujung Bawah)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFCC00),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(110),
                  ),
                ),
                child: Stack(
                  children: [
                    // Watermark Accent Tepat di Sangat Pojok Kiri Bawah (Bottom-Left Angle)
                    Positioned(
                      left: -110,
                      bottom: -100,
                      width: 240,
                      height: 240,
                      child: IgnorePointer(
                        child: Opacity(
                          opacity: 0.95,
                          child: Image.asset(
                            'assets/images/WATERMARK_LOGIN.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Image.asset(
                              'assets/images/watermark.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Scrollable Form Fields
                    SingleChildScrollView(
                      padding: const EdgeInsets.only(left: 36, right: 36, top: 40, bottom: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Nama Lengkap
                            _buildYellowUnderlineField(
                              controller: _nameController,
                              hintText: 'Nama Lengkap',
                              validator: (val) => val == null || val.trim().isEmpty ? 'Nama lengkap wajib diisi' : null,
                            ),
                            const SizedBox(height: 16),

                            // 2. Alamat
                            _buildYellowUnderlineField(
                              controller: _alamatController,
                              hintText: 'Alamat',
                              keyboardType: TextInputType.streetAddress,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Alamat Wajib Diisi';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // 3. No. Handphone
                            _buildYellowUnderlineField(
                              controller: _phoneController,
                              hintText: 'No. Handphone',
                              keyboardType: TextInputType.phone,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (val) => val == null || val.trim().isEmpty ? 'No. HP Wajib Diisi' : null,
                            ),
                            const SizedBox(height: 16),

                            // 4. Email
                            _buildYellowUnderlineField(
                              controller: _emailController,
                              hintText: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Email Wajib Diisi';
                                if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(val.trim())) return 'Email Tidak Valid';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // 5. Password
                            _buildYellowUnderlineField(
                              controller: _passwordController,
                              hintText: 'Password',
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: const Color(0xFF0F172A),
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Password Wajib Diisi';
                                if (val.length < 8) return 'Minimal 8 Karakter';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // 6. Konfirmasi Password
                            _buildYellowUnderlineField(
                              controller: _passwordConfirmController,
                              hintText: 'Konfirmasi Password',
                              obscureText: _obscureConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: const Color(0xFF0F172A),
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Konfirmasi Password Wajib Diisi';
                                if (val != _passwordController.text) return 'Password Tidak Cocok';
                                return null;
                              },
                            ),

                            const SizedBox(height: 28),

                            // Tombol Daftar (Dark Navy Blue Button)
                            LoadingButton(
                              label: 'Daftar',
                              onPressed: _onRegister,
                              isLoading: authProvider.isLoading,
                              backgroundColor: const Color(0xFF1E3A6E),
                              foregroundColor: Colors.white,
                              height: 48,
                            ),

                            const SizedBox(height: 16),

                            // Link Sudah punya akun? Masuk
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Sudah Punya Akun? ',
                                  style: TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 13,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context.pop(),
                                  child: const Text(
                                    'Masuk',
                                    style: TextStyle(
                                      color: Color(0xFF1E3A6E),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYellowUnderlineField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF334155), fontSize: 14),
        suffixIcon: suffixIcon,
        counterText: '',
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF0F172A), width: 1.3),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF0F172A), width: 2.2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
      validator: validator,
    );
  }
}
