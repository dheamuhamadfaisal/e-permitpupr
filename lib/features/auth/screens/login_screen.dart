import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/api_exception.dart';
import '../../../core/widgets/global_error_bottom_sheet.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('saved_email');
      final savedPassword = prefs.getString('saved_password');
      if (savedEmail != null) _emailController.text = savedEmail;
      if (savedPassword != null) _passwordController.text = savedPassword;
    } catch (_) {}
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();

    final success = authProvider.isLoading
        ? false
        : await authProvider.login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

    if (!mounted) return;

    if (!success) {
      final error = authProvider.errorMessage ?? 'Login Gagal.';
      
      showGlobalErrorBottomSheet(
        context,
        errorMessage: error,
        onRetry: () {
        },
      );
    } else {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_email', _emailController.text.trim());
        await prefs.setString('saved_password', _passwordController.text);
      } catch (_) {}
    }
  }

  Future<void> _onGoogleLogin() async {
    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();
    
    try {
      // Menambahkan clientId dummy untuk Web agar tidak crash jika belum disetup
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: kIsWeb ? 'dummy-client-id.apps.googleusercontent.com' : null,
      );
      
      // Force account picker by signing out the cached session first
      await googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        return; // User canceled
      }
      
      if (!mounted) return;
      
      final success = await authProvider.loginWithGoogle(
        email: googleUser.email,
        name: googleUser.displayName ?? '',
        googleId: googleUser.id,
        avatar: googleUser.photoUrl,
      );
      
      if (!mounted) return;
      
      if (!success) {
        final error = authProvider.errorMessage ?? 'Google Login gagal.';
        showGlobalErrorBottomSheet(
          context,
          errorMessage: error,
          onRetry: () {},
        );
      }
    } catch (error) {
      if (!mounted) return;
      showGlobalErrorBottomSheet(
        context,
        errorMessage: kIsWeb && error.toString().contains('dummy-client-id')
          ? 'Login Google belum dikonfigurasi untuk Web (Client ID belum ada).'
          : 'Terjadi Kesalahan Saat Login Dengan Google: $error',
        onRetry: () {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const SizedBox.expand(), // Forces Stack to take full screen size
          // 1. Watermark Accent di Sangat Pojok Kiri Bawah (Bottom-Left Angle)
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

          // 2. Content Form Login (Diturunkan Lebih ke Bawah / Vertically Centered)
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Form(
                    key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Spasi Atas agar Form Login berada lebih ke bawah (sesuai Mockup Gambar 1)
                    SizedBox(height: size.height * 0.22),

                    // Header Logo (Logo di Kiri, Teks di Kanan)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/LOGO_LOGIN.png',
                          width: 60,
                          height: 60,
                          errorBuilder: (context, error, stackTrace) => Image.asset(
                            'assets/images/logo.png',
                            width: 60,
                            height: 60,
                          ),
                        ),
                        const SizedBox(width: 14),
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
                              'Penyedia Perijinan KRK \ndan SitePlan PUPR Garut',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 44),

                    // Input Field: Email (Underline Style)
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF0F172A),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 15),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(Icons.email, color: Color(0xFF1E3A6E), size: 22),
                        ),
                        prefixIconConstraints: BoxConstraints(minWidth: 36),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF64748B), width: 1.2),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFFCC00), width: 2.0),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(value.trim())) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Input Field: Password (Underline Style)
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _onLogin(),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 15),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(Icons.lock, color: Color(0xFF1E3A6E), size: 22),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 36),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: const Color(0xFF0F172A),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF64748B), width: 1.2),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFFCC00), width: 2.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password Tidak Boleh Kosong';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Tombol Login (Kuning Emas)
                    LoadingButton(
                      label: 'Login',
                      onPressed: _onLogin,
                      isLoading: authProvider.isLoading,
                      backgroundColor: const Color(0xFFFFCC00),
                      foregroundColor: Colors.white,
                      height: 48,
                    ),

                    const SizedBox(height: 18),

                    // Link Daftar Akun
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Belum Punya Akun? ',
                          style: TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 13,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push(AppRoutes.register),
                          child: const Text(
                            'Daftar',
                            style: TextStyle(
                              color: Color(0xFF1E3A6E),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('ATAU', style: TextStyle(color: Colors.grey)),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _onGoogleLogin,
                        icon: Image.asset('assets/images/google_logo.png', width: 24, height: 24),
                        label: const Text('Lanjutkan Dengan Google', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          foregroundColor: const Color(0xFF0F172A),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          ),
          ),
        ],
      ),
    );
  }
}
