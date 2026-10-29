import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/permohonan_history_model.dart';

/// Component Timeline Riwayat Status Permohonan
class StatusTimeline extends StatelessWidget {
  final List<PermohonanHistoryModel> histories;

  const StatusTimeline({
    super.key,
    required this.histories,
  });

  @override
  Widget build(BuildContext context) {
    if (histories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('Belum ada riwayat status', style: TextStyle(color: Colors.grey)),
      );
    }

    return Column(
      children: List.generate(histories.length, (index) {
        final item = histories[index];
        final isFirst = index == 0;
        final isLast = index == histories.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline Icon & Line Connection (Tanpa IntrinsicHeight agar layout tidak crash)
            SizedBox(
              width: 24,
              child: Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isFirst ? AppTheme.primaryColor : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFirst ? Icons.check : Icons.circle,
                      size: 14,
                      color: isFirst ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 44,
                      color: Colors.grey.shade300,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Text Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.statusBaru.toUpperCase().replaceAll('_', ' '),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isFirst ? AppTheme.primaryColor : const Color(0xFF1E293B),
                      ),
                    ),
                    if (item.createdAt.isNotEmpty)
                      Text(
                        item.createdAt,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    if (item.catatan != null && item.catatan!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.catatan!,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
