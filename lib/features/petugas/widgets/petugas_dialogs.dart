import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/permohonan_model.dart';
import '../../../providers/petugas_provider.dart';
import '../../../core/utils/api_exception.dart';

class PetugasDialogs {
  static void showAccKelengkapanDialog({
    required BuildContext context,
    required PermohonanModel permohonan,
    required VoidCallback onSuccess,
  }) {
    bool butuhKunjungan = (permohonan.jenisPerizinan?.kode ?? '').toUpperCase() == 'SITEPLAN';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('ACC Kelengkapan Berkas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Apakah Permohonan Ini Membutuhkan Survei/Kunjungan Lapangan?'),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Butuh Kunjungan Lapangan', style: TextStyle(fontWeight: FontWeight.bold)),
                value: butuhKunjungan,
                onChanged: (val) => setState(() => butuhKunjungan = val ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(ctx);
                context.read<PetugasProvider>().validasiKelengkapan(
                  id: permohonan.id,
                  keputusan: 'acc',
                  butuhKunjungan: butuhKunjungan,
                ).then((success) {
                  if (success) onSuccess();
                });
              },
              child: const Text('Konfirmasi ACC'),
            ),
          ],
        ),
      ),
    );
  }

  static void showTolakKelengkapanDialog({
    required BuildContext context,
    required PermohonanModel permohonan,
    required VoidCallback onSuccess,
    required String jenisPenolakan,
  }) {
    final controller = TextEditingController();
    List<String> selectedDocs = [];
    String? errorMessage;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tolak / Revisi Berkas'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pilih Dokumen Yang Bermasalah / Kurang:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (permohonan.dokumen.isEmpty)
                    const Text('Tidak Ada Dokumen Terlampir.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                  ...permohonan.dokumen.map((doc) => CheckboxListTile(
                    title: Text(doc.jenisDokumen, style: const TextStyle(fontSize: 13)),
                    value: selectedDocs.contains(doc.jenisDokumen),
                    onChanged: (val) {
                      if (val == true) selectedDocs.add(doc.jenisDokumen);
                      else selectedDocs.remove(doc.jenisDokumen);
                      setState(() {});
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  )),
                  const SizedBox(height: 12),
                  const Text('Catatan Penolakan (Wajib):', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    onChanged: (_) {
                      if (errorMessage != null) {
                        setState(() => errorMessage = null);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Alasan Penolakan / Revisi...',
                      border: const OutlineInputBorder(),
                      errorText: errorMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: jenisPenolakan == 'revisi' ? Colors.orange : Colors.red, 
                foregroundColor: Colors.white
              ),
              onPressed: () {
                if (selectedDocs.isEmpty && permohonan.dokumen.isNotEmpty) {
                  setState(() => errorMessage = 'Pilih minimal satu dokumen yang bermasalah!');
                  return;
                }
                if (controller.text.trim().isEmpty) {
                  setState(() => errorMessage = 'Catatan Wajib Diisi!');
                  return;
                }
                Navigator.pop(ctx);
                context.read<PetugasProvider>().validasiKelengkapan(
                  id: permohonan.id,
                  keputusan: 'tolak',
                  catatan: controller.text.trim(),
                  fieldBermasalah: selectedDocs,
                  jenisPenolakan: jenisPenolakan,
                ).then((success) {
                  if (success) onSuccess();
                });
              },
              child: Text(jenisPenolakan == 'revisi' ? 'Minta Revisi' : 'Tolak Permanen'),
            ),
          ],
        ),
      ),
    );
  }

  static void showTolakAnalisisDialog({
    required BuildContext context,
    required PermohonanModel permohonan,
    required VoidCallback onSuccess,
    required String jenisPenolakan,
  }) {
    final controller = TextEditingController();
    List<String> selectedDocs = [];
    String? errorMessage;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(jenisPenolakan == 'revisi' ? 'Minta Revisi Analisis' : 'Tolak Analisis Permanen'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pilih Dokumen Yang Bermasalah / Kurang (jika ada):', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (permohonan.dokumen.isEmpty)
                    const Text('Tidak Ada Dokumen Terlampir.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                  ...permohonan.dokumen.map((doc) => CheckboxListTile(
                    title: Text(doc.jenisDokumen, style: const TextStyle(fontSize: 13)),
                    value: selectedDocs.contains(doc.jenisDokumen),
                    onChanged: (val) {
                      if (val == true) selectedDocs.add(doc.jenisDokumen);
                      else selectedDocs.remove(doc.jenisDokumen);
                      setState(() {});
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  )),
                  const SizedBox(height: 12),
                  const Text('Catatan Penolakan/Revisi (Wajib):', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    onChanged: (_) {
                      if (errorMessage != null) {
                        setState(() => errorMessage = null);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Alasan Penolakan / Revisi...',
                      border: const OutlineInputBorder(),
                      errorText: errorMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: jenisPenolakan == 'revisi' ? Colors.orange : Colors.red, 
                foregroundColor: Colors.white
              ),
              onPressed: () {
                if (controller.text.trim().isEmpty) {
                  setState(() => errorMessage = jenisPenolakan == 'revisi' ? 'Catatan Revisi Wajib Diisi!' : 'Catatan Penolakan Wajib Diisi!');
                  return;
                }
                Navigator.pop(ctx);
                context.read<PetugasProvider>().analisis(
                  id: permohonan.id,
                  keputusan: 'tolak',
                  catatan: controller.text.trim(),
                  fieldBermasalah: selectedDocs.isNotEmpty ? selectedDocs : null,
                  jenisPenolakan: jenisPenolakan,
                ).then((success) {
                  if (success) onSuccess();
                });
              },
              child: Text(jenisPenolakan == 'revisi' ? 'Minta Revisi' : 'Tolak Permanen'),
            ),
          ],
        ),
      ),
    );
  }
}
