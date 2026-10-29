import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/api_exception.dart';
import '../../../core/widgets/global_empty_state.dart';
import '../../../core/widgets/global_error_bottom_sheet.dart';
import '../../../models/berita_model.dart';
import '../../../providers/berita_provider.dart';
import '../../../widgets/loading_button.dart';

class UploadBeritaScreen extends StatefulWidget {
  const UploadBeritaScreen({super.key});

  @override
  State<UploadBeritaScreen> createState() => _UploadBeritaScreenState();
}

class _UploadBeritaScreenState extends State<UploadBeritaScreen> with SingleTickerProviderStateMixin {
  final _formKeyBanner = GlobalKey<FormState>();
  final _formKeyBerita = GlobalKey<FormState>();
  
  final _judulController = TextEditingController();
  final _ringkasanController = TextEditingController();
  final _kontenController = TextEditingController();
  final _linkUrlController = TextEditingController();

  late TabController _tabController;
  
  String? _pickedImagePath;
  String? _pickedFileName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // Clear selected image when switching tabs
        setState(() {
          _pickedImagePath = null;
          _pickedFileName = null;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final provider = context.read<BeritaProvider>();
    await provider.fetchHomeBerita();
    if (!mounted) return;

    if (provider.error != null) {
      showGlobalErrorBottomSheet(
        context,
        errorMessage: provider.error!,
        onRetry: _fetchData,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _judulController.dispose();
    _ringkasanController.dispose();
    _kontenController.dispose();
    _linkUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isBanner) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Kompres gambar 70%
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (image != null) {
        final String imagePath = image.path;
      if (isBanner) {
        final cropped = await ImageCropper().cropImage(
          sourcePath: imagePath,
          aspectRatio: const CropAspectRatio(ratioX: 1080, ratioY: 450),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Banner',
              toolbarColor: AppTheme.primaryColor,
              toolbarWidgetColor: Colors.white,
              lockAspectRatio: true,
            ),
            IOSUiSettings(
              title: 'Crop Banner',
              aspectRatioLockEnabled: true,
            ),
          ],
        );
        if (cropped != null) {
          setState(() {
            _pickedImagePath = cropped.path;
            _pickedFileName = 'banner_cropped.jpg';
          });
        }
      } else {
        setState(() {
          _pickedImagePath = imagePath;
          _pickedFileName = image.name;
        });
      }
      }
    } catch (e) {
      if (mounted) context.showApiError(ApiException(message: 'Gagal memilih gambar: $e'));
    }
  }

  Future<void> _onSubmitBerita(bool isBanner) async {
    final formKey = isBanner ? _formKeyBanner : _formKeyBerita;
    if (!(formKey.currentState?.validate() ?? false)) return;

    final provider = context.read<BeritaProvider>();
    final success = await provider.createBerita(
      judul: isBanner ? 'Banner' : _judulController.text.trim(),
      ringkasan: isBanner ? null : _ringkasanController.text.trim(),
      konten: isBanner ? 'Banner Item' : _kontenController.text.trim(),
      kategori: isBanner ? 'informasi_terkini' : 'berita',
      imagePath: _pickedImagePath,
      linkUrl: isBanner ? _linkUrlController.text.trim() : null,
    );

    if (!mounted) return;

    if (success) {
      FocusManager.instance.primaryFocus?.unfocus();
      context.showSuccessMessage(isBanner ? 'Banner berhasil diterbitkan!' : 'Berita berhasil diterbitkan!');
      
      if (isBanner) {
        _linkUrlController.clear();
      } else {
        _judulController.clear();
        _ringkasanController.clear();
        _kontenController.clear();
      }
      
      setState(() {
        _pickedImagePath = null;
        _pickedFileName = null;
      });
    } else if (provider.error != null) {
      context.showApiError(ApiException(message: provider.error!));
    }
  }

  Future<void> _onDeleteBerita(BeritaModel berita) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(berita.kategori == 'informasi_terkini' ? 'Hapus Banner' : 'Hapus Berita'),
        content: Text('Apakah Anda yakin ingin menghapus "${berita.judul}"?'),
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

    final provider = context.read<BeritaProvider>();
    final success = await provider.deleteBerita(berita.id);

    if (!mounted) return;

    if (success) {
      context.showSuccessMessage('Berhasil dihapus');
    } else if (provider.error != null) {
      context.showApiError(ApiException(message: provider.error!));
    }
  }

  void _showBeritaDetail(BeritaModel berita) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (berita.gambarUrl != null && berita.gambarUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          berita.gambarUrl!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      berita.judul,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${berita.kategori.replaceAll('_', ' ').toUpperCase()} • ${berita.createdAt.split('T').first}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      berita.konten,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, BeritaModel berita) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditBeritaForm(berita: berita),
    );
  }

  Widget _buildFormBanner(BeritaProvider provider) {
    return Form(
      key: _formKeyBanner,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Banner Baru',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _linkUrlController,
            decoration: const InputDecoration(
              labelText: 'Link Tujuan Banner (URL) *',
              hintText: 'https://...',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (val) => val == null || val.trim().isEmpty ? 'Link URL Wajib Diisi' : null,
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
            icon: const Icon(Icons.image_outlined),
            label: Text(_pickedFileName ?? 'Pilih Gambar Banner (Wajib)'),
            onPressed: () => _pickImage(true),
          ),
          const SizedBox(height: 18),
          LoadingButton(
            label: 'Terbitkan Banner',
            isLoading: provider.isActionLoading,
            onPressed: () {
              if (_pickedImagePath == null) {
                context.showWarningMessage('Gambar banner wajib dipilih');
                return;
              }
              _onSubmitBerita(true);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormBerita(BeritaProvider provider) {
    return Form(
      key: _formKeyBerita,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Berita Baru',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _judulController,
            decoration: const InputDecoration(
              labelText: 'Judul Berita *',
              hintText: 'Contoh: Sosialisasi...',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (val) => val == null || val.trim().isEmpty ? 'Judul Wajib Diisi' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _ringkasanController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Ringkasan Singkat (Opsional)',
              hintText: 'Ringkasan 1-2 Kalimat...',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _kontenController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Isi Berita Lengkap *',
              hintText: 'Tuliskan Rincian Berita...',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (val) => val == null || val.trim().isEmpty ? 'Isi Konten Wajib Diisi' : null,
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
            icon: const Icon(Icons.image_outlined),
            label: Text(_pickedFileName ?? 'Pilih Gambar Berita (Opsional)'),
            onPressed: () => _pickImage(false),
          ),
          const SizedBox(height: 18),
          LoadingButton(
            label: 'Terbitkan Berita',
            isLoading: provider.isActionLoading,
            onPressed: () => _onSubmitBerita(false),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BeritaProvider provider, List<BeritaModel> items, bool isBanner) {
    if (provider.isLoading && items.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()));
    }
    if (items.isEmpty) {
      return GlobalEmptyState(
        title: isBanner ? 'Belum Ada Banner' : 'Belum Ada Berita',
        subtitle: isBanner ? 'Tidak ada banner yang sedang aktif.' : 'Belum ada berita yang diterbitkan.',
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final b = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            onTap: () => _showBeritaDetail(b),
            leading: b.gambarUrl != null && b.gambarUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      b.gambarUrl!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => CircleAvatar(
                        backgroundColor: isBanner ? const Color(0xFFF97316) : AppTheme.primaryColor,
                        child: const Icon(Icons.newspaper, color: Colors.white, size: 20),
                      ),
                    ),
                  )
                : CircleAvatar(
                    backgroundColor: isBanner ? const Color(0xFFF97316) : AppTheme.primaryColor,
                    child: const Icon(Icons.newspaper, color: Colors.white, size: 20),
                  ),
            title: Text(b.judul, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(
              '${b.kategori.replaceAll('_', ' ').toUpperCase()} • ${b.createdAt.split('T').first}',
              style: const TextStyle(fontSize: 11),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryColor),
                  onPressed: () => _showEditDialog(context, b),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _onDeleteBerita(b),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BeritaProvider>(); 

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Kelola Banner & Berita'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppTheme.goldColor,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Banner'),
            Tab(text: 'Berita'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: BANNER
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildFormBanner(provider),
                  ),
                ),
                const SizedBox(height: 28),
                const Text('Daftar Banner Aktif', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 12),
                _buildList(provider, provider.sliderItems, true),
              ],
            ),
          ),
          
          // TAB 2: BERITA
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildFormBerita(provider),
                  ),
                ),
                const SizedBox(height: 28),
                const Text('Daftar Berita Diterbitkan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 12),
                _buildList(provider, provider.newsItems, false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditBeritaForm extends StatefulWidget {
  final BeritaModel berita;
  
  const _EditBeritaForm({required this.berita});

  @override
  State<_EditBeritaForm> createState() => _EditBeritaFormState();
}

class _EditBeritaFormState extends State<_EditBeritaForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _ringkasanController;
  late TextEditingController _kontenController;
  late TextEditingController _linkUrlController;
  
  String? _pickedImagePath;
  String? _pickedFileName;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.berita.judul);
    _ringkasanController = TextEditingController(text: widget.berita.ringkasan ?? '');
    _kontenController = TextEditingController(text: widget.berita.konten);
    _linkUrlController = TextEditingController(text: widget.berita.linkUrl ?? '');
  }

  @override
  void dispose() {
    _judulController.dispose();
    _ringkasanController.dispose();
    _kontenController.dispose();
    _linkUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Kompres gambar 70%
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (image != null) {
        final String imagePath = image.path;
      if (widget.berita.kategori == 'informasi_terkini') {
        final cropped = await ImageCropper().cropImage(
          sourcePath: imagePath,
          aspectRatio: const CropAspectRatio(ratioX: 1080, ratioY: 450),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Banner',
              toolbarColor: AppTheme.primaryColor,
              toolbarWidgetColor: Colors.white,
              lockAspectRatio: true,
            ),
            IOSUiSettings(title: 'Crop Banner', aspectRatioLockEnabled: true),
          ],
        );
        if (cropped != null) {
          setState(() {
            _pickedImagePath = cropped.path;
            _pickedFileName = 'banner_cropped.jpg';
          });
        }
      } else {
        setState(() {
          _pickedImagePath = imagePath;
          _pickedFileName = image.name;
        });
      }
      }
    } catch (e) {
      if (mounted) context.showApiError(ApiException(message: 'Gagal memilih gambar: $e'));
    }
  }

  Future<void> _onUpdate() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final provider = context.read<BeritaProvider>();
    final isBanner = widget.berita.kategori == 'informasi_terkini';
    
    final success = await provider.updateBerita(
      id: widget.berita.id,
      judul: isBanner ? 'Banner' : _judulController.text.trim(),
      ringkasan: isBanner ? null : _ringkasanController.text.trim(),
      konten: isBanner ? 'Banner Item' : _kontenController.text.trim(),
      kategori: widget.berita.kategori,
      imagePath: _pickedImagePath,
      linkUrl: isBanner ? _linkUrlController.text.trim() : null,
    );

    if (!mounted) return;

    if (success) {
      context.showSuccessMessage('Berhasil diperbarui!');
      Navigator.pop(context);
    } else if (provider.error != null) {
      context.showApiError(ApiException(message: provider.error!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BeritaProvider>();
    final isBanner = widget.berita.kategori == 'informasi_terkini';

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 50,
            height: 5,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBanner ? 'Edit Banner' : 'Edit Berita',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 20),
                    
                    if (isBanner) ...[
                      TextFormField(
                        controller: _linkUrlController,
                        decoration: const InputDecoration(labelText: 'Link Tujuan Banner (URL) *', border: OutlineInputBorder()),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Link URL Wajib Diisi' : null,
                      ),
                    ] else ...[
                      TextFormField(
                        controller: _judulController,
                        decoration: const InputDecoration(labelText: 'Judul Berita *', border: OutlineInputBorder()),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Judul Wajib Diisi' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _ringkasanController,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Ringkasan Singkat (Opsional)', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _kontenController,
                        maxLines: 4,
                        decoration: const InputDecoration(labelText: 'Isi Berita Lengkap *', border: OutlineInputBorder()),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Isi Konten Wajib Diisi' : null,
                      ),
                    ],
                    
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
                      icon: const Icon(Icons.image_outlined),
                      label: Text(_pickedFileName ?? 'Ganti Gambar (Opsional)'),
                      onPressed: _pickImage,
                    ),
                    
                    const SizedBox(height: 24),
                    LoadingButton(
                      label: 'Simpan Perubahan',
                      isLoading: provider.isActionLoading,
                      onPressed: _onUpdate,
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
