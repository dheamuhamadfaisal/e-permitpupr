import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/profil_dinas_provider.dart';

class ProfilDinasScreen extends StatefulWidget {
  const ProfilDinasScreen({super.key});

  @override
  State<ProfilDinasScreen> createState() => _ProfilDinasScreenState();
}

class _ProfilDinasScreenState extends State<ProfilDinasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfilDinasProvider>().fetchProfilDinas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfilDinasProvider>();
    final profil = provider.profil;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Dinas PUPR Garut'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.fetchProfilDinas(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Logo & Office Photo Header
                    Center(
                      child: Column(
                        children: [
                          if (profil?.fotoUrl != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                profil!.fotoUrl!,
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Image.asset(
                                  'assets/images/logo_profildinas.png',
                                  width: 90,
                                  height: 90,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ] else ...[
                            Image.asset(
                              'assets/images/logo_profildinas.png',
                              width: 90,
                              height: 90,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.account_balance,
                                size: 80,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Text(
                            profil?.namaDinas ?? 'Dinas PUPR Kabupaten Garut',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profil?.subNama ?? 'Dinas Pekerjaan Umum dan Penataan Ruang',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Card Visi
                    Card(
                      elevation: 0,
                      color: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.remove_red_eye_outlined, color: AppTheme.goldColor, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'VISI',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.goldColor,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '"${profil?.visi ?? 'Terwujudnya Infrastruktur Pekerjaan Umum dan Penataan Ruang yang Berkualitas dalam Mendukung Kabupaten Garut Bermartabat, Nyaman dan Sejahtera'}"',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                height: 1.5,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Card Misi
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.flag_outlined, color: AppTheme.primaryColor, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'MISI',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            if (profil?.misi.isNotEmpty ?? false)
                              ...List.generate(
                                profil!.misi.length,
                                (index) => _buildMisiItem('${index + 1}.', profil.misi[index]),
                              )
                            else ...[
                              _buildMisiItem('1.', 'Meningkatkan kualitas aparatur sipil negara yang profesional dan beretika.'),
                              _buildMisiItem('2.', 'Meningkatkan tata kelola organisasi dalam perencanaan, pelaksanaan dan pengawasan yang terpadu dan tepat sasaran.'),
                              _buildMisiItem('3.', 'Mewujudkan infrastruktur jalan, permukiman, sumber daya air, bangunan, yang berkualitas dan memadai dengan berbasis penataan ruang.'),
                              _buildMisiItem('4.', 'Meningkatkan kualitas dan kuantitas sarana penunjang sumber daya manusia dan infrastruktur.'),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Informasi Kontak & Alamat Kantor
                    const Text(
                      'Informasi Kontak & Alamat Kantor',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on, color: AppTheme.primaryColor, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  profil?.alamat ?? 'Jl. Raya Samarang No.117, Sukagalih, Kec. Tarogong Kidul, Kabupaten Garut, Jawa Barat 44151',
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              const Icon(Icons.phone, color: AppTheme.primaryColor, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                profil?.telepon ?? '(0262) 233730',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.email, color: AppTheme.primaryColor, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                profil?.email ?? 'pupr@garutkab.go.id',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMisiItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
