import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OperatorDetailScreen extends StatelessWidget {
  final int permohonanId;

  const OperatorDetailScreen({
    super.key,
    required this.permohonanId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Permohonan Bagian Umum'),
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
                'SOP Terbaru: Seluruh Validasi Berkas, Survey Lapangan, dan Penerbitan Permohonan Diproses oleh Validator Bidang Tata Ruang. Akun Bagian Umum Bertugas untuk Pengelolaan Berita dan Profil Dinas.',
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
