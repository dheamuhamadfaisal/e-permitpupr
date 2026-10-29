import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/api_exception.dart';
import '../../../providers/profil_dinas_provider.dart';
import '../../../widgets/loading_button.dart';

class EditProfilDinasScreen extends StatefulWidget {
  const EditProfilDinasScreen({super.key});

  @override
  State<EditProfilDinasScreen> createState() => _EditProfilDinasScreenState();
}

class _EditProfilDinasScreenState extends State<EditProfilDinasScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaDinasController = TextEditingController();
  final _subNamaController = TextEditingController();
  final _visiController = TextEditingController();
  final _alamatController = TextEditingController();
  final _teleponController = TextEditingController();
  final _emailController = TextEditingController();

  final List<TextEditingController> _misiControllers = [];
  String? _pickedFotoPath;
  String? _pickedFotoName;
  bool _isFotoDeleted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ProfilDinasProvider>();
      await provider.fetchProfilDinas();
      final p = provider.profil;

      if (p != null) {
        _namaDinasController.text = p.namaDinas;
        _subNamaController.text = p.subNama;
        _visiController.text = p.visi;
        _alamatController.text = p.alamat;
        _teleponController.text = p.telepon;
        _emailController.text = p.email;

        setState(() {
          _misiControllers.clear();
          for (final m in p.misi) {
            _misiControllers.add(TextEditingController(text: m));
          }
          if (_misiControllers.isEmpty) {
            _misiControllers.add(TextEditingController());
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _namaDinasController.dispose();
    _subNamaController.dispose();
    _visiController.dispose();
    _alamatController.dispose();
    _teleponController.dispose();
    _emailController.dispose();
    for (final c in _misiControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickFotoKantor() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _pickedFotoPath = image.path;
          _pickedFotoName = image.name;
          _isFotoDeleted = false;
        });
      }
    } catch (e) {
      if (mounted) context.showApiError(ApiException(message: 'Gagal memilih gambar: $e'));
    }
  }

  Future<void> _onSaveProfilDinas() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final provider = context.read<ProfilDinasProvider>();
    final misiList = _misiControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final success = await provider.updateProfilDinas(
      namaDinas: _namaDinasController.text.trim(),
      subNama: _subNamaController.text.trim(),
      visi: _visiController.text.trim(),
      misi: misiList,
      alamat: _alamatController.text.trim(),
      telepon: _teleponController.text.trim(),
      email: _emailController.text.trim(),
      fotoPath: _pickedFotoPath,
    );

    if (!mounted) return;

    if (success) {
      // Tutup keyboard agar animasi lebih smooth
      FocusManager.instance.primaryFocus?.unfocus();
      
      context.showSuccessMessage('Profil Dinas PUPR Garut Berhasil Diperbarui!');
    } else if (provider.error != null) {
      context.showApiError(ApiException(message: provider.error!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfilDinasProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil Dinas'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 120),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kelola Informasi Resmi Dinas PUPR Garut:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _namaDinasController,
                decoration: const InputDecoration(
                  labelText: 'Nama Dinas *',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nama Dinas Wajib Diisi' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _subNamaController,
                decoration: const InputDecoration(
                  labelText: 'Sub Judul Dinas *',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Sub Judul Wajib Diisi' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _visiController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Visi Dinas PUPR *',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Visi Wajib Diisi' : null,
              ),
              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Daftar Poin Misi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _misiControllers.add(TextEditingController());
                      });
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tambah Misi'),
                  ),
                ],
              ),
              ...List.generate(_misiControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _misiControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Misi Ke-${index + 1}',
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      if (_misiControllers.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _misiControllers[index].dispose();
                              _misiControllers.removeAt(index);
                            });
                          },
                        ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

              TextFormField(
                controller: _alamatController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Alamat Lengkap Kantor *',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Alamat Wajib Diisi' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _teleponController,
                decoration: const InputDecoration(
                  labelText: 'Telepon Kantor *',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Telepon Wajib Diisi' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Resmi *',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Email Wajib Diisi' : null,
              ),
              const SizedBox(height: 14),

              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(_pickedFotoName ?? 'Upload / Ganti Foto Kantor Dinas'),
                onPressed: _pickFotoKantor,
              ),
              const SizedBox(height: 24),

              LoadingButton(
                label: 'Simpan Perubahan Profil Dinas',
                isLoading: provider.isActionLoading,
                onPressed: _onSaveProfilDinas,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
