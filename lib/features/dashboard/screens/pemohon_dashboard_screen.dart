import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/berita_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/berita_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/jenis_perizinan_provider.dart';
import '../../../providers/informasi_layanan_provider.dart';
import '../../../models/informasi_layanan_model.dart';
import '../../profile/screens/profil_dinas_screen.dart';
import 'berita_list_screen.dart';
import '../../../core/utils/api_exception.dart';
import '../../../core/widgets/responsive_layout.dart';

class PemohonDashboardScreen extends StatefulWidget {
  const PemohonDashboardScreen({super.key});

  @override
  State<PemohonDashboardScreen> createState() => _PemohonDashboardScreenState();
}

class _PemohonDashboardScreenState extends State<PemohonDashboardScreen> {
  final PageController _bannerPageController = PageController();
  final ScrollController _scrollController = ScrollController();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  static const Map<String, String> _informasiLayananIcons = {
    'KRK': 'assets/images/logo_krk.png',
    'SITEPLAN': 'assets/images/logo_siteplan.png',
    'PKKPR': 'assets/images/pkkpr.png',
    'PEIL': 'assets/images/peil_banjir.png',
    'RUMIJA': 'assets/images/rumija.png',
    'PBG': 'assets/images/pbg.png',
    'SLF': 'assets/images/slf.png',
    'IRIGASI': 'assets/images/irigasi_teknis.png',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboardForRole('pemohon');
      context.read<JenisPerizinanProvider>().fetchJenisPerizinan();
      context.read<InformasiLayananProvider>().fetchInformasiLayanan();
      context.read<BeritaProvider>().fetchHomeBerita();
    });
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerPageController.hasClients) {
        final sliderItems = context.read<BeritaProvider>().sliderItems;
        if (sliderItems.isNotEmpty) {
          _bannerPageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerPageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToCreatePermohonan(String kode) {
    final authProv = context.read<AuthProvider>();
    final user = authProv.user;
    
    if (user != null && (
        user.alamat == null || user.alamat!.trim().isEmpty || user.alamat!.trim() == '-' || 
        user.phone == null || user.phone!.trim().isEmpty || user.phone!.trim() == '-')) {
      context.showWarningMessage('Mohon lengkapi Alamat dan No. HP di menu Profil sebelum mengajukan permohonan.');
      return;
    }
    context.push('/permohonan/create?kode=$kode');
  }

  void _openCallCenterDialog() {
    final user = context.read<AuthProvider>().user;
    final subjekController = TextEditingController();
    final pesanController = TextEditingController();
    final formKeyState = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo_wa.png',
              width: 32,
              height: 32,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.phone, color: Color(0xFF22C55E), size: 28),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'CS WhatsApp PUPR',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKeyState,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kirim pesan langsung ke Layanan Informasi & Pengaduan Dinas PUPR Garut:',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 14),

                TextFormField(
                  initialValue: user?.name ?? 'Pemohon',
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap (Otomatis)',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color(0xFFF1F5F9),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  initialValue: user?.email ?? 'user@gmail.com',
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Email (Otomatis)',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color(0xFFF1F5F9),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: subjekController,
                  decoration: const InputDecoration(
                    labelText: 'Subjek Pertanyaan / Pengaduan *',
                    hintText: 'Contoh: Pertanyaan Syarat KRK',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Subjek wajib diisi' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: pesanController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Isi Chat / Pesan *',
                    hintText: 'Tuliskan pesan atau kendala Anda...',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Isi chat wajib diisi' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.send, size: 16),
            label: const Text('Kirim via WhatsApp'),
            onPressed: () {
              if (formKeyState.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext);

                final nama = user?.name ?? 'Pemohon';
                final email = user?.email ?? '-';
                final subjek = subjekController.text.trim();
                final pesan = pesanController.text.trim();

                // GANTI NOMOR WA DI BAWAH INI (Gunakan awalan 62 tanpa + atau 0)
                const whatsappNumber = '6282319871591';
                
                final fullMsg = 'Halo CS Dinas PUPR Garut,\n\n'
                    'Nama: $nama\n'
                    'Email: $email\n'
                    'Subjek: $subjek\n\n'
                    'Pesan:\n$pesan';

                final url = Uri.parse('https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(fullMsg)}');
                
                launchUrl(url, mode: LaunchMode.externalApplication).catchError((_) {
                  if (context.mounted) {
                    context.showWarningMessage('Gagal Membuka WhatsApp. Pastikan Aplikasi WhatsApp Terinstal.');
                  }
                  return false;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  void _showInformasiLayananModal(InformasiLayananModel item) {
    final kode = item.kode;

    final judul = item.nama;
    final tentang = item.tentang ?? '-';
    final alur = item.alur;
    final persyaratan = item.persyaratan;
    final iconAsset = _informasiLayananIcons[item.kode.toUpperCase()] ?? 'assets/images/logo.png';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.78,
        maxChildSize: 0.94,
        minChildSize: 0.5,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Drag Handle
              Center(
                child: Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF94A3B8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Custom Logo Asset Tanpa Circle Kuning (Request #4)
              Image.asset(
                iconAsset,
                width: 64,
                height: 64,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.design_services,
                  color: AppTheme.primaryColor,
                  size: 48,
                ),
              ),
              const SizedBox(height: 12),

              // Title Centered
              Text(
                judul,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description Text (Tentang Layanan)
              Text(
                tentang,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF334155),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Gold Horizontal Divider
              Container(
                width: double.infinity,
                height: 1.5,
                color: const Color(0xFFF5B800),
              ),

              const SizedBox(height: 20),

              // 2 Side-by-Side Navy Cards: Alur Pelayanan & Persyaratan
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Left: Alur Pelayanan
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C4375),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Alur Pelayanan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...alur.map(
                            (stepText) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                stepText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Card Right: Persyaratan
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C4375),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Persyaratan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...persyaratan.asMap().entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${entry.key + 1}. ',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      height: 1.4,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11.5,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
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

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showBeritaDetail(BeritaModel berita) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.only(top: 20, bottom: 0),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (berita.gambarUrl != null && berita.gambarUrl!.isNotEmpty)
              Image.network(
                berita.gambarUrl!,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                berita.judul,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF475569),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                berita.konten,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                  height: 1.7,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 32),
            // Share Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Sumber:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        berita.penulisNama ?? 'Administrator Dinas PUPR',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Bagikan:',
                        style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () async {
                          final url = Uri.parse('https://www.facebook.com/sharer/sharer.php?u=https://puprgarut.cloud');
                          try {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          } catch (e) {
                            debugPrint('Could not launch Facebook');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: const Color(0xFF1877F2), borderRadius: BorderRadius.circular(4)),
                          child: const Icon(Icons.facebook, color: Colors.white, size: 16),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          final url = Uri.parse('https://www.instagram.com/pupr.garutkab.go.id/');
                          try {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          } catch (e) {
                            debugPrint('Could not launch Instagram');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFF56040)],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          final url = Uri.parse('https://wa.me/?text=Lihat informasi ini di Aplikasi PUPR Garut!');
                          try {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          } catch (e) {
                            debugPrint('Could not launch WhatsApp');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: const Color(0xFF25D366), borderRadius: BorderRadius.circular(4)),
                          child: const Icon(Icons.phone, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Blue Footer
            ClipPath(
              clipper: _WavyTopClipper(),
              child: Container(
                width: double.infinity,
                color: const Color(0xFF1E3A8A),
                padding: const EdgeInsets.only(left: 20, right: 20, top: 50, bottom: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/LOGO_LOGIN.png',
                              width: 32,
                              height: 32,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Dinas PUPR Kabupaten Garut\nDinas Pekerjaan Umum dan Penataan Ruang',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    'Terwujudnya Infrastruktur Pekerjaan Umum dan Penataan Ruang yang Berkualitas dalam Mendukung Kabupaten Garut Bermartabat, Nyaman dan Sejahtera',
                    style: TextStyle(color: Colors.white, fontSize: 12, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.location_on_outlined, color: Colors.white70, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Jl. Raya Samarang No.117, Sukagalih, Kec. Tarogong Kidul, Kabupaten Garut, Jawa Barat 44151',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Icon(Icons.phone_outlined, color: Colors.white70, size: 16),
                      SizedBox(width: 8),
                      Text('(0262) 233730', style: TextStyle(color: Colors.white, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Icon(Icons.email_outlined, color: Colors.white70, size: 16),
                      SizedBox(width: 8),
                      Text('pupr@garutkab.go.id', style: TextStyle(color: Colors.white, fontSize: 11)),
                    ],
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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final beritaProvider = context.watch<BeritaProvider>();
    final dashboardProvider = context.watch<DashboardProvider>();
    final sliderItems = beritaProvider.sliderItems;
    final newsItems = beritaProvider.newsItems;

    // Check if there are active permohonan with updates (Request #6)
    final permohonanList = dashboardProvider.pemohonDashboard?.permohonanTerbaru ?? [];
    final hasPermohonanUpdates = permohonanList.any(
      (p) => p.status != 'draft',
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final dashProv = context.read<DashboardProvider>();
            final beritaProv = context.read<BeritaProvider>();
            final infoProv = context.read<InformasiLayananProvider>();
            await dashProv.fetchDashboardForRole('pemohon');
            await beritaProv.fetchHomeBerita();
            await infoProv.fetchInformasiLayanan();
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -------------------------------------------------------------
                // 1. Header Top: User Avatar + Hallo [Nama User] + WA Icon (Request #3 & #6)
                // -------------------------------------------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: AppTheme.primaryColor,
                              backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                              child: user?.avatarUrl == null
                                  ? Text(
                                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'R',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                            // Red Badge Indicator Dot if Permohonan has update (Request #6)
                            if (hasPermohonanUpdates)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDC2626),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hallo',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              user?.name ?? 'Pemohon',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // WhatsApp Icon Logo dari Asset (Request #3)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _openCallCenterDialog,
                        borderRadius: BorderRadius.circular(24),
                        splashColor: const Color(0xFF22C55E).withValues(alpha: 0.2),
                        child: Image.asset(
                          'assets/images/logo_wa.png',
                          width: 42,
                          height: 42,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.phone, color: Colors.white, size: 22),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // -------------------------------------------------------------
                // 2. Section "Informasi terkini"
                // -------------------------------------------------------------
                const Text(
                  'Informasi terkini',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 1080 / 450,
                      child: sliderItems.isEmpty
                        ? _buildFallbackBannerCard(
                            title: 'Sistem Perizinan Tata Ruang PUPR Garut',
                            onTap: () => _navigateToCreatePermohonan('KRK'),
                          )
                        : Stack(
                            children: [
                              PageView.builder(
                                controller: _bannerPageController,
                                onPageChanged: (idx) => setState(() => _currentBannerIndex = sliderItems.isNotEmpty ? idx % sliderItems.length : 0),
                                itemBuilder: (context, index) {
                                  if (sliderItems.isEmpty) return const SizedBox.shrink();
                                  final realIndex = index % sliderItems.length;
                                  final b = sliderItems[realIndex];
                                  return _buildFallbackBannerCard(
                                    title: b.judul,
                                    imageUrl: b.gambarUrl,
                                    onTap: () async {
                                      if (b.kategori == 'informasi_terkini' && b.linkUrl != null && b.linkUrl!.isNotEmpty) {
                                        final uri = Uri.tryParse(b.linkUrl!);
                                        if (uri != null) {
                                          try {
                                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                                            return;
                                          } catch (e) {
                                            // Fallback to _showBeritaDetail if launchUrl fails
                                          }
                                        }
                                      }
                                      _showBeritaDetail(b);
                                    },
                                  );
                                },
                              ),
                              if (sliderItems.length > 1)
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      '${_currentBannerIndex + 1} dari ${sliderItems.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),
                ),
              ),



                const SizedBox(height: 24),

                // -------------------------------------------------------------
                // 3. Section "Layanan Utama" (KRK, Siteplan, Profile) - Tanpa Circle Kuning (Request #4)
                // -------------------------------------------------------------
                const Text(
                  'Layanan Utama',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 10),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = ResponsiveLayout.isDesktop(context) ? 6 : (ResponsiveLayout.isTablet(context) ? 4 : 3);
                    final width = (constraints.maxWidth - (12 * (crossAxisCount - 1))) / crossAxisCount;
                    final provider = context.watch<JenisPerizinanProvider>();
                    final items = provider.activeItems;
                    
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ...items.where((jenis) => jenis.status.toLowerCase() == 'aktif').map((jenis) {
                          String icon = 'assets/images/logo.png';
                          if (jenis.logoUrl == null) {
                            if (jenis.kode.toUpperCase() == 'KRK') icon = 'assets/images/logo_krk.png';
                            else if (jenis.kode.toUpperCase() == 'SITEPLAN') icon = 'assets/images/logo_siteplan.png';
                            else if (jenis.kode.toUpperCase() == 'PBG') icon = 'assets/images/pbg.png';
                            else if (jenis.kode.toUpperCase() == 'SLF') icon = 'assets/images/slf.png';
                            else if (jenis.kode.toUpperCase() == 'PKKPR') icon = 'assets/images/pkkpr.png';
                            else if (jenis.kode.toUpperCase() == 'PEIL') icon = 'assets/images/peil_banjir.png';
                            else if (jenis.kode.toUpperCase() == 'RUMIJA') icon = 'assets/images/rumija.png';
                          }

                          return SizedBox(
                            width: width,
                            child: _buildServiceCard(
                              context: context,
                              imagePath: icon,
                              networkImageUrl: jenis.logoUrl,
                              label: jenis.kode,
                              onTap: () => _navigateToCreatePermohonan(jenis.kode),
                            ),
                          );
                        }),
                        SizedBox(
                          width: width,
                          child: _buildServiceCard(
                            context: context,
                            imagePath: 'assets/images/logo_profildinas.png',
                            label: 'Profil Dinas',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ProfilDinasScreen()),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 28),

                // -------------------------------------------------------------
                // 4. Section "Informasi Layanan" (2 Rows x 4 Columns Grid) - Tanpa Circle Kuning (Request #4 & #5)
                // -------------------------------------------------------------
                const Text(
                  'Informasi Layanan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 10),

                Consumer<InformasiLayananProvider>(
                  builder: (context, infoProvider, _) {
                    if (infoProvider.isLoading && infoProvider.items.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (infoProvider.items.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: infoProvider.items.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: ResponsiveLayout.isDesktop(context) ? 6 : (ResponsiveLayout.isTablet(context) ? 4 : 4),
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.82,
                        ),
                        itemBuilder: (context, index) {
                          final item = infoProvider.items[index];
                          return _buildInformasiLayananGridItem(context, item);
                        },
                      ),
                    );
                  }
                ),

                const SizedBox(height: 28),

                // -------------------------------------------------------------
                // 5. Section "PUPR news"
                // -------------------------------------------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Berita PUPR',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BeritaListScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Berita Lainnya',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (newsItems.isEmpty)
                  _buildNewsListItem(
                    title: 'Layanan Perizinan Tata Ruang PUPR Garut Online',
                    onTap: () {},
                  )
                else
                  ...newsItems.take(5).map((b) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildNewsListItem(
                        title: b.judul,
                        imageUrl: b.gambarUrl,
                        date: b.createdAt.split('T').first,
                        category: b.kategori,
                        onTap: () => _showBeritaDetail(b),
                      ),
                    );
                  }),

                const SizedBox(height: 24),
                
                // "Kembali ke Atas" Button
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: const Icon(Icons.arrow_upward, color: AppTheme.primaryColor, size: 20),
                    label: const Text(
                      'Kembali ke atas',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                // Add bottom padding so the floating navigation bar doesn't cover the last news item
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Item Grid Informasi Layanan — Tanpa Circle Kuning (Request #4 & #5)
  Widget _buildInformasiLayananGridItem(BuildContext context, InformasiLayananModel item) {
    final iconAsset = _informasiLayananIcons[item.kode.toUpperCase()] ?? 'assets/images/logo.png';
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _showInformasiLayananModal(item),
        borderRadius: BorderRadius.circular(12),
        splashColor: AppTheme.goldColor.withValues(alpha: 0.2),
        hoverColor: const Color(0xFFF1F5F9),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image Asset Langsung Tanpa Circle Kuning (Request #4)
              Image.asset(
                iconAsset,
                width: 48,
                height: 48,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.nama,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackBannerCard({
    required String title,
    String? imageUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          image: imageUrl != null && imageUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.fill,
                  )
                : null,
          ),
        child: (imageUrl != null && imageUrl.isNotEmpty)
            ? null
            : Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 90,
                    alignment: Alignment.bottomRight,
                    child: Image.asset(
                      'assets/images/watermark.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.campaign,
                        size: 60,
                        color: Color(0xFFF97316),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildNewsListItem({
    required String title,
    String? imageUrl,
    String? date,
    String? category,
    required VoidCallback onTap,
  }) {
    String displayCategory = category != null && category.isNotEmpty
        ? (category == 'informasi_terkini' ? 'Informasi Terkini' : 'Berita')
        : 'Berita';
        
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Content (Left)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (date != null)
                    Text(
                      '$displayCategory • $date',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Thumbnail (Right)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildFallbackThumbnail(),
                    )
                  : _buildFallbackThumbnail(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackThumbnail() {
    return Container(
      width: 80,
      height: 80,
      color: const Color(0xFFF1F5F9),
      child: const Icon(Icons.article, color: Color(0xFF94A3B8), size: 30),
    );
  }

  // Card Layanan Utama — Tanpa Circle Kuning (Request #4 & #5)
  Widget _buildServiceCard({
    required BuildContext context,
    required String imagePath,
    String? networkImageUrl,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: AppTheme.goldColor.withValues(alpha: 0.2),
          hoverColor: const Color(0xFFF8FAFC),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Image Langsung Tanpa Circle Kuning (Request #4)
              networkImageUrl != null
                  ? Image.network(
                      networkImageUrl,
                      width: 52,
                      height: 52,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        imagePath,
                        width: 52,
                        height: 52,
                        fit: BoxFit.contain,
                      ),
                    )
                  : Image.asset(
                      imagePath,
                      width: 52,
                      height: 52,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.design_services,
                        color: AppTheme.primaryColor,
                        size: 36,
                      ),
                    ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WavyTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 25);
    
    // Wave down then up
    var firstControlPoint = Offset(size.width / 4, 0);
    var firstEndPoint = Offset(size.width / 2, 25);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    
    var secondControlPoint = Offset(size.width - (size.width / 4), 50);
    var secondEndPoint = Offset(size.width, 25);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
