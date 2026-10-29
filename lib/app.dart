// ============================================================
// app.dart — Root Widget Aplikasi e-License PUPR Garut
// ============================================================
//
// File ini bertanggung jawab untuk:
// 1. Menyediakan semua Provider ke seluruh widget tree (MultiProvider)
// 2. Menginisialisasi GoRouter untuk navigasi berbasis URL
// 3. Menerapkan tema global (AppTheme.lightTheme)
// 4. Mencegah perubahan ukuran teks berdasarkan pengaturan aksesibilitas sistem
//    (TextScaler.noScaling) agar layout tidak rusak
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/admin_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/berita_provider.dart';
import 'providers/profil_dinas_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/dokumen_provider.dart';
import 'providers/jenis_perizinan_provider.dart';
import 'providers/informasi_layanan_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/operator_provider.dart';
import 'providers/permohonan_provider.dart';
import 'providers/petugas_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/verifikator_provider.dart';
import 'routes/app_router.dart';

/// [PuprPerizinanApp] adalah root widget aplikasi e-License PUPR Garut.
///
/// Widget ini membungkus seluruh aplikasi dengan [MultiProvider] sehingga
/// semua state management (Provider) dapat diakses dari widget mana saja
/// di dalam pohon widget.
///
/// Arsitektur: Provider Pattern (ChangeNotifier)
/// - Provider bertugas sebagai "jembatan" antara UI dan logic bisnis
/// - Setiap provider hanya dibuat sekali (singleton per app session)
class PuprPerizinanApp extends StatelessWidget {
  const PuprPerizinanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Daftar semua provider yang tersedia di seluruh aplikasi.
      // Setiap ChangeNotifierProvider membuat instance provider sekali saja
      // dan mendistribusikannya ke seluruh widget tree.
      providers: [
        // Provider autentikasi: menyimpan status login, data user, token
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Provider dashboard: statistik permohonan per role
        ChangeNotifierProvider(create: (_) => DashboardProvider()),

        // Provider profil user: edit nama, alamat, telepon, email
        ChangeNotifierProvider(create: (_) => ProfileProvider()),

        // Provider jenis perizinan: KRK, Siteplan, PBG, dll.
        ChangeNotifierProvider(create: (_) => JenisPerizinanProvider()),

        // Provider permohonan: CRUD permohonan oleh pemohon
        ChangeNotifierProvider(create: (_) => PermohonanProvider()),

        // Provider dokumen: upload dan manajemen berkas permohonan
        ChangeNotifierProvider(create: (_) => DokumenProvider()),

        // Provider operator: kelola permohonan masuk (validasi administrasi)
        ChangeNotifierProvider(create: (_) => OperatorProvider()),

        // Provider petugas: survey, pemeriksaan teknis, rekomendasi
        ChangeNotifierProvider(create: (_) => PetugasProvider()),

        // Provider verifikator: keputusan akhir (setuju/tolak)
        ChangeNotifierProvider(create: (_) => VerifikatorProvider()),

        // Provider notifikasi: notifikasi push/database dari backend
        ChangeNotifierProvider(create: (_) => NotificationProvider()),

        // Provider admin IT: kelola user, monitoring semua permohonan
        ChangeNotifierProvider(create: (_) => AdminProvider()),

        // Provider berita & banner: konten CMS halaman utama
        ChangeNotifierProvider(create: (_) => BeritaProvider()),

        // Provider profil dinas: informasi instansi PUPR Garut
        ChangeNotifierProvider(create: (_) => ProfilDinasProvider()),

        // Provider informasi layanan: deskripsi dan persyaratan tiap layanan
        ChangeNotifierProvider(create: (_) => InformasiLayananProvider()),
      ],
      child: const _AppWithRouter(),
    );
  }
}

/// Widget internal yang membangun [MaterialApp.router] dengan [GoRouter].
///
/// Dipisahkan menjadi [StatefulWidget] karena router perlu diinisialisasi
/// di [initState] menggunakan [AuthProvider] yang sudah tersedia dari
/// [MultiProvider] di atas.
class _AppWithRouter extends StatefulWidget {
  const _AppWithRouter();

  @override
  State<_AppWithRouter> createState() => _AppWithRouterState();
}

class _AppWithRouterState extends State<_AppWithRouter> {
  /// Instance GoRouter yang mengelola semua navigasi aplikasi.
  /// Diinisialisasi sekali di [initState] dan tidak dibuat ulang.
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Ambil AuthProvider yang sudah ada di widget tree (bukan buat baru)
    // AuthProvider digunakan oleh router untuk redirect berdasarkan status login
    final authProvider = context.read<AuthProvider>();
    _router = AppRouter.createRouter(authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // Nama aplikasi (muncul di task switcher Android/iOS)
      title: 'e-License PUPR Garut',

      // Sembunyikan label "DEBUG" di pojok kanan atas saat mode debug
      debugShowCheckedModeBanner: false,

      // Terapkan tema global dari AppTheme (warna biru tua + kuning emas PUPR)
      theme: AppTheme.lightTheme,

      // Konfigurasi router dari GoRouter
      routerConfig: _router,

      // Builder untuk memaksa semua teks menggunakan ukuran asli (tidak ikut
      // setting aksesibilitas "Ukuran Font" di sistem operasi).
      // Ini mencegah layout rusak akibat font terlalu besar atau kecil.
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling, // Matikan scaling teks sistem
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
