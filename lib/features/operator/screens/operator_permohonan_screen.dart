import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'kelola_informasi_layanan_screen.dart';

/// Dashboard Utama Bagian Umum (Operator)
/// Peran khusus Bagian Umum: Pengelolaan Berita, Informasi Layanan Publik, dan Profil Dinas / Visi Misi PUPR Garut.
/// Sesuai instruksi: Seluruh statistik permohonan telah dihapus dari tampilan Bagian Umum.
class OperatorPermohonanScreen extends StatelessWidget {
  const OperatorPermohonanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Dashboard Bagian Umum'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Peran Bagian Umum PUPR Garut
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.admin_panel_settings_outlined, color: AppTheme.goldColor, size: 40),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Peran Akun Bagian Umum',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Pengelolaan Informasi Layanan Publik, Berita Pengumuman, serta Visi Misi Dinas PUPR Garut.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Menu Pengelolaan Bagian Umum:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 14),

            // Card 1: Kelola Informasi Layanan Publik
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.goldColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.info_outline_rounded, color: Color(0xFFB45309), size: 28),
                ),
                title: const Text(
                  'Kelola Informasi Layanan Publik',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                subtitle: const Text(
                  'Atur Deskripsi, Alur Pelayanan, dan Persyaratan 8 Jenis Layanan Publik PUPR Garut',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const KelolaInformasiLayananScreen()),
                  );
                },
              ),
            ),



            const SizedBox(height: 24),

            // Catatan SOP Terbaru
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Color(0xFFB45309), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'SOP Terbaru: Seluruh Validasi Teknis & Penerbitan Permohonan Perizinan Diproses Oleh Validator Bidang Tata Ruang.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF78350F), height: 1.3),
                    ),
                  ),
                ],
              ),
            ),

            // Add padding for floating navigation bar
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
