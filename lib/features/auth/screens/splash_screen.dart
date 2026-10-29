import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const navy = Color(0xFF16255E);
  bool _isPhase2 = false;

  @override
  void initState() {
    super.initState();
    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    // Fase 1: Menampilkan Logo, Nama, dan Loading (2.5 detik)
    await Future.delayed(const Duration(milliseconds: 5000));
    if (!mounted) return;
    
    // Transisi halus ke Fase 2
    setState(() {
      _isPhase2 = true;
    });

    // Tunggu Fase 2 selama 2 detik
    await Future.delayed(const Duration(milliseconds: 2000));
    
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    await authProvider.checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Logo & Teks Fase 1 (Tengah)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo yang membesar perlahan
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOutBack, // Animasi memantul sedikit
                  width: _isPhase2 ? 160 : 100,
                  height: _isPhase2 ? 160 : 100,
                  child: Image.asset(
                    'assets/images/logo.png', // Logo berwarna
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image_not_supported,
                      color: navy,
                      size: 80,
                    ),
                  ),
                ),
                
                // Teks yang menghilang dan mengecil ukurannya
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  opacity: _isPhase2 ? 0.0 : 1.0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeInOut,
                    height: _isPhase2 ? 0 : 200, // Mengecil saat fase 2 agar logo turun ke tengah
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            'e-PERMIT PUPR',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: navy, // Teks biru dongker
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Penyedia Layanan KRK, SITEPLAN\ndan Sistem PUPR Garut',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Keterangan Developer Fase 2 (Muncul dari bawah)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutBack,
            bottom: _isPhase2 ? 40 : -100,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 800),
              opacity: _isPhase2 ? 1.0 : 0.0,
              child: Column(
                children: [
                  Text(
                    'Dikembangkan Oleh:',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Image.asset(
                    'assets/images/logo_itg.png',
                    height: 48,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(height: 48),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Dhea Muhamad Faisal dan Moh Ramdani',
                    style: TextStyle(
                      color: Color(0xFF1E293B), // Slate 800
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}