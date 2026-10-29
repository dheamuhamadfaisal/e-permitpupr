import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VerifikasiDetailScreen extends StatelessWidget {
  final int permohonanId;

  const VerifikasiDetailScreen({
    super.key,
    required this.permohonanId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Permohonan Verifikator'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 64, color: Color(0xFF64748B)),
              const SizedBox(height: 16),
              const Text(
                'Alur Validasi Diproses oleh Bidang Tata Ruang',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'SOP Terbaru: Seluruh Validasi Berkas, Survey Lapangan, Analisis Kesesuaian Tata Ruang, dan Penerbitan Permohonan Perizinan KRK & Siteplan Diproses Langsung oleh Validator Bidang Tata Ruang PUPR Kabupaten Garut.',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali ke Dashboard'),
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
