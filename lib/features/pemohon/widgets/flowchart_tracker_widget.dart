import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/permohonan_model.dart';

class FlowchartTrackerWidget extends StatelessWidget {
  final PermohonanModel permohonan;

  const FlowchartTrackerWidget({
    super.key,
    required this.permohonan,
  });

  /// Tentukan stage mana yang sedang aktif saat ini (1 sampai 4)
  int get currentStageIndex {
    final s = permohonan.status.toLowerCase();
    if (s == 'draft' || s == 'diajukan' || s == 'dalam_validasi_kelengkapan' || s == 'pemeriksaan_administrasi' || s == 'pemeriksaan_teknis') {
      return 1; // Stage 1: Bidang Tata Ruang (Validasi Kelengkapan Berkas)
    } else if (s == 'perlu_kunjungan_lapangan' || s == 'survey') {
      return 2; // Stage 2: Bidang Tata Ruang (Kunjungan Lapangan)
    } else if (s == 'dalam_analisis' || s == 'rekomendasi' || s == 'menunggu_verifikasi') {
      return 3; // Stage 3: Bidang Tata Ruang (Analisis Data & Draft Surat)
    } else if (s == 'siap_terbit' || s == 'terbit' || s == 'disetujui' || s == 'selesai') {
      return 4; // Stage 4: Pemohon (Surat Terbit & Download PDF)
    } else if (s == 'perlu_revisi' || s == 'tidak_lengkap' || s == 'revisi') {
      return 1;
    } else if (s == 'ditolak_permanen' || s == 'ditolak') {
      return 4;
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = currentStageIndex;
    final isSiteplan = (permohonan.jenisPerizinan?.kode ?? '').toUpperCase() == 'SITEPLAN';

    final List<Map<String, dynamic>> stages = [
      {
        'stage': 1,
        'role': 'Bidang Tata Ruang',
        'title': '1. Validasi Kelengkapan Berkas',
        'desc': 'Pemeriksaan kelengkapan berkas administratif & teknis oleh Bidang Tata Ruang',
      },
      {
        'stage': 2,
        'role': 'Bidang Tata Ruang',
        'title': '2. Kunjungan Lapangan',
        'desc': isSiteplan
            ? 'Peninjauan fisik lokasi & survey peta lokasi (Wajib untuk Siteplan)'
            : 'Peninjauan fisik lokasi & survey peta lokasi (Kondisional untuk KRK)',
      },
      {
        'stage': 3,
        'role': 'Bidang Tata Ruang',
        'title': '3. Analisis Kesesuaian Tata Ruang',
        'desc': 'Pemeriksaan kesesuaian tata ruang, koordinasi teknis, & pembuatan draft surat',
      },
      {
        'stage': 4,
        'role': 'Bidang Tata Ruang & Pemohon',
        'title': '4. Penerbitan Surat & Download Hasil',
        'desc': 'Surat Resmi Perizinan telah terbit dan dapat diunduh langsung oleh pemohon',
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_tree_outlined, color: AppTheme.primaryColor, size: 22),
                const SizedBox(width: 8),
                const Text(
                  'Alur Pengajuan (SOP Permohonan)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Pelacakan Real-time Bidang Tata Ruang PUPR Garut (${isSiteplan ? "Alur Siteplan" : "Alur KRK"}):',
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),

            // Timelines Steps
            Column(
              children: List.generate(stages.length, (index) {
                final stage = stages[index];
                final int stageNum = stage['stage'] as int;
                final bool isCurrent = stageNum == activeIndex;
                final bool isPast = stageNum < activeIndex;
                final bool isLast = index == stages.length - 1;

                Color circleBgColor;
                Color circleTextColor;
                IconData? circleIcon;

                if (isPast) {
                  circleBgColor = const Color(0xFF16A34A);
                  circleTextColor = Colors.white;
                  circleIcon = Icons.check;
                } else if (isCurrent) {
                  circleBgColor = AppTheme.goldColor;
                  circleTextColor = Colors.white;
                } else {
                  circleBgColor = const Color(0xFFF1F5F9);
                  circleTextColor = const Color(0xFF94A3B8);
                }

                if (permohonan.isDitolakPermanen && isCurrent) {
                  circleBgColor = const Color(0xFFDC2626);
                  circleIcon = Icons.close;
                }

                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Indicator Badge
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: circleBgColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCurrent && !permohonan.isDitolakPermanen ? AppTheme.goldColor : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: circleIcon != null
                                ? Icon(circleIcon, size: 18, color: circleTextColor)
                                : Text(
                                    '$stageNum',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: circleTextColor,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Stage Text Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      stage['role'] as String,
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                                    ),
                                  ),
                                  if (isCurrent && !permohonan.isTerbit && !permohonan.isDitolakPermanen) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.goldColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'PROSES SEKARANG',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                stage['title'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isCurrent ? AppTheme.primaryColor : const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                stage['desc'] as String,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (!isLast)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 17, top: 4, bottom: 4),
                          child: Container(
                            width: 2,
                            height: 24,
                            color: (index + 1) < activeIndex
                                ? const Color(0xFF16A34A)
                                : (index + 1) == activeIndex
                                    ? AppTheme.goldColor
                                    : const Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
