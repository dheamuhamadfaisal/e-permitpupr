import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/api_exception.dart';
import '../../../models/jenis_perizinan_model.dart';
import '../../../models/permohonan_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/dokumen_provider.dart';
import '../../../providers/jenis_perizinan_provider.dart';
import '../../../providers/permohonan_provider.dart';
import '../../../services/permohonan_service.dart';
import '../../../widgets/loading_button.dart';

class CreatePermohonanScreen extends StatefulWidget {
  final String? initialKode;
  final PermohonanModel? draft;

  const CreatePermohonanScreen({
    super.key,
    this.initialKode,
    this.draft,
  });

  @override
  State<CreatePermohonanScreen> createState() => _CreatePermohonanScreenState();
}

class _CreatePermohonanScreenState extends State<CreatePermohonanScreen> {
  int _currentStep = 1;
  JenisPerizinanModel? _selectedJenis;

  String _tipePemohon = 'Individu / Perorangan';

  final _namaPerusahaanController = TextEditingController();
  final _namaDirekturController = TextEditingController();
  final _noHpPenanggungJawabController = TextEditingController();
  final _rencanaKegiatanController = TextEditingController();
  final _alamatLengkapController = TextEditingController();
  final _luasAreaController = TextEditingController();
  final _keteranganController = TextEditingController();

  final _formKeyDetail = GlobalKey<FormState>();

  // Map of temporary picked files: { jenis_dokumen: PlatformFile }
  final Map<String, PlatformFile> _pickedFiles = {};

  // Map of temporary provided links: { jenis_dokumen: String url }
  final Map<String, String> _pickedLinks = {};

  // Existing documents for draft mode
  final Map<String, String> _existingDokumen = {};

  // Checkbox alamat lokasi sama dengan profil
  bool _samaDenganAlamatProfil = false;
  String _previousCustomAlamat = '';

  // Siteplan Prerequisite KRK Terbit state
  List<PermohonanModel> _myKrkTerbitList = [];
  int? _selectedKrkTerkaitId;
  bool _isLoadingKrkTerbit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<JenisPerizinanProvider>();
      await provider.fetchJenisPerizinan();

