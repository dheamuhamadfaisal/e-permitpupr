import 'package:flutter/material.dart';
import '../../../models/permohonan_model.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final PermohonanModel? permohonan;

  const StatusBadge({
    super.key,
    required this.status,
    this.permohonan,
  });

  @override
  Widget build(BuildContext context) {
    final color = permohonan?.statusColor ?? _getColor(status);
    final label = permohonan?.statusLabel ?? _getLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Color _getColor(String s) {
    if (s == 'draft') return Colors.grey;
    if (s == 'disetujui' || s == 'selesai') return Colors.green;
    if (s == 'ditolak') return Colors.red;
    if (s == 'tidak_lengkap' || s == 'revisi') return Colors.orange;
    return Colors.blue;
  }

  String _getLabel(String s) {
    return s.toUpperCase().replaceAll('_', ' ');
  }
}
