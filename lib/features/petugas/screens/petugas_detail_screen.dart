import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/permohonan_model.dart';
import '../../../providers/petugas_provider.dart';
import '../../pemohon/widgets/status_badge.dart';
import '../widgets/petugas_dialogs.dart';
import '../../../core/utils/api_exception.dart';

class PetugasDetailScreen extends StatefulWidget {
  final int permohonanId;

  const PetugasDetailScreen({super.key, required this.permohonanId});

  @override
  State<PetugasDetailScreen> createState() => _PetugasDetailScreenState();
}

class _PetugasDetailScreenState extends State<PetugasDetailScreen> {
  final TextEditingController _surveyController = TextEditingController();
  final TextEditingController _analisisController = TextEditingController();
  PlatformFile? _selectedPdfFile;
  PlatformFile? _selectedSurveyFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PetugasProvider>().fetchDetail(widget.permohonanId);
    });
  }

  @override
  void dispose() {
    _surveyController.dispose();
    _analisisController.dispose();
    super.dispose();
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    context.showSuccessMessage(message);
    context.read<PetugasProvider>().fetchDetail(widget.permohonanId);
  }

  Future<void> _downloadAndOpenFile(String? urlPath, String fileName) async {
    if (urlPath == null || urlPath.isEmpty) {
      if (mounted) context.showWarningMessage('File Dokumen Belum Diunggah');
      return;
    }

    String finalUrl = urlPath;
    if (finalUrl.contains('localhost')) {
      finalUrl = finalUrl.replaceFirst(RegExp(r'http(s)?://localhost(:\d+)?'), ApiConstants.baseUrl);
    } else if (!finalUrl.startsWith('http')) {
      finalUrl = '${ApiConstants.baseUrl}/storage/' + finalUrl.replaceFirst('public/', '');
    }

    try {
      if (mounted) context.showWarningMessage('Mengunduh Dokumen...');
      final dir = await getTemporaryDirectory();
      final savePath = '${dir.path}/$fileName';
      
      await Dio().download(finalUrl, savePath);
      final result = await OpenFilex.open(savePath);
      
      if (result.type != ResultType.done && mounted) {
        context.showWarningMessage('Tidak Dapat Membuka File: ${result.message}');
      }
    } catch (e) {
      if (mounted) context.showWarningMessage('Gagal Mengunduh: $e');
    }
  }

  void _onSimpanSurvey() {
    if (_surveyController.text.trim().isEmpty) {
      context.showWarningMessage('Isi Hasil Survey Terlebih Dahulu');
      return;
    }

    if (_selectedSurveyFile != null && _selectedSurveyFile!.size > 10 * 1024 * 1024) {
      context.showWarningMessage('Ukuran file PDF maksimal 10MB');
      return;
    }

    context.read<PetugasProvider>().kunjunganLapangan(
      id: widget.permohonanId,
      hasilSurvey: _surveyController.text.trim(),
      filePath: _selectedSurveyFile?.path,
    ).then((success) {
      if (success) {
        _showSuccess('Hasil Survey Berhasil Disimpan');
        setState(() => _selectedSurveyFile = null);
      }
    });
  }

  void _onTerbitSurat() {
    if (_selectedPdfFile == null || _selectedPdfFile!.path == null) {
      context.showWarningMessage('Pilih File PDF Surat Terbit Terlebih Dahulu');
      return;
    }
    context.read<PetugasProvider>().terbit(
      id: widget.permohonanId,
      filePath: _selectedPdfFile!.path!,
    ).then((success) {
      if (success) {
        _showSuccess('Surat Perizinan Berhasil Diterbitkan!');
        context.pop();
      }
    });
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Widget? extraWidget, bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          ),
          const Text(':', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E293B))),
                if (extraWidget != null) ...[
                  const SizedBox(height: 6),
                  extraWidget,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPemohon(PermohonanModel p) {
    return _buildSectionCard(
      title: 'Informasi Pemohon',
      icon: Icons.person_outline_rounded,
      children: [
        _buildInfoRow('Nama', p.pemohon?.name ?? "-"),
        _buildInfoRow(
          'No. HP',
          p.pemohon?.phone ?? "-",
          extraWidget: (p.pemohon?.phone != null && p.pemohon!.phone!.isNotEmpty)
              ? _buildWhatsAppBtn(p.pemohon!.phone!)
              : null,
        ),
        if (p.namaPerusahaan != null && p.namaPerusahaan!.isNotEmpty)
          _buildInfoRow('Perusahaan', p.namaPerusahaan!),
        if (p.namaDirektur != null && p.namaDirektur!.isNotEmpty)
          _buildInfoRow('Direktur', p.namaDirektur!),
        if (p.noHpPenanggungJawab != null && p.noHpPenanggungJawab!.isNotEmpty)
          _buildInfoRow(
            'No HP Direktur',
            p.noHpPenanggungJawab!,
            extraWidget: _buildWhatsAppBtn(p.noHpPenanggungJawab!),
            isLast: true,
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }

  String _formatLuasArea(String? luas) {
    if (luas == null || luas.isEmpty) return "-";
    final intVal = int.tryParse(luas.replaceAll(RegExp(r'\D'), ''));
    if (intVal == null) return '$luas m²';
    final formatted = intVal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return '$formatted m²';
  }

  Widget _buildDataTeknis(PermohonanModel p) {
    return _buildSectionCard(
      title: 'Data Teknis',
      icon: Icons.home_work_outlined,
      children: [
        _buildInfoRow('Layanan', p.jenisPerizinan?.nama ?? "-"),
        _buildInfoRow('Rencana', p.rencanaKegiatan ?? "-"),
        _buildInfoRow('Luas Lahan', _formatLuasArea(p.luasArea)),
        _buildInfoRow('Keterangan', (p.keterangan != null && p.keterangan!.isNotEmpty) ? p.keterangan! : "-", isLast: true),
      ],
    );
  }

  Widget _buildWhatsAppBtn(String phoneStr) {
    return ElevatedButton.icon(
      onPressed: () async {
        String phone = phoneStr.replaceAll(RegExp(r'\D'), '');
        if (phone.startsWith('0')) phone = '62${phone.substring(1)}';
        final Uri url = Uri.parse('https://wa.me/$phone');
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          if (mounted) context.showWarningMessage('Tidak Dapat Membuka WhatsApp');
        }
      },
      icon: const Icon(Icons.chat_outlined, size: 14),
      label: const Text('Hubungi', style: TextStyle(fontSize: 11)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF25D366),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        minimumSize: const Size(0, 26),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  Widget _buildDokumenSection(PermohonanModel p) {
    return _buildSectionCard(
      title: 'Dokumen Persyaratan',
      icon: Icons.folder_outlined,
      children: [
        if (p.dokumen.isEmpty)
          const Text('Belum ada dokumen yang diunggah', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
        else
          ...p.dokumen.map((doc) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (doc.isUrl ? Colors.green : (doc.isMapFile ? Colors.orange : (doc.isArchive ? Colors.purple : (doc.isPdf ? Colors.red : Colors.blue)))).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        doc.isUrl ? Icons.link : (doc.isMapFile ? Icons.map : (doc.isArchive ? Icons.folder_zip : (doc.isPdf ? Icons.picture_as_pdf : Icons.image))),
                        color: doc.isUrl ? Colors.green : (doc.isMapFile ? Colors.orange : (doc.isArchive ? Colors.purple : (doc.isPdf ? Colors.red : Colors.blue))),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doc.jenisDokumen, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                          const SizedBox(height: 2),
                          Text(doc.namaFile, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(doc.isUrl ? Icons.open_in_new_rounded : Icons.download_rounded, color: AppTheme.primaryColor),
                      onPressed: () async {
                        if (doc.isUrl) {
                          if (doc.filePath.isNotEmpty) {
                            final Uri url = Uri.parse(doc.filePath);
                            if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                              if (context.mounted) context.showWarningMessage('Tidak Dapat Membuka Link');
                            }
                          } else {
                            if (context.mounted) context.showWarningMessage('Link Dokumen Kosong');
                          }
                        } else {
                          _downloadAndOpenFile(doc.filePath, doc.namaFile);
                        }
                      },
                      tooltip: doc.isUrl ? 'Buka Tautan' : 'Unduh',
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  Widget _buildBody(PetugasProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final p = provider.selectedPermohonan;
    if (provider.error != null && p == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(provider.error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => provider.fetchDetail(widget.permohonanId),
              child: const Text('Muat Ulang Data'),
            ),
          ],
        ),
      );
    }

    if (p == null || p.id != widget.permohonanId) {
      return const Center(child: CircularProgressIndicator());
    }

    // Tentukan langkah Stepper saat ini
    int currentStep = 0;
    if (p.status == PermohonanModel.statusDiajukan || p.status == PermohonanModel.statusDalamValidasiKelengkapan) {
      currentStep = 0;
    } else if (p.status == PermohonanModel.statusPerluKunjunganLapangan) {
      currentStep = 1;
    } else if (p.status == PermohonanModel.statusDalamAnalisis) {
      currentStep = 2;
    } else if (p.status == PermohonanModel.statusTerbit || p.status == PermohonanModel.statusSiapTerbit) {
      currentStep = 3;
    } else if (p.status == PermohonanModel.statusDitolakPermanen || p.status == PermohonanModel.statusPerluRevisi) {
      if (p.fieldBermasalah.contains('Analisis Kesesuaian')) {
        currentStep = 2;
      } else {
        currentStep = 0;
      }
    }

    bool isSiteplan = (p.jenisPerizinan?.kode ?? '').toUpperCase() == 'SITEPLAN';
    bool hideKunjungan = !isSiteplan && currentStep != 1 && (p.hasilSurvey == null || p.hasilSurvey!.isEmpty);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoPemohon(p),
                _buildDataTeknis(p),
                _buildDokumenSection(p),
                const SizedBox(height: 16),
                const Text('Alur Kerja Petugas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                const SizedBox(height: 8),
        
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Stepper(
            physics: const ClampingScrollPhysics(),
            currentStep: currentStep,
            controlsBuilder: (context, details) => const SizedBox.shrink(),
            steps: [
              // ----------------------------------------------------
              // STEP 1: VALIDASI KELENGKAPAN
              // ----------------------------------------------------
              Step(
                title: const Text('Validasi Administrasi', style: TextStyle(fontWeight: FontWeight.bold)),
                isActive: currentStep >= 0,
                state: currentStep > 0 ? StepState.complete : (p.status == PermohonanModel.statusPerluRevisi || p.status == PermohonanModel.statusDitolakPermanen ? StepState.error : StepState.indexed),
                content: currentStep == 0 && (p.status == PermohonanModel.statusDiajukan || p.status == PermohonanModel.statusDalamValidasiKelengkapan)
                    ? Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.start,
                        children: [
                          if (p.percobaanRevisi == 0)
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
                              onPressed: provider.isActionLoading ? null : () => PetugasDialogs.showTolakKelengkapanDialog(
                                context: context,
                                permohonan: p,
                                jenisPenolakan: 'revisi',
                                onSuccess: () => _showSuccess('Permintaan Revisi Berhasil'),
                              ),
                              child: const Text('REVISI', style: TextStyle(fontSize: 12)),
                            ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                            onPressed: provider.isActionLoading ? null : () => PetugasDialogs.showTolakKelengkapanDialog(
                              context: context,
                              permohonan: p,
                              jenisPenolakan: 'permanen',
                              onSuccess: () => _showSuccess('Permohonan Berhasil Ditolak'),
                            ),
                            child: const Text('TOLAK', style: TextStyle(fontSize: 12)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                            onPressed: provider.isActionLoading ? null : () => PetugasDialogs.showAccKelengkapanDialog(
                              context: context,
                              permohonan: p,
                              onSuccess: () => _showSuccess('Berkas di-ACC. Lanjut ke Tahap Berikutnya.'),
                            ),
                            child: const Text('ACC BERKAS'),
                          ),
                        ],
                      )
                    : Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          (currentStep == 0 && p.status == PermohonanModel.statusPerluRevisi)
                              ? 'Perlu Revisi: ${p.catatanPenolakan ?? "-"}${p.batasWaktuRevisi != null ? "\nBatas Waktu: ${DateTime.parse(p.batasWaktuRevisi!).toLocal().toString().split('.')[0]}" : ""}'
                              : (currentStep == 0 && p.status == PermohonanModel.statusDitolakPermanen)
                                  ? 'Ditolak Permanen: ${p.catatanPenolakan ?? "-"}'
                                  : 'Validasi Kelengkapan Telah Selesai.',
                          style: TextStyle(
                            color: (currentStep == 0 && p.status == PermohonanModel.statusPerluRevisi)
                                ? Colors.orange
                                : (currentStep == 0 && p.status == PermohonanModel.statusDitolakPermanen)
                                    ? Colors.red
                                    : Colors.grey,
                          ),
                        ),
                      ),
              ),

              // ----------------------------------------------------
              // STEP 2: KUNJUNGAN LAPANGAN
              // ----------------------------------------------------
              Step(
                title: const Text('Kunjungan Lapangan', style: TextStyle(fontWeight: FontWeight.bold)),
                isActive: currentStep >= 1,
                state: hideKunjungan ? StepState.complete : (currentStep > 1 ? StepState.complete : StepState.indexed),
                content: hideKunjungan 
                    ? Container(
                        alignment: Alignment.centerLeft,
                        child: const Text('Kunjungan Lapangan Tidak Diperlukan.', style: TextStyle(color: Colors.grey)),
                      )
                    : (currentStep == 1
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (p.hasilSurvey != null && p.hasilSurvey!.isNotEmpty) ...[
                              Text('Hasil Survey Terdaftar: ${p.hasilSurvey}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                            ],
                            TextField(
                              controller: _surveyController,
                              decoration: const InputDecoration(hintText: 'Isi Hasil Kunjungan Lapangan...', border: OutlineInputBorder()),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedSurveyFile?.name ?? 'Belum Memilih File PDF (Max 10MB)',
                                    style: TextStyle(
                                      fontWeight: _selectedSurveyFile != null ? FontWeight.bold : FontWeight.normal,
                                      color: _selectedSurveyFile != null ? Colors.black : Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.attach_file, size: 16),
                                  label: const Text('Pilih PDF', style: TextStyle(fontSize: 12)),
                                  onPressed: () async {
                                    final res = await FilePicker.platform.pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions: ['pdf'],
                                    );
                                    if (res != null) {
                                      setState(() => _selectedSurveyFile = res.files.single);
                                    }
                                  },
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFACC15),
                                foregroundColor: Colors.black,
                                minimumSize: const Size.fromHeight(40)
                              ),
                              onPressed: provider.isActionLoading ? null : _onSimpanSurvey,
                              child: const Text('Simpan Hasil Survey', style: TextStyle(fontWeight: FontWeight.bold)),
                            )
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hasil Survey: ${p.hasilSurvey ?? "-"}', style: const TextStyle(color: Colors.grey)),
                            if (p.fileHasilSurvey != null && p.fileHasilSurvey!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.download, size: 16),
                                label: const Text('Unduh File Survey', style: TextStyle(fontSize: 12)),
                                onPressed: () => _downloadAndOpenFile(p.fileHasilSurvey, 'Hasil_Survey_${p.nomorPermohonan}.pdf'),
                              )
                            ]
                          ],
                        )),
                ),

              // ----------------------------------------------------
              // STEP 3: ANALISIS TATA RUANG
              // ----------------------------------------------------
              Step(
                title: const Text('Analisis Kesesuaian', style: TextStyle(fontWeight: FontWeight.bold)),
                isActive: currentStep >= 2,
                state: (currentStep == 2 && (p.status == PermohonanModel.statusPerluRevisi || p.status == PermohonanModel.statusDitolakPermanen)) ? StepState.error : (currentStep > 2 ? StepState.complete : StepState.indexed),
                content: (currentStep == 2 && p.status == PermohonanModel.statusDalamAnalisis)
                    ? Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.start,
                        children: [
                          if (p.percobaanRevisi == 0)
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
                              onPressed: provider.isActionLoading ? null : () => PetugasDialogs.showTolakAnalisisDialog(
                                context: context,
                                permohonan: p,
                                jenisPenolakan: 'revisi',
                                onSuccess: () => _showSuccess('Permintaan Revisi Berhasil'),
                              ),
                              child: const Text('REVISI', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                            ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                            onPressed: provider.isActionLoading ? null : () => PetugasDialogs.showTolakAnalisisDialog(
                              context: context,
                              permohonan: p,
                              jenisPenolakan: 'permanen',
                              onSuccess: () => _showSuccess('Permohonan Berhasil Ditolak'),
                            ),
                            child: const Text('TOLAK', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                            onPressed: provider.isActionLoading ? null : () {
                              context.read<PetugasProvider>().analisis(
                                id: widget.permohonanId,
                                keputusan: 'acc',
                                catatan: '',
                              ).then((success) {
                                if (success) _showSuccess('Analisis di-ACC. Menunggu Penerbitan.');
                              });
                            },
                            child: const Text('ACC ANALISIS'),
                          ),
                        ],
                      )
                    : Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          (currentStep == 2 && p.status == PermohonanModel.statusPerluRevisi)
                              ? 'Perlu Revisi: ${p.catatanPenolakan ?? "-"}${p.batasWaktuRevisi != null ? "\nBatas Waktu: ${DateTime.parse(p.batasWaktuRevisi!).toLocal().toString().split('.')[0]}" : ""}'
                              : (currentStep == 2 && p.status == PermohonanModel.statusDitolakPermanen)
                                  ? 'Ditolak Permanen: ${p.catatanPenolakan ?? "-"}'
                                  : (currentStep > 2 ? 'Analisis Disetujui.' : 'Menunggu Tahap Sebelumnya.'),
                          style: TextStyle(
                            color: (currentStep == 2 && p.status == PermohonanModel.statusPerluRevisi)
                                ? Colors.orange
                                : (currentStep == 2 && p.status == PermohonanModel.statusDitolakPermanen)
                                    ? Colors.red
                                    : Colors.grey,
                          ),
                        ),
                      ),
              ),

              // ----------------------------------------------------
              // STEP 4: PENERBITAN SURAT
              // ----------------------------------------------------
              Step(
                title: const Text('Penerbitan Surat', style: TextStyle(fontWeight: FontWeight.bold)),
                isActive: currentStep >= 3,
                state: currentStep == 3 && p.status == PermohonanModel.statusTerbit ? StepState.complete : StepState.indexed,
                content: currentStep == 3
                    ? (p.status == PermohonanModel.statusTerbit
                        ? const Text('Surat Perizinan Telah Diterbitkan.', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(_selectedPdfFile?.name ?? 'Belum Memilih File PDF Surat', style: const TextStyle(fontWeight: FontWeight.bold))),
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.attach_file),
                                    label: const Text('Pilih PDF'),
                                    onPressed: () async {
                                      final res = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                                      if (res != null) setState(() => _selectedPdfFile = res.files.single);
                                    },
                                  )
                                ],
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(40)),
                                onPressed: provider.isActionLoading ? null : _onTerbitSurat,
                                child: const Text('TERBITKAN SURAT'),
                              )
                            ],
                          ))
                    : Container(
                        alignment: Alignment.centerLeft,
                        child: const Text('Menunggu Tahap Sebelumnya.', style: TextStyle(color: Colors.grey)),
                      ),
              ),
            ],
          ),
        ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PetugasProvider>();
    final permohonan = provider.selectedPermohonan;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              backgroundColor: AppTheme.primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 48, bottom: 16, right: 48),
                title: Text(
                  permohonan != null ? 'Proses: ${permohonan.nomorPermohonan}' : 'Detail Permohonan',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: AppTheme.primaryColor),
                    if (permohonan != null)
                      Positioned(
                        right: 16,
                        top: 60,
                        child: StatusBadge(status: permohonan.status, permohonan: permohonan),
                      ),
                  ],
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              actions: [
                if (provider.isActionLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))),
                  )
              ],
            ),
          ];
        },
        body: _buildBody(provider),
      ),
    );
  }
}
