import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/api_exception.dart';
import '../../../models/permohonan_dokumen_model.dart';
import '../../../models/permohonan_model.dart';
import '../../../providers/dokumen_provider.dart';

class DokumenSectionWidget extends StatefulWidget {
  final PermohonanModel permohonan;

  const DokumenSectionWidget({
    super.key,
    required this.permohonan,
  });

  @override
  State<DokumenSectionWidget> createState() => _DokumenSectionWidgetState();
}

class _DokumenSectionWidgetState extends State<DokumenSectionWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DokumenProvider>().fetchDokumen(widget.permohonan.id);
    });
  }

  Future<void> _pickAndUpload(String jenisDokumen) async {
    List<String> extensions = ['pdf']; // default fallback

    final persyaratanList = widget.permohonan.jenisPerizinan?.persyaratan ?? [];
    for (var p in persyaratanList) {
      if (p.nama.toLowerCase().trim() == jenisDokumen.toLowerCase().trim()) {
        if (p.allowedTypes != null && p.allowedTypes!.isNotEmpty) {
          extensions = p.allowedTypes!.split(',').map((e) => e.trim().toLowerCase()).where((e) => e.isNotEmpty).toList();
        } else {
          final lowerReq = p.nama.toLowerCase();
          final isDWGorSHP = lowerReq.contains('dwg') ||
              lowerReq.contains('shp') ||
              lowerReq.contains('kml') ||
              lowerReq.contains('kmz') ||
              lowerReq.contains('polygon');
          
          final isKTP = lowerReq.contains('ktp');
          extensions = isDWGorSHP ? ['dwg', 'dxf', 'shp', 'kml', 'kmz', 'zip', 'rar'] : (isKTP ? ['pdf', 'png', 'jpg', 'jpeg'] : ['pdf']);
        }
        break;
      }
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
      withData: kIsWeb,
    );

    if (result == null || !mounted) return;
    if (result.files.isEmpty) return;

    // Validasi Ekstensi di Dart (karena kita pakai FileType.any)
    bool allValid = true;
    for (var f in result.files) {
      if (f.extension != null && !extensions.contains(f.extension!.toLowerCase())) {
        allValid = false;
        break;
      }
    }

    if (!allValid) {
      if (mounted) context.showApiError(ApiException(message: 'Terdapat file dengan format yang tidak diizinkan. Harap upload file dengan ekstensi: ${extensions.join(", ")}'));
      return;
    }

    int maxMb = widget.permohonan.jenisPerizinan?.maxFileSizeMb ?? 5;
    
    // Cari spesifik maxSizeMb untuk dokumen ini jika ada
    for (var p in persyaratanList) {
      if (p.nama.toLowerCase().trim() == jenisDokumen.toLowerCase().trim()) {
        maxMb = p.maxSizeMb;
        break;
      }
    }

    final provider = context.read<DokumenProvider>();
    int successCount = 0;

    for (var file in result.files) {
      if (file.path == null && file.bytes == null) continue;

      // Validasi Ukuran (Maksimal maxMb MB)
      if (file.size > maxMb * 1024 * 1024) {
        if (mounted) context.showApiError(ApiException(message: 'Ukuran File "${file.name}" Melebihi Batas Maksimal $maxMb MB'));
        continue;
      }

      final success = await provider.uploadDokumen(
        permohonanId: widget.permohonan.id,
        jenisDokumen: jenisDokumen,
        filePath: file.path,
        fileBytes: file.bytes,
        fileName: file.name,
      );

      if (!mounted) return;

      if (success) {
        successCount++;
      } else if (provider.error != null) {
        if (mounted) context.showApiError(ApiException(message: 'Gagal mengupload "${file.name}": ${provider.error!}'));
      }
    }

    if (successCount > 0 && mounted) {
      context.showSuccessMessage('$successCount Dokumen "$jenisDokumen" Berhasil Diupload');  
    }
  }

  Future<void> _onDeleteDokumen(PermohonanDokumenModel dokumen) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Dokumen'),
        content: Text('Apakah Anda Yakin Ingin Menghapus "${dokumen.namaFile}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final provider = context.read<DokumenProvider>();
    final success = await provider.deleteDokumen(
      permohonanId: widget.permohonan.id,
      dokumenId: dokumen.id,
    );

    if (!mounted) return;

    if (success) {
      context.showSuccessMessage('Dokumen Berhasil Dihapus');
    } else if (provider.error != null) {
      context.showApiError(ApiException(message: provider.error!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DokumenProvider>();
    final persyaratan = widget.permohonan.jenisPerizinan?.persyaratan ?? [];
    final uploadedDocs = provider.items;
    final isEditable = widget.permohonan.isEditableByPemohon;

    return Card(
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
                const Text(
                  'Dokumen Persyaratan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                if (provider.isUploading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Format File Yang Diizinkan Sesuai Dengan Aturan Tiap Dokumen\n(Dokumen Lainnya Default Menggunakan PDF)',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Keterangan Status Persyaratan:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF4ADE80)),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text('Hijau: Dokumen sudah diupload', style: TextStyle(fontSize: 11, color: Colors.black87)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.radio_button_unchecked, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text('Abu-abu: Dokumen belum diupload', style: TextStyle(fontSize: 11, color: Colors.black87)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Dynamic Requirements Checklist (✓ uploaded, ○ pending)
            if (persyaratan.isNotEmpty) ...[
              const Text(
                'Daftar Persyaratan Dinamis:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 8),
              ...persyaratan.map((syaratModel) {
                final syarat = syaratModel.nama;
                final isOptional = syaratModel.isOpsional;
                final maxMb = syaratModel.maxSizeMb;
                
                final hasUploaded = uploadedDocs.any(
                  (d) => d.jenisDokumen.toLowerCase().trim() == syarat.toLowerCase().trim(),
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        hasUploaded ? Icons.check_circle_outline : Icons.radio_button_unchecked,
                        size: 20,
                        color: hasUploaded ? const Color(0xFF4ADE80) : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$syarat${isOptional ? " (Opsional)" : " * (Maks. $maxMb MB)"}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: hasUploaded ? const Color(0xFF4ADE80) : Colors.grey,
                          ),
                        ),
                      ),
                      if (isEditable)
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(Icons.upload_file, size: 14),
                          label: const Text('Upload', style: TextStyle(fontSize: 12)),
                          onPressed: () => _pickAndUpload(syarat),
                        ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],

            // Custom Upload Button if required list is empty or additional doc
            if (isEditable)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  foregroundColor: AppTheme.primaryColor,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 42),
                ),
                icon: const Icon(Icons.add_a_photo_outlined, size: 16),
                label: const Text('Upload Dokumen Lainnya', style: TextStyle(fontSize: 13)),
                onPressed: () {
                  _showCustomUploadDialog();
                },
              ),

            const SizedBox(height: 16),
            const Text(
              'Dokumen Yang Sudah Terupload:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 12),

            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (uploadedDocs.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Center(
                  child: Text(
                    'Belum Ada Dokumen Yang Diupload',
                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                ),
              )
            else
              ...uploadedDocs.map((doc) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        doc.isUrl ? Icons.link : (doc.isMapFile ? Icons.map : (doc.isArchive ? Icons.folder_zip : (doc.isPdf ? Icons.picture_as_pdf : Icons.image))),
                        color: doc.isUrl ? Colors.green : (doc.isMapFile ? Colors.orange : (doc.isArchive ? Colors.purple : (doc.isPdf ? Colors.red : Colors.blue))),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc.namaFile,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${doc.jenisDokumen} - ${doc.ukuranReadable}',
                              style: const TextStyle(fontSize: 10, color: Colors.black87),
                            ),
                            if (doc.statusVerifikasi != PermohonanDokumenModel.statusPending) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Verifikasi: ${doc.statusVerifikasi.toUpperCase()}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: doc.statusVerifikasi == PermohonanDokumenModel.statusDiterima
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isEditable)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          onPressed: () => _onDeleteDokumen(doc),
                        ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  void _showCustomUploadDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Dokumen'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nama / Jenis Dokumen',
            hintText: 'Contoh: KTP Pemohon, Sertifikat Tanah',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context);
                _pickAndUpload(name);
              }
            },
            child: const Text('Pilih File'),
          ),
        ],
      ),
    );
  }
}
  