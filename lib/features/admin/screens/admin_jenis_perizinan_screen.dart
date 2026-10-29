import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/api_exception.dart';
import '../../../core/widgets/global_empty_state.dart';
import '../../../core/widgets/global_error_bottom_sheet.dart';
import '../../../models/jenis_perizinan_model.dart';
import '../../../providers/admin_provider.dart';

class AdminJenisPerizinanScreen extends StatefulWidget {
  const AdminJenisPerizinanScreen({super.key});

  @override
  State<AdminJenisPerizinanScreen> createState() =>
      _AdminJenisPerizinanScreenState();
}

class _AdminJenisPerizinanScreenState extends State<AdminJenisPerizinanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final provider = context.read<AdminProvider>();
    await provider.fetchMasterJenisPerizinan();
    if (!mounted) return;

    if (provider.error != null) {
      showGlobalErrorBottomSheet(
        context,
        errorMessage: provider.error!,
        onRetry: _fetchData,
      );
    }
  }

  void _showFormDialog([JenisPerizinanModel? item]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) =>
            _JenisPerizinanFormPage(item: item, onSaved: _fetchData),
      ),
    );
  }

  Future<void> _onDeleteJenis(JenisPerizinanModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jenis Perizinan'),
        content: Text('Apakah Anda yakin ingin menghapus "${item.nama}"?'),
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

    final provider = context.read<AdminProvider>();
    final success = await provider.deleteJenisPerizinan(item.id);

    if (!mounted) return;

    if (success) {
      context.showSuccessMessage('Jenis Perizinan Berhasil Dihapus');
    } else if (provider.error != null) {
      context.showApiError(ApiException(message: provider.error!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Master Jenis Perizinan'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 110),
        child: FloatingActionButton(
          heroTag: 'admin_jenis_perizinan_fab',
          backgroundColor: AppTheme.goldColor,
          foregroundColor: AppTheme.primaryColor,
          onPressed: () => _showFormDialog(),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
      body: provider.isJenisLoading && provider.jenisList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.jenisList.isEmpty
          ? RefreshIndicator(
              onRefresh: _fetchData,
              child: const GlobalEmptyState(
                title: 'Belum Ada Perizinan',
                subtitle: 'Tidak Ada Master Jenis Perizinan yang Ditemukan.',
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 180),
                itemCount: provider.jenisList.length,
                itemBuilder: (context, index) {
                  final item = provider.jenisList[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    if (item.logoUrl != null)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: Image.network(
                                          item.logoUrl!,
                                          width: 32,
                                          height: 32,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(
                                            Icons.image,
                                            size: 32,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item.kode,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryColor,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Switch(
                                    value: item.status == 'aktif',
                                    onChanged: (val) {
                                      provider.updateJenisPerizinan(
                                        id: item.id,
                                        status: val ? 'aktif' : 'nonaktif',
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: AppTheme.primaryColor,
                                    ),
                                    onPressed: () => _showFormDialog(item),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _onDeleteJenis(item),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.nama,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (item.deskripsi != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.deskripsi!,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Text(
                            'Estimasi Waktu: ${item.estimasiWaktu} Hari Kerja',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Persyaratan:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: item.persyaratan.map((p) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: p.isOpsional
                                      ? const Color(0xFFF8FAFC)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        '${p.nama}${p.isOpsional ? ' (Opsional)' : ''}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: p.isOpsional
                                              ? const Color(0xFF64748B)
                                              : const Color(0xFF334155),
                                          fontWeight: p.isOpsional
                                              ? FontWeight.normal
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE2E8F0),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: Text(
                                        '${p.maxSizeMb} MB',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: Color(0xFF475569),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}


// ─── Halaman Form (bukan Dialog) ────────────────────────────────────────────

class _JenisPerizinanFormPage extends StatefulWidget {
  final JenisPerizinanModel? item;
  final VoidCallback onSaved;

  const _JenisPerizinanFormPage({this.item, required this.onSaved});

  @override
  State<_JenisPerizinanFormPage> createState() =>
      _JenisPerizinanFormPageState();
}

class _JenisPerizinanFormPageState extends State<_JenisPerizinanFormPage> {
  late final TextEditingController kodeController;
  late final TextEditingController namaController;
  late final TextEditingController deskripsiController;
  late final TextEditingController waktuController;
  late final TextEditingController ukuranFileController;
  late List<Map<String, dynamic>> persyaratanList;
  late String status;
  File? selectedLogo;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    kodeController = TextEditingController(text: item?.kode ?? '');
    namaController = TextEditingController(text: item?.nama ?? '');
    deskripsiController = TextEditingController(text: item?.deskripsi ?? '');
    waktuController = TextEditingController(
      text: (item?.estimasiWaktu ?? 14).toString(),
    );
    ukuranFileController = TextEditingController(
      text: (item?.maxFileSizeMb ?? 5).toString(),
    );

    persyaratanList = (item?.persyaratan ?? []).map((p) => <String, dynamic>{
      'namaController': TextEditingController(text: p.nama),
      'isOpsional': p.isOpsional,
      'maxSizeController': TextEditingController(text: p.maxSizeMb.toString()),
      'linkController': TextEditingController(text: p.linkUrl ?? ''),
      'hasLink': p.allowLink || (p.linkUrl != null && p.linkUrl!.isNotEmpty),
      'tipeController': TextEditingController(text: p.allowedTypes ?? ''),
    }).toList();

    final rawStatus = (item?.status ?? 'aktif').toLowerCase();
    status = ['aktif', 'nonaktif'].contains(rawStatus) ? rawStatus : 'aktif';
  }

  @override
  void dispose() {
    kodeController.dispose();
    namaController.dispose();
    deskripsiController.dispose();
    waktuController.dispose();
    ukuranFileController.dispose();
    for (final p in persyaratanList) {
      (p['namaController'] as TextEditingController).dispose();
      (p['maxSizeController'] as TextEditingController).dispose();
      (p['linkController'] as TextEditingController).dispose();
      (p['tipeController'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  Future<void> _pickLogo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'],
        allowCompression: false,
      );
      if (result != null && result.files.single.path != null) {
        setState(() => selectedLogo = File(result.files.single.path!));
      }
    } catch (e) {
      if (mounted) {
        context.showApiError(ApiException(message: 'Gagal mengambil gambar: $e'));
      }
    }
  }

  Future<void> _save() async {
    final kode = kodeController.text.trim();
    final nama = namaController.text.trim();
    final waktu = int.tryParse(waktuController.text.trim()) ?? 14;
    final ukuranFile = int.tryParse(ukuranFileController.text.trim()) ?? 5;

    final List<PersyaratanModel> syaratList = [];
    for (var req in persyaratanList) {
      final namaReq = (req['namaController'] as TextEditingController).text
          .trim();
      if (namaReq.isNotEmpty) {
        syaratList.add(
          PersyaratanModel(
            nama: namaReq,
            isOpsional: req['isOpsional'],
            maxSizeMb:
                int.tryParse(
                  (req['maxSizeController'] as TextEditingController).text
                      .trim(),
                ) ??
                5,
            linkUrl: (req['linkController'] as TextEditingController).text.trim().isEmpty ? null : (req['linkController'] as TextEditingController).text.trim(),
            allowedTypes: (req['tipeController'] as TextEditingController).text.trim().isEmpty ? null : (req['tipeController'] as TextEditingController).text.trim(),
            allowLink: req['hasLink'] == true,
          ),
        );
      }
    }

    if (kodeController.text.trim().isEmpty || namaController.text.trim().isEmpty) {
      context.showApiError(const ApiException(message: 'Kode dan Nama Perizinan Wajib Diisi'));
      return;
    }

    if (widget.item == null && selectedLogo == null) {
      context.showApiError(const ApiException(message: 'Logo Wajib Diunggah'));
      return;
    }

    setState(() => isSaving = true);

    final provider = context.read<AdminProvider>();
    bool success;
    if (widget.item == null) {
      success = await provider.createJenisPerizinan(
        kode: kode,
        nama: nama,
        deskripsi: deskripsiController.text.trim(),
        estimasiWaktu: waktu,
        maxFileSizeMb: ukuranFile,
        status: status,
        persyaratan: syaratList,
        logoFile: selectedLogo,
      );
    } else {
      success = await provider.updateJenisPerizinan(
        id: widget.item!.id,
        kode: kode,
        nama: nama,
        deskripsi: deskripsiController.text.trim(),
        estimasiWaktu: waktu,
        maxFileSizeMb: ukuranFile,
        status: status,
        persyaratan: syaratList,
        logoFile: selectedLogo,
      );
    }

    if (!mounted) return;
    setState(() => isSaving = false);

    if (success) {
      widget.onSaved();
      Navigator.of(context).pop();
      context.showSuccessMessage('Master Jenis Perizinan Berhasil Disimpan');
    } else if (provider.error != null) {
      context.showApiError(ApiException(message: provider.error!));
    }
  }

  Future<void> _showFormatSelectionDialog(int index) async {
    final ctrl = persyaratanList[index]['tipeController'] as TextEditingController;
    List<String> currentSelected = ctrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final List<String> allFormats = ['pdf', 'jpg', 'png', 'doc', 'docx', 'xls', 'xlsx', 'zip', 'rar', 'kml', 'kmz', 'shp', 'dwg'];

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Pilih Format Diizinkan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              contentPadding: const EdgeInsets.only(top: 16),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allFormats.length,
                  itemBuilder: (context, i) {
                    final ext = allFormats[i];
                    return CheckboxListTile(
                      dense: true,
                      title: Text(ext, style: const TextStyle(fontSize: 14)),
                      value: currentSelected.contains(ext),
                      onChanged: (val) {
                        setStateDialog(() {
                          if (val == true) {
                            if (!currentSelected.contains(ext)) currentSelected.add(ext);
                          } else {
                            currentSelected.remove(ext);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Tutup / Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    if (mounted) {
      setState(() {
        ctrl.text = currentSelected.join(', ');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      final isEdit = widget.item != null;
      final sw = MediaQuery.of(context).size.width;
      return Scaffold(
        appBar: AppBar(
        title: Text(isEdit ? 'Edit Jenis Perizinan' : 'Tambah Jenis Perizinan'),
        actions: [
          if (isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo Upload Section
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickLogo,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                          image: selectedLogo != null
                              ? DecorationImage(
                                  image: ResizeImage(FileImage(selectedLogo!), width: 200),
                                  fit: BoxFit.cover,
                                )
                              : (widget.item?.logoUrl != null
                                  ? DecorationImage(image: NetworkImage(widget.item!.logoUrl!), fit: BoxFit.cover)
                                  : null),
                        ),
                        child: selectedLogo == null && widget.item?.logoUrl == null
                            ? const Icon(Icons.add_a_photo, color: Color(0xFF94A3B8), size: 30)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Upload Logo (Wajib *)', style: TextStyle(fontSize: 12, color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Kode
              TextFormField(
                controller: kodeController,
                decoration: InputDecoration(
                  labelText: 'Kode (KRK / SITEPLAN)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),

              // Nama
              TextFormField(
                controller: namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Perizinan',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),

              // Deskripsi
              TextFormField(
                controller: deskripsiController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  filled: true,
                  fillColor: Colors.white,
                  alignLabelWithHint: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),

              // Estimasi Waktu
              TextFormField(
                controller: waktuController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Estimasi Waktu (Hari)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),

              // Max File
              TextFormField(
                controller: ukuranFileController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Default Max File (MB)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 20),

              // Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Status', style: TextStyle(fontSize: 13, color: Color(0xFF666666))),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: status == 'aktif' ? const Color(0xFF1A3C6E) : Colors.transparent,
                            foregroundColor: status == 'aktif' ? Colors.white : const Color(0xFF1A3C6E),
                            side: const BorderSide(color: Color(0xFF1A3C6E)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8))),
                          ),
                          onPressed: () => setState(() => status = 'aktif'),
                          child: const Text('Aktif', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: status == 'nonaktif' ? Colors.red.shade700 : Colors.transparent,
                            foregroundColor: status == 'nonaktif' ? Colors.white : Colors.red.shade700,
                            side: BorderSide(color: Colors.red.shade700),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8))),
                          ),
                          onPressed: () => setState(() => status = 'nonaktif'),
                          child: const Text('Nonaktif', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Persyaratan Dokumen header
              Row(
                children: [
                  const Expanded(
                    child: Text('Persyaratan Dokumen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor, 
                      foregroundColor: Colors.white,
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Tambah'),
                    onPressed: () {
                      debugPrint('TOMBOL TAMBAH PERSYARATAN DITEKAN');
                      setState(() {
                        persyaratanList.add({
                          'namaController': TextEditingController(),
                          'isOpsional': false,
                          'maxSizeController': TextEditingController(text: ukuranFileController.text.isNotEmpty ? ukuranFileController.text : '5'),
                          'linkController': TextEditingController(),
                          'hasLink': false,
                          'tipeController': TextEditingController(),
                        });
                      });
                      context.showInfoMessage('Form Persyaratan Baru Ditambahkan di Paling Bawah!');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // List persyaratan
              for (int i = 0; i < persyaratanList.length; i++) ...[
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text('Persyaratan ', style: const TextStyle(fontWeight: FontWeight.w600))),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => setState(() => persyaratanList.removeAt(i)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: persyaratanList[i]['namaController'] as TextEditingController,
                          decoration: const InputDecoration(labelText: 'Nama Dokumen', border: OutlineInputBorder(), isDense: true),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: persyaratanList[i]['maxSizeController'] as TextEditingController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Max Ukuran (MB)', border: OutlineInputBorder(), isDense: true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: InkWell(
                                onTap: () => _showFormatSelectionDialog(i),
                                child: IgnorePointer(
                                  child: TextFormField(
                                    controller: persyaratanList[i]['tipeController'] as TextEditingController,
                                    decoration: const InputDecoration(
                                      labelText: 'Format (Pilih)', 
                                      border: OutlineInputBorder(), 
                                      isDense: true,
                                      suffixIcon: Icon(Icons.arrow_drop_down),
                                    ),
                                    readOnly: true,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (persyaratanList[i]['hasLink'] == true) ...[
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: persyaratanList[i]['linkController'] as TextEditingController,
                                  decoration: const InputDecoration(
                                    labelText: 'Link (G-Drive, dll)', 
                                    border: OutlineInputBorder(), 
                                    isDense: true,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    persyaratanList[i]['hasLink'] = false;
                                    (persyaratanList[i]['linkController'] as TextEditingController).clear();
                                  });
                                },
                              ),
                            ],
                          ),
                        ] else ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  persyaratanList[i]['hasLink'] = true;
                                });
                              },
                              icon: const Icon(Icons.add_link, size: 18),
                              label: const Text('Tambah Link'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Checkbox(
                              value: persyaratanList[i]['isOpsional'] as bool,
                              onChanged: (val) => setState(() => persyaratanList[i]['isOpsional'] = val ?? false),
                            ),
                            const Text('Opsional'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: isSaving ? null : _save,
                child: const Text('Simpan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
    } catch (e, stack) {
      debugPrint('BUILD ERROR: ');
      debugPrint(stack.toString());
      return Scaffold(
        appBar: AppBar(title: const Text('Error form')),
        body: SingleChildScrollView(
          child: Text('Error: \n\n', style: const TextStyle(color: Colors.red, fontSize: 12)),
        ),
      );
    }
  }
}
