import 'package:flutter/material.dart';

class GlobalEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final Widget? actionButton;

  const GlobalEmptyState({
    super.key,
    this.title = 'Belum Ada Aktivitas',
    this.subtitle = 'Saat Ini Belum Ada Data Untuk Ditampilkan.',
    this.imagePath = 'assets/images/belum ada permohonan.png',
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double minHeight = constraints.maxHeight == double.infinity ? 0 : constraints.maxHeight;
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: minHeight,
            ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  imagePath,
                  width: 180,
                  fit: BoxFit.contain,
                ),
                Transform.translate(
                  offset: const Offset(0, -45),
                  child: Column(
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      if (actionButton != null) ...[
                        const SizedBox(height: 24),
                        actionButton!,
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 80), // Adjusted bottom space
              ],
            ),
          ),
        ),
        );
      },
    );
  }
}
