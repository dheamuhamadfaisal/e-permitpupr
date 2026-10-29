import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void showGlobalErrorBottomSheet(
  BuildContext context, {
  required String errorMessage,
  required VoidCallback onRetry,
}) {
  final isNetwork = errorMessage.toLowerCase().contains('koneksi') ||
      errorMessage.toLowerCase().contains('jaringan') ||
      errorMessage.toLowerCase().contains('timeout');

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(Icons.close, color: Colors.black87, size: 22),
              ),
            ),
            // Image
            Center(
              child: Image.asset(
                isNetwork
                    ? 'assets/images/tidak ada jaringan.png'
                    : 'assets/images/error_pekerja.png',
                width: 180,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.error_outline_rounded,
                  size: 80,
                  color: Color(0xFFCBD5E1),
                ),
              ),
            ),
            const SizedBox(height: 0),
            // Title
            const Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            // Subtitle
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  isNetwork
                      ? 'Mohon Cek Koneksi Internet Anda dan Coba Kembali'
                      : errorMessage,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.pop();
                  onRetry();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003399),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
