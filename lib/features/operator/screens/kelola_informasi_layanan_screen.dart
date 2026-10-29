import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/api_exception.dart';
import '../../../models/informasi_layanan_model.dart';
import '../../../providers/informasi_layanan_provider.dart';

/// Halaman Pengelolaan Informasi Layanan Publik untuk Bagian Umum (Operator)
/// Memungkinkan Operator mengelola deskripsi, alur pelayanan, dan persyaratan 8 jenis layanan publik.
/// Data diambil dari backend API dan perubahan disimpan ke database secara terpisah dari Master Jenis Perizinan.
class KelolaInformasiLayananScreen extends StatefulWidget {
  const KelolaInformasiLayananScreen({super.key});

  @override
  State<KelolaInformasiLayananScreen> createState() => _KelolaInformasiLayananScreenState();
}

class _KelolaInformasiLayananScreenState extends State<KelolaInformasiLayananScreen> {
  /// Map kode layanan ke asset icon lokal (fallback jika backend tidak punya logo)
  static const Map<String, String> _iconAssets = {
    'KRK': 'assets/images/logo_krk.png',
    'SITEPLAN': 'assets/images/logo_siteplan.png',
    'PKKPR': 'assets/images/pkkpr.png',
    'PEIL': 'assets/images/peil_banjir.png',
    'RUMIJA': 'assets/images/rumija.png',
    'PBG': 'assets/images/pbg.png',
    'SLF': 'assets/images/slf.png',
    'IRIGASI': 'assets/images/irigasi_teknis.png',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InformasiLayananProvider>().fetchInformasiLayanan();
    });
  }

  String _getIconAsset(String kode) {
    return _iconAssets[kode.toUpperCase()] ?? 'assets/images/logo_krk.png';
  }

  void _editInformasiDialog(InformasiLayananModel item) {
    final deskripsiController = TextEditingController(text: item.deskripsi ?? '');
    final tentangController = TextEditingController(text: item.tentang ?? '');
    final alurController = TextEditingController(text: item.alur.join('\n'));

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Image.asset(_getIconAsset(item.kode), width: 32, height: 32, errorBuilder: (c, e, s) => const Icon(Icons.info)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Edit ${item.nama}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: deskripsiController,
                minLines: 3,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Singkat',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tentangController,
                minLines: 4,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: 'Tentang Layanan (Detail)',
                  helperText: 'Deskripsi lengkap yang ditampilkan di halaman informasi pemohon',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: alurController,
                minLines: 5,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: 'Alur Pelayanan',
                  helperText: 'Satu langkah per baris',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          Consumer<InformasiLayananProvider>(
            builder: (context, provider, _) => ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      // Parse alur: split by newline, trim empty lines
                      final alurList = alurController.text
                          .split('\n')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();

                      final success = await context.read<InformasiLayananProvider>().updateInformasiLayanan(
                            item.id,
                            deskripsiController.text.trim(),
                            tentangController.text.trim(),
                            alurList,
                          );

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }

                      FocusManager.instance.primaryFocus?.unfocus();

                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (context.mounted) {
                          if (success) {
                            context.showSuccessMessage('Informasi ${item.kode} Berhasil Diperbarui!');
                          } else {
                            context.showWarningMessage(provider.error ?? 'Gagal Memperbarui Informasi Layanan');
                          }
                        }
                      });
                    },
              child: provider.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Simpan Perubahan'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Kelola Informasi Layanan Publik'),
      ),
      body: Consumer<InformasiLayananProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                  const SizedBox(height: 12),
                  Text(provider.error!, style: const TextStyle(color: Color(0xFF64748B))),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => provider.fetchInformasiLayanan(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (provider.items.isEmpty) {
            return const Center(
              child: Text('Belum ada data layanan.', style: TextStyle(color: Color(0xFF64748B))),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            itemCount: provider.items.length,
            itemBuilder: (context, index) {
              final item = provider.items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: Image.asset(
                    _getIconAsset(item.kode),
                    width: 44,
                    height: 44,
                    errorBuilder: (c, e, s) => const Icon(Icons.info, color: AppTheme.primaryColor, size: 36),
                  ),
                  title: Text(
                    item.nama,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      item.deskripsi ?? '-',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_note_rounded, color: AppTheme.primaryColor, size: 28),
                    onPressed: () => _editInformasiDialog(item),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