      if (widget.draft != null && provider.activeItems.isNotEmpty) {
        _initializeFromDraft(widget.draft!, provider);
      } else if (widget.initialKode != null && provider.activeItems.isNotEmpty) {
        final match = provider.activeItems.firstWhere(
          (j) => j.kode.toUpperCase() == widget.initialKode!.toUpperCase(),
          orElse: () => provider.activeItems.first,
        );
        setState(() {
          _selectedJenis = match;
          _currentStep = 1;
        });
        if (match.kode.toUpperCase() == 'SITEPLAN') {
          _fetchMyKrkTerbitList();
        }
      } else if (provider.activeItems.isNotEmpty) {
        setState(() {
          _selectedJenis = provider.activeItems.first;
          _currentStep = 0;
        });
      }
    });
  }

  void _initializeFromDraft(PermohonanModel draft, JenisPerizinanProvider provider) {
    final match = provider.activeItems.firstWhere(
      (j) => j.id == draft.jenisPerizinanId,
      orElse: () => provider.activeItems.first,
    );

    setState(() {
      _selectedJenis = match;
      _currentStep = 1;
      
      if (draft.namaPerusahaan != null && draft.namaPerusahaan!.isNotEmpty) {
        _tipePemohon = 'Perusahaan / PT';
      } else {
        _tipePemohon = 'Individu / Perorangan';
      }
      _namaPerusahaanController.text = draft.namaPerusahaan ?? '';
      _namaDirekturController.text = draft.namaDirektur ?? '';
      _noHpPenanggungJawabController.text = draft.noHpPenanggungJawab ?? '';
      _rencanaKegiatanController.text = draft.rencanaKegiatan ?? '';
      _alamatLengkapController.text = draft.alamatLengkap ?? '';
      _luasAreaController.text = draft.luasArea ?? '';
      _keteranganController.text = draft.keterangan ?? '';

      final user = context.read<AuthProvider>().user;
      final alamatProfil = user?.alamat?.trim() ?? '';
      if (draft.alamatLengkap != null &&
          draft.alamatLengkap!.trim().isNotEmpty &&
          alamatProfil.isNotEmpty &&
          draft.alamatLengkap!.trim() == alamatProfil) {
        _samaDenganAlamatProfil = true;
      }
    });

    _fetchExistingDokumen(draft.id);

    if (match.kode.toUpperCase() == 'SITEPLAN') {
      _selectedKrkTerkaitId = draft.krkTerkaitId;
      _fetchMyKrkTerbitList();
    }
  }

  void _toggleSamaDenganProfil(bool value) {
    final user = context.read<AuthProvider>().user;
    final alamatProfil = user?.alamat?.trim() ?? '';

    if (value) {
      if (alamatProfil.isEmpty || alamatProfil == '-') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Alamat di profil Anda belum diatur. Silakan lengkapi profil terlebih dahulu atau ketik alamat secara manual.',
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _samaDenganAlamatProfil = false;
        });
        return;
      }

      setState(() {
        _previousCustomAlamat = _alamatLengkapController.text;
        _samaDenganAlamatProfil = true;
        _alamatLengkapController.text = alamatProfil;
      });
    } else {
      setState(() {
        _samaDenganAlamatProfil = false;
        _alamatLengkapController.text = _previousCustomAlamat;
      });
    }
  }

  Future<void> _fetchExistingDokumen(int permohonanId) async {
    final dokumenProvider = context.read<DokumenProvider>();
    await dokumenProvider.fetchDokumen(permohonanId);
    if (!mounted) return;
    setState(() {
      for (final doc in dokumenProvider.items) {
        _existingDokumen[doc.jenisDokumen] = doc.filePath;
        if (doc.isUrl ||
            doc.filePath.startsWith('http://') ||
            doc.filePath.startsWith('https://')) {
          _pickedLinks[doc.jenisDokumen] = doc.filePath;
        }
      }
    });
  }

  Future<void> _fetchMyKrkTerbitList() async {
    setState(() => _isLoadingKrkTerbit = true);
    try {
      final list = await PermohonanService().getMyKrkTerbitList();
      setState(() {
        _myKrkTerbitList = list;
        if (list.isNotEmpty) {
          _selectedKrkTerkaitId = list.first.id;
        }
      });
    } catch (_) {
    } finally {
      setState(() => _isLoadingKrkTerbit = false);
    }
  }

  @override
  void dispose() {
    _namaPerusahaanController.dispose();
    _namaDirekturController.dispose();
    _noHpPenanggungJawabController.dispose();
    _rencanaKegiatanController.dispose();
    _alamatLengkapController.dispose();
    _luasAreaController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _pickFileForRequirement(PersyaratanModel requirement) async {
    List<String> extensions = ['pdf']; // default fallback
    final lowerReq = requirement.nama.toLowerCase();
    final isKTP = lowerReq.contains('ktp');
    
    if (requirement.allowedTypes != null && requirement.allowedTypes!.isNotEmpty) {
      extensions = requirement.allowedTypes!.split(',').map((e) => e.trim().toLowerCase()).where((e) => e.isNotEmpty).toList();
    } else {
      // Fallback legacy logic
      final isDWGorSHP = lowerReq.contains('dwg') ||
          lowerReq.contains('shp') ||
          lowerReq.contains('kml') ||
          lowerReq.contains('kmz') ||
          lowerReq.contains('polygon');
      
      extensions = isDWGorSHP ? ['dwg', 'dxf', 'shp', 'kml', 'kmz', 'zip', 'rar'] : (isKTP ? ['pdf', 'png', 'jpg', 'jpeg'] : ['pdf']);
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Gunakan 'any' agar intent OS Android tidak gagal membuka picker untuk ekstensi khusus
        withData: kIsWeb,
      );

      if (result != null && (result.files.single.path != null || result.files.single.bytes != null)) {
        final file = result.files.single;
        
        // Manual Extension Validation
        if (extensions.isNotEmpty) {
          final fileExt = file.extension?.toLowerCase() ?? '';
          if (!extensions.contains(fileExt)) {
            if (!mounted) return;
            context.showApiError(ApiException(message: 'Format File Tidak Valid. Harap Upload File dengan Format: ${extensions.join(', ')}'));
            return;
          }
        }

        final int maxMb = requirement.maxSizeMb;
        final int maxBytes = maxMb * 1024 * 1024;

        if (file.size > maxBytes) {
          if (!mounted) return;
          context.showApiError(ApiException(message: 'Ukuran File Maksimal $maxMb MB untuk ${isKTP ? "Foto KTP" : "Dokumen Ini"}'));
          return;
        }
        setState(() {
          _pickedFiles[requirement.nama] = file;
        });
      }
    } catch (e) {
      if (!mounted) return;
      context.showApiError(ApiException(message: 'Gagal membuka penjelajah file. Pastikan izin akses penyimpanan diberikan.'));
    }
  }

  String _normalizeUrl(String input) {
    var trimmed = input.trim();
    if (trimmed.isEmpty) return trimmed;
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      trimmed = 'https://$trimmed';
    }
    return trimmed;
  }

  bool _isLikelyFilename(String text) {
    final lower = text.toLowerCase().trim();
    if (!lower.contains('/')) {
      return lower.endsWith('.pdf') ||
          lower.endsWith('.png') ||
          lower.endsWith('.jpg') ||
          lower.endsWith('.jpeg') ||
          lower.endsWith('.dwg') ||
          lower.endsWith('.shp') ||
          lower.endsWith('.zip') ||
          lower.endsWith('.rar') ||
          lower.endsWith('.kml') ||
          lower.endsWith('.kmz');
    }
    return false;
  }

  bool _isValidUrl(String? input) {
    if (input == null || input.trim().isEmpty) return false;
    final trimmed = input.trim();

    // Jika yang dimasukkan hanya nama file tanpa URL/protokol
    if (_isLikelyFilename(trimmed) &&
        !trimmed.startsWith('http://') &&
        !trimmed.startsWith('https://')) {
      return false;
    }

    final normalized = _normalizeUrl(trimmed);
    final uri = Uri.tryParse(normalized);
    if (uri == null) return false;
    if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) return false;
    if (uri.host.isEmpty || !uri.host.contains('.')) return false;
    if (uri.host.contains(' ')) return false;

    final parts = uri.host.split('.');
    if (parts.last.length < 2) return false;

    return true;
  }

  bool _doesRequirementProvideLink(PersyaratanModel syarat) {
    final lowerSyarat = syarat.nama.toLowerCase();
    final isDWG = lowerSyarat.contains('dwg') ||
        lowerSyarat.contains('site plan') ||
        lowerSyarat.contains('siteplan');
    final isAndalalin = lowerSyarat.contains('andalalin');
    final isPolygon = lowerSyarat.contains('polygon') ||
        lowerSyarat.contains('kml') ||
        lowerSyarat.contains('shp') ||
        lowerSyarat.contains('kmz');
    return syarat.allowLink || isDWG || isAndalalin || isPolygon;
  }

  bool _validateMandatoryDocuments() {
    if (_selectedJenis == null) return false;

    final missingMandatoryFiles = <String>[];
    final invalidLinks = <String>[];

    for (final req in _selectedJenis!.persyaratan) {
      final isOptional = req.isOpsional;
      final providesLink = _doesRequirementProvideLink(req);

      final hasFile = _pickedFiles.containsKey(req.nama);
      final rawLink = _pickedLinks[req.nama]?.trim() ?? '';
      final hasLink = rawLink.isNotEmpty;
      final hasExisting = _existingDokumen.containsKey(req.nama);

      if (providesLink) {
        // Link selalu opsional, tapi kalau diisi HARUS link valid yang bisa dibuka
        if (hasLink && !_isValidUrl(rawLink)) {
          invalidLinks.add('${req.nama} (Bukan link URL yang valid — pastikan link bisa diakses)');
        }
        // Untuk dokumen wajib tanpa link: tetap boleh upload file saja
        if (!isOptional && !hasFile && !hasLink && !hasExisting) {
          missingMandatoryFiles.add(req.nama);
        }
      } else {
        // Dokumen biasa (wajib upload file berkas)
        if (!isOptional && !hasFile && !hasExisting) {
          missingMandatoryFiles.add(req.nama);
        }
      }
    }

    final errors = <String>[];
    if (invalidLinks.isNotEmpty) {
      errors.add(
        'Link yang diisi tidak valid. Pastikan menggunakan URL lengkap yang bisa diakses (contoh: https://drive.google.com/...):\n• ${invalidLinks.join('\n• ')}',
      );
    }
    if (missingMandatoryFiles.isNotEmpty) {
      errors.add(
        'Silakan Upload Berkas Dokumen Wajib Berikut Sebelum Melanjutkan:\n• ${missingMandatoryFiles.join('\n• ')}',
      );
    }

    if (errors.isNotEmpty) {
      context.showApiError(
        ApiException(
          message: errors.join('\n\n'),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _onSubmitPermohonan() async {
    if (_selectedJenis == null) return;
    if (!_validateMandatoryDocuments()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memproses Permohonan...', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text('Sedang Mengunggah Dokumen,\nMohon Tunggu.', style: TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );

    final provider = context.read<PermohonanProvider>();
    final dokumenProvider = context.read<DokumenProvider>();

    int? currentId = widget.draft?.id;
    bool actionSuccess = false;

    if (currentId == null) {
      final created = await provider.createPermohonan(
        jenisPerizinanId: _selectedJenis!.id,
        krkTerkaitId: _selectedKrkTerkaitId,
        namaPerusahaan: _tipePemohon == 'Perusahaan / PT' ? _namaPerusahaanController.text.trim() : null,
        namaDirektur: _tipePemohon == 'Perusahaan / PT' ? _namaDirekturController.text.trim() : null,
        noHpPenanggungJawab: _tipePemohon == 'Perusahaan / PT' ? _noHpPenanggungJawabController.text.trim() : null,
        rencanaKegiatan: _rencanaKegiatanController.text.trim(),
        alamatLengkap: _alamatLengkapController.text.trim(),
        luasArea: _luasAreaController.text.trim(),
        keterangan: _keteranganController.text.trim(),
      );
      if (created != null) {
        currentId = created.id;
        actionSuccess = true;
      }
    } else {
      actionSuccess = await provider.updatePermohonan(
        id: currentId,
        jenisPerizinanId: _selectedJenis!.id,
        krkTerkaitId: _selectedKrkTerkaitId,
        namaPerusahaan: _tipePemohon == 'Perusahaan / PT' ? _namaPerusahaanController.text.trim() : null,
        namaDirektur: _tipePemohon == 'Perusahaan / PT' ? _namaDirekturController.text.trim() : null,
        noHpPenanggungJawab: _tipePemohon == 'Perusahaan / PT' ? _noHpPenanggungJawabController.text.trim() : null,
        rencanaKegiatan: _rencanaKegiatanController.text.trim(),
        alamatLengkap: _alamatLengkapController.text.trim(),
        luasArea: _luasAreaController.text.trim(),
        keterangan: _keteranganController.text.trim(),
      );
    }

    if (!mounted) return;

    if (actionSuccess && currentId != null) {
      for (final entry in _pickedFiles.entries) {
          await dokumenProvider.uploadDokumen(
            permohonanId: currentId,
            jenisDokumen: entry.key,
            filePath: entry.value.path,
            fileBytes: entry.value.bytes,
            fileName: entry.value.name,
          );
      }
      for (final entry in _pickedLinks.entries) {
        final normalized = _normalizeUrl(entry.value);
        if (normalized.isNotEmpty && _isValidUrl(normalized)) {
          await dokumenProvider.uploadDokumen(
            permohonanId: currentId,
            jenisDokumen: entry.key,
            linkUrl: normalized,
          );
        }
      }

      await provider.ajukanPermohonan(currentId);

      if (!mounted) return;
      Navigator.of(context).pop(); // Tutup dialog
      context.showSuccessMessage('Permohonan ${_selectedJenis!.kode} Berhasil Diajukan ke Bidang Tata Ruang!');
      context.pushReplacement('/permohonan/$currentId');
    } else {
      Navigator.of(context).pop(); // Tutup dialog jika error
      if (provider.error != null) {
        context.showApiError(ApiException(message: provider.error!));
      }
    }
  }

  Future<void> _onSimpanDraft() async {
    if (_selectedJenis == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Menyimpan Draft...', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );

    final provider = context.read<PermohonanProvider>();
    final dokumenProvider = context.read<DokumenProvider>();

    int? currentId = widget.draft?.id;
    bool actionSuccess = false;

    if (currentId == null) {
      final created = await provider.createPermohonan(
        jenisPerizinanId: _selectedJenis!.id,
        krkTerkaitId: _selectedKrkTerkaitId,
        namaPerusahaan: _tipePemohon == 'Perusahaan / PT' ? _namaPerusahaanController.text.trim() : null,
        namaDirektur: _tipePemohon == 'Perusahaan / PT' ? _namaDirekturController.text.trim() : null,
        noHpPenanggungJawab: _tipePemohon == 'Perusahaan / PT' ? _noHpPenanggungJawabController.text.trim() : null,
        rencanaKegiatan: _rencanaKegiatanController.text.trim(),
        alamatLengkap: _alamatLengkapController.text.trim(),
        luasArea: _luasAreaController.text.trim(),
        keterangan: _keteranganController.text.trim(),
      );
      if (created != null) {
        currentId = created.id;
        actionSuccess = true;
      }
    } else {
      actionSuccess = await provider.updatePermohonan(
        id: currentId,
        jenisPerizinanId: _selectedJenis!.id,
        krkTerkaitId: _selectedKrkTerkaitId,
        namaPerusahaan: _tipePemohon == 'Perusahaan / PT' ? _namaPerusahaanController.text.trim() : null,
        namaDirektur: _tipePemohon == 'Perusahaan / PT' ? _namaDirekturController.text.trim() : null,
        noHpPenanggungJawab: _tipePemohon == 'Perusahaan / PT' ? _noHpPenanggungJawabController.text.trim() : null,
        rencanaKegiatan: _rencanaKegiatanController.text.trim(),
        alamatLengkap: _alamatLengkapController.text.trim(),
        luasArea: _luasAreaController.text.trim(),
        keterangan: _keteranganController.text.trim(),
      );
    }

    if (!mounted) return;

    if (actionSuccess && currentId != null) {
      for (final entry in _pickedFiles.entries) {
          await dokumenProvider.uploadDokumen(
            permohonanId: currentId,
            jenisDokumen: entry.key,
            filePath: entry.value.path,
            fileBytes: entry.value.bytes,
            fileName: entry.value.name,
          );
      }
      for (final entry in _pickedLinks.entries) {
        final normalized = _normalizeUrl(entry.value);
        if (normalized.isNotEmpty && _isValidUrl(normalized)) {
          await dokumenProvider.uploadDokumen(
            permohonanId: currentId,
            jenisDokumen: entry.key,
            linkUrl: normalized,
          );
        }
      }

      if (!mounted) return;
      Navigator.of(context).pop(); // dialog
      context.showSuccessMessage('Progres berhasil disimpan sebagai Draft');
      context.pop(); // close screen
    } else {
      Navigator.of(context).pop();
      if (provider.error != null) {
        context.showApiError(ApiException(message: provider.error!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final jenisProvider = context.watch<JenisPerizinanProvider>();
    final permohonanProvider = context.watch<PermohonanProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.draft != null
              ? 'Lanjutkan Draft'
              : (_selectedJenis != null ? 'Form Permohonan ${_selectedJenis!.kode}' : 'Buat Permohonan Baru'),
        ),
        actions: [
          if (_currentStep == 1 || _currentStep == 2)
            TextButton.icon(
              onPressed: permohonanProvider.isActionLoading ? null : _onSimpanDraft,
              icon: const Icon(Icons.save_outlined, color: Colors.white, size: 20),
              label: const Text('Simpan Draft', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: jenisProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : jenisProvider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(jenisProvider.error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => jenisProvider.fetchJenisPerizinan(),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Progress Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: AppTheme.goldColor,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$_currentStep',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _currentStep == 1
                                        ? 'Langkah 1 dari 3: Isian Data Lokasi'
                                        : _currentStep == 2
                                            ? 'Langkah 2 dari 3: Upload Dokumen'
                                            : 'Langkah 3 dari 3: Konfirmasi & Ajukan',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Layanan ${_selectedJenis?.kode ?? ''} - ${_selectedJenis?.nama ?? ''}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Section Content per Step
                      if (_currentStep == 1) _buildStep1FormIsian(),
                      if (_currentStep == 2) _buildStep2UploadDokumen(),
                      if (_currentStep == 3) _buildStep3Konfirmasi(),

                      const SizedBox(height: 24),

                      // Bottom Navigation Action Buttons
                      Row(
                        children: [
                          if (_currentStep > 1) ...[
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 48),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () => setState(() => _currentStep -= 1),
                                child: const Text('Kembali'),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            flex: 2,
                            child: LoadingButton(
                              label: _currentStep == 3 ? 'Ajukan Permohonan' : 'Lanjutkan',
                              isLoading: permohonanProvider.isActionLoading,
                              onPressed: () {
                                if (_currentStep == 1) {
                                  if (_formKeyDetail.currentState?.validate() ?? false) {
                                    setState(() => _currentStep = 2);
                                  }
                                } else if (_currentStep == 2) {
                                  if (_validateMandatoryDocuments()) {
                                    setState(() => _currentStep = 3);
                                  }
                                } else if (_currentStep == 3) {
                                  _onSubmitPermohonan();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStep1FormIsian() {
    final isSiteplan = _selectedJenis?.kode.toUpperCase() == 'SITEPLAN';

    return Form(
      key: _formKeyDetail,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Form Isian Perizinan ${_selectedJenis?.kode ?? ''}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 16),

          // Prasyarat Layanan Siteplan: Pilih KRK terbit dari aplikasi (Opsional)
          if (isSiteplan) ...[
            if (_isLoadingKrkTerbit)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(),
              )
            else if (_myKrkTerbitList.isNotEmpty) ...[
              DropdownButtonFormField<int?>(
              isExpanded: true,
              initialValue: _selectedKrkTerkaitId,
              decoration: const InputDecoration(
                labelText: 'Pilih Surat KRK Terbit dari Aplikasi (Opsional)',
                hintText: 'Pilih Jika Pernah Membuat KRK di Aplikasi ini, atau Upload Manual di Langkah 2',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('-- Tidak Memilih (Upload Manual PDF di Langkah 2) --', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ),
                ..._myKrkTerbitList.map((krk) {
                  return DropdownMenuItem<int?>(
                    value: krk.id,
                    child: Text(
                      '${krk.nomorPermohonan} - ${krk.rencanaKegiatan ?? "Surat KRK"}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }),
              ],
              onChanged: (val) {
                setState(() => _selectedKrkTerkaitId = val);
              },
            ),
            const SizedBox(height: 16),
          ],
        ],

          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: _tipePemohon,
            decoration: const InputDecoration(
              labelText: 'Tipe Pemohon (Individu atau Perusahaan/PT) *',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            items: const [
              DropdownMenuItem(value: 'Individu / Perorangan', child: Text('Individu / Perorangan')),
              DropdownMenuItem(value: 'Perusahaan / PT', child: Text('Perusahaan / PT')),
            ],
            onChanged: (val) {
              setState(() {
                _tipePemohon = val!;
              });
            },
          ),
          const SizedBox(height: 14),

          if (_tipePemohon == 'Perusahaan / PT') ...[
            TextFormField(
              controller: _namaPerusahaanController,
              decoration: const InputDecoration(
                labelText: 'Nama Perusahaan *',
                hintText: 'Contoh: PT. Maju Bersama',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Nama Perusahaan Wajib Diisi' : null,
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _namaDirekturController,
              decoration: const InputDecoration(
                labelText: 'Nama Direktur / Penanggung Jawab *',
                hintText: 'Contoh: Budi Santoso',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Nama Direktur Wajib Diisi' : null,
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _noHpPenanggungJawabController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'No HP Penanggung Jawab *',
                hintText: 'Contoh: 081234567890',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'No HP Penanggung Jawab Wajib Diisi' : null,
            ),
            const SizedBox(height: 14),
          ],

          TextFormField(
            controller: _rencanaKegiatanController,
            minLines: 1,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: isSiteplan
                  ? 'Rencana Pembangunan Apa? *'
                  : 'Rencana Kegiatan atau Pembangunan Apa? *',
              hintText: _tipePemohon == 'Perusahaan / PT' 
                  ? 'Contoh: Pembangunan Perumahan Cluster / Pabrik / Gudang'
                  : 'Contoh: Pembangunan Rumah Tinggal / Kios',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Rencana Kegiatan Wajib Diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Checkbox Sama dengan Alamat Profil
          InkWell(
            onTap: () => _toggleSamaDenganProfil(!_samaDenganAlamatProfil),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _samaDenganAlamatProfil,
                      activeColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (val) {
                        _toggleSamaDenganProfil(val ?? false);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Alamat lokasi sama dengan alamat di profil',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),

          TextFormField(
            controller: _alamatLengkapController,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Alamat Lengkap (KP, RT, RW, Desa, Kecamatan) *',
              hintText: 'Contoh: Kp. Sukagalih RT 02 RW 05, Desa Sukagalih, Kec. Tarogong Kidul (Kabupaten Garut)',
              helperText: _samaDenganAlamatProfil
                  ? 'Menggunakan alamat dari profil pemohon'
                  : 'Bisa centang opsi di atas atau ketik alamat lokasi lain',
              helperStyle: TextStyle(
                color: _samaDenganAlamatProfil ? AppTheme.primaryColor : Colors.grey.shade600,
                fontSize: 11,
              ),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (val) {
              final user = context.read<AuthProvider>().user;
              final alamatProfil = user?.alamat?.trim() ?? '';
              if (_samaDenganAlamatProfil && val.trim() != alamatProfil) {
                setState(() {
                  _samaDenganAlamatProfil = false;
                  _previousCustomAlamat = val;
                });
              }
            },
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Alamat Lengkap Lokasi Wajib Diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          TextFormField(
            controller: _luasAreaController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Luas Lahan m² (Bukan Luas Bangunan) *',
              hintText: 'Contoh: 250',
              suffixText: 'm²',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Luas Lahan Wajib Diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          TextFormField(
            controller: _keteranganController,
            minLines: 1,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Catatan / Keterangan Tambahan (Opsional)',
              hintText: 'Catatan Spesifik Lokasi atau Pengajuan...',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2UploadDokumen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dokumen Persyaratan ${_selectedJenis?.kode ?? ''}:',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 6),
        const Text(
          'Dokumen Bertanda (*) Wajib Diupload. Dokumen (Kondisional) Dapat Dikosongkan Jika Tidak Berlaku.',
          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 16),

        if (_selectedJenis != null)
          ...(_selectedJenis!.persyaratan.toList()..sort((a, b) {
            final aOpt = a.isOpsional;
            final bOpt = b.isOpsional;
            if (aOpt == bOpt) return 0;
            return aOpt ? 1 : -1; // Wajib (false) diletakkan di atas Kondisional (true)
          })).map((syarat) {
            final picked = _pickedFiles[syarat.nama];
            final pickedLink = _pickedLinks[syarat.nama];
            final isOptional = syarat.isOpsional;
            final maxMb = syarat.maxSizeMb;
            final providesLink = _doesRequirementProvideLink(syarat);

            final isLinkValid = pickedLink != null && _isValidUrl(pickedLink);
            final hasExisting = _existingDokumen.containsKey(syarat.nama);

            // Validitas dokumen: link opsional, tapi kalau diisi harus valid
            final bool isSatisfied;
            final bool hasInvalidLink = pickedLink != null && pickedLink.trim().isNotEmpty && !_isValidUrl(pickedLink);
            if (providesLink) {
              if (isOptional) {
                // Kondisional: satisfied kecuali ada link invalid
                isSatisfied = !hasInvalidLink;
              } else {
                // Wajib: harus ada file/link valid/existing, DAN tidak boleh ada link invalid
                isSatisfied = !hasInvalidLink && (picked != null || isLinkValid || hasExisting);
              }
            } else {
              isSatisfied = picked != null || isLinkValid || hasExisting;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSatisfied
                      ? const Color(0xFF16A34A)
                      : isOptional
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFFEF4444),
                  width: isSatisfied ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        isSatisfied
                            ? Icons.check_circle
                            : isOptional
                                ? Icons.info_outline
                                : Icons.warning_amber_rounded,
                        color: isSatisfied
                            ? const Color(0xFF16A34A)
                            : isOptional
                                ? const Color(0xFF64748B)
                                : const Color(0xFFEF4444),
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    syarat.nama,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isOptional ? const Color(0xFFF1F5F9) : const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isOptional ? 'Kondisional' : 'Wajib *',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isOptional ? const Color(0xFF64748B) : const Color(0xFFDC2626),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Maks. $maxMb MB${(syarat.allowedTypes != null && syarat.allowedTypes!.isNotEmpty) ? ' | Format: ${syarat.allowedTypes}' : ''}',
                              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 3),
                            Builder(
                              builder: (context) {
                                String statusMsg;
                                Color statusColor;

                                if (isLinkValid) {
                                  final norm = _normalizeUrl(pickedLink);
                                  statusMsg = picked != null
                                      ? '${picked.name} • Link: $norm'
                                      : 'Link Disematkan: $norm';
                                  statusColor = const Color(0xFF16A34A);
                                } else if (pickedLink != null && pickedLink.trim().isNotEmpty) {
                                  statusMsg = 'Format link tidak valid! Harus URL yang bisa dibuka (https://...)';
                                  statusColor = const Color(0xFFDC2626);
                                } else if (hasExisting) {
                                  statusMsg = 'Sudah Diunggah (Tersimpan di Draft)';
                                  statusColor = const Color(0xFF16A34A);
                                } else if (picked != null) {
                                  statusMsg = picked.name;
                                  statusColor = const Color(0xFF16A34A);
                                } else {
                                  statusMsg = 'Belum dipilih';
                                  statusColor = isOptional
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFFEF4444);
                                }

                                return Text(
                                  statusMsg,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: (!isSatisfied && !isOptional) ? FontWeight.w600 : FontWeight.normal,
                                    color: statusColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => _pickFileForRequirement(syarat),
                        child: Text(picked != null ? 'Ganti File' : 'Pilih File'),
                      ),
                    ],
                  ),
                  if (providesLink) ...[
                    const SizedBox(height: 12),
                    if (syarat.linkUrl != null && syarat.linkUrl!.isNotEmpty) ...[
                      SelectableText(
                        'Link Template / Info: ${syarat.linkUrl}',
                        style: const TextStyle(fontSize: 11, color: Colors.blue),
                      ),
                      const SizedBox(height: 4),
                    ],
                    TextFormField(
                      initialValue: pickedLink ?? '',
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText: 'Link Google Drive / Cloud Storage (Opsional)',
                        hintText: 'https://drive.google.com/drive/folders/...',
                        helperText: 'Opsional — Jika diisi, pastikan link valid dan akses disetel Publik',
                        helperStyle: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF64748B),
                        ),
                        prefixIcon: const Icon(Icons.link, size: 20),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                      style: const TextStyle(fontSize: 12),
                      validator: (val) {
                        final text = val?.trim() ?? '';
                        // Link opsional: kosong = OK
                        if (text.isEmpty) return null;
                        // Tapi kalau diisi, HARUS link valid yang bisa dibuka
                        if (!_isValidUrl(text)) {
                          return 'Link tidak valid! Pastikan format URL benar (contoh: https://drive.google.com/...)';
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          final trimmed = val.trim();
                          if (trimmed.isEmpty) {
                            _pickedLinks.remove(syarat.nama);
                          } else {
                            _pickedLinks[syarat.nama] = _normalizeUrl(trimmed);
                          }
                        });
                      },
                    ),
                  ],
                ],
              ),
            );
          }),
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

  Widget _buildStep3Konfirmasi() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Permohonan:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const Divider(height: 20),
          _buildSummaryRow('Jenis Perizinan', '${_selectedJenis?.kode} - ${_selectedJenis?.nama}'),
          const SizedBox(height: 10),
          _buildSummaryRow('Tipe Pemohon', _tipePemohon),
          const SizedBox(height: 10),
          if (_tipePemohon == 'Perusahaan / PT') ...[
            _buildSummaryRow('Nama Perusahaan', _namaPerusahaanController.text),
            const SizedBox(height: 10),
            _buildSummaryRow('Direktur / Penanggung Jawab', _namaDirekturController.text),
            const SizedBox(height: 10),
            _buildSummaryRow('No HP Penanggung Jawab', _noHpPenanggungJawabController.text),
            const SizedBox(height: 10),
          ],
          _buildSummaryRow('Rencana Pembangunan', _rencanaKegiatanController.text),
          const SizedBox(height: 10),
          _buildSummaryRow(
            'Alamat Lokasi',
            _alamatLengkapController.text.toLowerCase().contains('garut')
                ? _alamatLengkapController.text
                : '${_alamatLengkapController.text}, Kab. Garut',
          ),
          const SizedBox(height: 10),
          _buildSummaryRow('Luas Lahan', _formatLuasArea(_luasAreaController.text)),
          const SizedBox(height: 10),
          const Text(
            'Dokumen Terlampir',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 4),
          if (_pickedFiles.isEmpty && _pickedLinks.isEmpty)
             const Text('-', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))
          else ...[
             ..._pickedFiles.entries.map((entry) {
                return InkWell(
                  onTap: () {
                    if (entry.value.path != null) {
                      OpenFilex.open(entry.value.path!);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.insert_drive_file_outlined, size: 20, color: Color(0xFF3B82F6)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                entry.value.name,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.remove_red_eye_outlined, size: 18, color: Color(0xFF64748B)),
                      ],
                    ),
                  ),
                );
             }),
             ..._pickedLinks.entries.map((entry) {
                final displayUrl = _normalizeUrl(entry.value);
                return InkWell(
                  onTap: () async {
                    try {
                      final url = Uri.parse(displayUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      } else {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tidak dapat membuka link tersebut')),
                        );
                      }
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link tidak valid')),
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.link, size: 20, color: Color(0xFF3B82F6)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                displayUrl,
                                style: const TextStyle(fontSize: 11, color: Colors.blue),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.open_in_new, size: 18, color: Color(0xFF64748B)),
                      ],
                    ),
                  ),
                );
             }),
          ]
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        const SizedBox(height: 2),
        Text(
          value.isNotEmpty ? value : '-',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
      ],
    );
  }
}
