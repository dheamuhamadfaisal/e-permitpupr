import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/api_exception.dart';
import '../../../providers/permohonan_provider.dart';
import '../widgets/dokumen_section_widget.dart';
import '../widgets/status_badge.dart';
import '../widgets/status_timeline.dart';

class DetailPermohonanScreen extends StatefulWidget {
  final int permohonanId;

  const DetailPermohonanScreen({
    super.key,
    required this.permohonanId,
  });

  @override
  State<DetailPermohonanScreen> createState() => _DetailPermohonanScreenState();
}

class _DetailPermohonanScreenState extends State<DetailPermohonanScreen> {
  bool _isRiwayatExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PermohonanProvider>().fetchDetail(widget.permohonanId);
    });
  }

  Future<void> _onAjukan() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pengajuan'),
        content: const Text(
          'Apakah Anda Yakin Ingin Mengajukan Permohonan Ini ke Bidang Tata Ruang PUPR Garut?'
          '\n\nSetelah Diajukan, Status Akan Berubah Menjadi DIAJUKAN.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Ajukan', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final provider = context.read<PermohonanProvider>();
    final success = await provider.ajukanPermohonan(widget.permohonanId);

    if (!mounted) return;

    if (success) {
      context.showSuccessMessage('Permohonan Berhasil Diajukan ke Bidang Tata Ruang!');
      provider.fetchDetail(widget.permohonanId);
    } else if (provider.error != null) {
      context.showApiError(ApiException(message: provider.error!));
    }
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
    final provider = context.watch<PermohonanProvider>();
    final permohonan = provider.selectedPermohonan;

    return Scaffold(
      appBar: AppBar(
        title: Text(permohonan?.nomorPermohonan ?? 'Detail Permohonan'),
        actions: [],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(provider.error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => provider.fetchDetail(widget.permohonanId),
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
                          // BANNER PERLU REVISI (PERCOBAAN 1 - TERAKHIR)
                          if (permohonan.isPerluRevisi) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFF97316), width: 1.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.warning_amber_rounded, color: Color(0xFFC2410C), size: 24),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'PERINGATAN: KESEMPATAN REVISI TERAKHIR',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFC2410C),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Ini adalah kesempatan terakhir Anda untuk memperbaiki permohonan ini. '
                                    'Jika ditolak kembali pada tahap berikutnya, permohonan ini akan DITOLAK PERMANEN dan Anda harus mengajukan permohonan baru.',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF9A3412), height: 1.3),
                                  ),
                                  if (permohonan.batasWaktuRevisi != null) ...[
                                    const SizedBox(height: 10),
                                    Text(
                                      'Batas Waktu Perbaikan: ${DateTime.parse(permohonan.batasWaktuRevisi!).toLocal().toString().split(".")[0]}',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF9A3412)),
                                    ),
                                  ],
                                  if (permohonan.catatanPenolakan != null) ...[
                                    const SizedBox(height: 10),
                                    Text(
                                      'Catatan Penolakan Validator: ${permohonan.catatanPenolakan}',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF7C2D12)),
                                    ),
                                  ],
                                  if (permohonan.fieldBermasalah.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: permohonan.fieldBermasalah.map((f) {
                                        return Chip(
                                          label: Text('Field: $f', style: const TextStyle(fontSize: 11, color: Colors.white)),
                                          backgroundColor: const Color(0xFFEA580C),
                                          visualDensity: VisualDensity.compact,
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // BANNER DITOLAK PERMANEN (PERCOBAAN 2)
                          if (permohonan.isDitolakPermanen) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.cancel_outlined, color: Color(0xFFDC2626), size: 24),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'PERMOHONAN DITOLAK PERMANEN',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFDC2626),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Permohonan ini telah ditolak secara permanen. Token permohonan ini dikunci dan tidak dapat diubah lagi.',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF991B1B), height: 1.3),
                                  ),
                                  if (permohonan.catatanPenolakan != null) ...[
                                    const SizedBox(height: 10),
                                    Text(
                                      'Alasan Penolakan Akhir: ${permohonan.catatanPenolakan}',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF7F1D1D)),
                                    ),
                                  ],
                                  if (permohonan.fieldBermasalah.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    const Text('Dokumen Yang Bermasalah:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF7F1D1D))),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: permohonan.fieldBermasalah.map((f) {
                                        return Chip(
                                          label: Text(f, style: const TextStyle(fontSize: 11, color: Colors.white)),
                                          backgroundColor: const Color(0xFFDC2626),
                                          visualDensity: VisualDensity.compact,
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

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
                                    'Selamat! Permohonan Anda telah disetujui dan Surat Perizinan Resmi telah diterbitkan oleh Bidang Tata Ruang PUPR Garut.',
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
                                  if (permohonan.namaPerusahaan != null && permohonan.namaPerusahaan!.isNotEmpty) ...[
                                    const Text('Data Perusahaan / PT', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
                                    const SizedBox(height: 4),
                                    Text('Nama PT : ${permohonan.namaPerusahaan}', style: const TextStyle(fontSize: 11, color: Colors.black87)),
                                    Text('Direktur : ${permohonan.namaDirektur ?? "-"}', style: const TextStyle(fontSize: 11, color: Colors.black87)),
                                    Text('No Hp : ${permohonan.noHpPenanggungJawab ?? "-"}', style: const TextStyle(fontSize: 11, color: Colors.black87)),
                                    const SizedBox(height: 12),
                                  ],
                                  const Text(
                                    'Rencana Bangunan :',
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

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),

      // Bottom Bar Action untuk Status Draft / Perlu Revisi / Ditolak Permanen
      bottomSheet: permohonan != null
          ? (permohonan.isEditableByPemohon
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            side: const BorderSide(color: AppTheme.primaryColor),
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: Text(permohonan.isPerluRevisi ? 'Perbaiki Permohonan' : 'Edit Draft'),
                          onPressed: () => context.push('/permohonan/${permohonan.id}/edit', extra: permohonan),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.goldColor,
                            foregroundColor: AppTheme.primaryColor,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          icon: const Icon(Icons.send_outlined, size: 18),
                          label: const Text('Ajukan', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: provider.isActionLoading ? null : _onAjukan,
                        ),
                      ),
                    ],
                  ),
                )
              : permohonan.isDitolakPermanen
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, -3),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        label: const Text('Ajukan Permohonan Baru', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () => context.push('/permohonan/create'),
                      ),
                    )
                  : null)
          : null,
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
