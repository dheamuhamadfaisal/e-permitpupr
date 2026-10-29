import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/api_exception.dart';
import '../../../providers/admin_provider.dart';
import '../../pemohon/widgets/dokumen_section_widget.dart';
import '../../pemohon/widgets/status_badge.dart';
import '../../pemohon/widgets/status_timeline.dart';

class AdminDetailScreen extends StatefulWidget {
  final int permohonanId;

  const AdminDetailScreen({
    super.key,
    required this.permohonanId,
  });

  @override
  State<AdminDetailScreen> createState() => _AdminDetailScreenState();
}

class _AdminDetailScreenState extends State<AdminDetailScreen> {
  bool _isRiwayatExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchMonitoringDetail(widget.permohonanId);
    });
  }

  Future<void> _downloadSurat(String? urlPath) async {
    if (urlPath == null || urlPath.isEmpty) return;

    try {
      if (mounted) context.showWarningMessage('Mengunduh Surat Izin...');

      String finalUrl = urlPath;
      if (!finalUrl.startsWith('http')) {
        finalUrl = '${ApiConstants.baseUrl.replaceAll('/api', '')}/storage/$urlPath';
      }

      if (finalUrl.contains('localhost')) {
        finalUrl = finalUrl.replaceAll('localhost', '10.0.2.2');
      }

      final dio = Dio();
      final tempDir = await getTemporaryDirectory();
      
      final fileName = urlPath.split('/').last.replaceAll(RegExp(r'[^a-zA-Z0-9.\-_]'), '_');
      final savePath = '${tempDir.path}/$fileName';

      await dio.download(finalUrl, savePath);

      if (!mounted) return;
      
      final result = await OpenFilex.open(savePath);
      if (result.type != ResultType.done && mounted) {
        context.showApiError(ApiException(message: 'Gagal Membuka File: ${result.message}'));
      }
    } catch (e) {
      if (!mounted) return;
      context.showApiError(const ApiException(message: 'Gagal Mengunduh Surat Perizinan'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final permohonan = provider.selectedMonitoring;

    return Scaffold(
      appBar: AppBar(
        title: Text(permohonan?.nomorPermohonan ?? 'Detail Monitoring'),
        actions: [],
      ),
      body: provider.isMonitoringLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(provider.error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => provider.fetchMonitoringDetail(widget.permohonanId),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : permohonan == null
                  ? const Center(child: Text('Data Permohonan Tidak Ditemukan'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // BANNER SURAT TERBIT (SUKSES)
                          if (permohonan.isTerbit) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFF22C55E), width: 1.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.verified_rounded, color: Color(0xFF16A34A), size: 24),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'SURAT RESMI PERIZINAN TELAH TERBIT',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF16A34A),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Permohonan telah disetujui dan Surat Perizinan Resmi telah diterbitkan oleh Bidang Tata Ruang PUPR Garut.',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF15803D), height: 1.3),
                                  ),
                                  if (permohonan.fileSuratTerbit != null || permohonan.fileSuratTerbitUrl != null) ...[
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF16A34A),
                                        foregroundColor: Colors.white,
                                      ),
                                      icon: const Icon(Icons.file_download_outlined, size: 18),
                                      label: const Text('Unduh Surat Perizinan PDF'),
                                      onPressed: () => _downloadSurat(permohonan.fileSuratTerbitUrl ?? permohonan.fileSuratTerbit),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Top Header Card
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey.shade400, width: 1),
                            ),
                            color: Colors.white,
                            surfaceTintColor: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          permohonan.nomorPermohonan,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                      ),
                                      StatusBadge(
                                        status: permohonan.status,
                                        permohonan: permohonan,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (permohonan.jenisPerizinan != null) ...[
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.description_outlined, size: 18, color: AppTheme.primaryColor),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${permohonan.jenisPerizinan!.kode} - ${permohonan.jenisPerizinan!.nama}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Estimasi Waktu ${permohonan.jenisPerizinan!.estimasiWaktu} Hari',
                                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  
                                  // Data Pemohon
                                  if (permohonan.pemohon != null) ...[
                                    const Text('Data Pemohon', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
                                    const SizedBox(height: 4),
                                    Text('Nama : ${permohonan.pemohon!.name}', style: const TextStyle(fontSize: 11, color: Colors.black87)),
                                    Text('No HP : ${permohonan.pemohon!.phone ?? "-"}', style: const TextStyle(fontSize: 11, color: Colors.black87)),
                                    const SizedBox(height: 12),
                                  ],

                                  if (permohonan.namaPerusahaan != null && permohonan.namaPerusahaan!.isNotEmpty) ...[
                                    const Text('Data Perusahaan / PT', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
                                    const SizedBox(height: 4),
                                    Text('Nama PT : ${permohonan.namaPerusahaan}', style: const TextStyle(fontSize: 11, color: Colors.black87)),
                                    Text('Direktur : ${permohonan.namaDirektur ?? "-"}', style: const TextStyle(fontSize: 11, color: Colors.black87)),
                                    Text('No Hp : ${permohonan.noHpPenanggungJawab ?? "-"}', style: const TextStyle(fontSize: 11, color: Colors.black87)),
                                    const SizedBox(height: 12),
                                  ],
                                  const Text(
                                    'Rencana Kegiatan :',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    (permohonan.rencanaKegiatan != null && permohonan.rencanaKegiatan!.isNotEmpty)
                                        ? permohonan.rencanaKegiatan!
                                        : '-',
                                    style: const TextStyle(fontSize: 11, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 12),
                                  if (permohonan.keterangan != null && permohonan.keterangan!.isNotEmpty && permohonan.keterangan != permohonan.rencanaKegiatan) ...[
                                    const Text(
                                      'Catatan Tambahan (Keterangan):',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      permohonan.keterangan!,
                                      style: const TextStyle(fontSize: 11, color: Colors.black87),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'Diajukan : ${permohonan.tanggalPengajuan != null ? permohonan.tanggalPengajuan!.split('T').first : permohonan.createdAt.split('T').first}',
                                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),


                          // Section Dokumen Persyaratan
                          DokumenSectionWidget(permohonan: permohonan),

                          // Catatan Petugas jika ada
                          if (permohonan.catatanTeknis != null ||
                              permohonan.hasilSurvey != null ||
                              permohonan.catatanPenolakan != null) ...[
                            const SizedBox(height: 16),
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Colors.grey.shade400, width: 1),
                              ),
                              color: Colors.white,
                              surfaceTintColor: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Catatan & Hasil Pemeriksaan Bidang Tata Ruang',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                    const SizedBox(height: 12),
                                    if (permohonan.catatanPenolakan != null)
                                      _buildNoteTile('Catatan Penolakan', permohonan.catatanPenolakan!),
                                    if (permohonan.catatanTeknis != null)
                                      _buildNoteTile('Catatan Analisis Tata Ruang', permohonan.catatanTeknis!),
                                    if (permohonan.hasilSurvey != null)
                                      _buildNoteTile('Hasil Kunjungan Lapangan', permohonan.hasilSurvey!),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),

                          // Timeline Riwayat
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey.shade400, width: 1),
                            ),
                            color: Colors.white,
                            surfaceTintColor: Colors.white,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _isRiwayatExpanded = !_isRiwayatExpanded;
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Riwayat Status Permohonan',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    if (_isRiwayatExpanded) ...[
                                      const SizedBox(height: 12),
                                      StatusTimeline(histories: permohonan.histories),
                                    ],
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          _isRiwayatExpanded ? 'Tutup' : 'Detail',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Icon(
                                          _isRiwayatExpanded ? Icons.expand_less : Icons.chevron_right,
                                          size: 16,
                                          color: Colors.black87,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildNoteTile(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFFFF7043))),
          const SizedBox(height: 2),
          Text(content, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
        ],
      ),
    );
  }
}
