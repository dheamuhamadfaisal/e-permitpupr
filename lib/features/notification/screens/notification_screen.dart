import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/global_empty_state.dart';
import '../../../core/widgets/global_error_bottom_sheet.dart';
import '../../../models/notification_model.dart';
import '../../../providers/notification_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData(page: 1);
    });
  }

  Future<void> _fetchData({int page = 1}) async {
    final provider = context.read<NotificationProvider>();
    await provider.fetchNotifications(page: page);
    if (!mounted) return;

    if (provider.error != null) {
      showGlobalErrorBottomSheet(
        context,
        errorMessage: provider.error!,
        onRetry: () => _fetchData(page: page),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi Saya'),
        actions: [
          if (provider.unreadCount > 0)
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Tandai Semua'),
              onPressed: () => provider.markAllAsRead(),
            ),
        ],
      ),
      body: provider.isLoading && provider.items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.items.isEmpty
                  ? RefreshIndicator(
                      onRefresh: () => _fetchData(page: 1),
                      child: const GlobalEmptyState(
                        title: 'Belum Ada Notifikasi',
                        subtitle: 'Anda Tidak Memiliki Notifikasi Terbaru.',
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _fetchData(page: 1),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.items.length,
                        itemBuilder: (context, index) {
                          final item = provider.items[index];
                          return _buildNotificationTile(context, item, provider);
                        },
                      ),
                    ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    NotificationModel item,
    NotificationProvider provider,
  ) {
    return Card(
      color: item.isRead ? Colors.white : AppTheme.primaryColor.withValues(alpha: 0.05),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () {
          if (!item.isRead) {
            provider.markAsRead(item.id);
          }
          if (item.permohonanId != null) {
            context.push('/permohonan/${item.permohonanId}');
          }
        },
        leading: CircleAvatar(
          backgroundColor: item.isRead
              ? const Color(0xFFE2E8F0)
              : AppTheme.primaryColor.withValues(alpha: 0.15),
          child: Icon(
            Icons.notifications_active_outlined,
            color: item.isRead ? const Color(0xFF64748B) : AppTheme.primaryColor,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
            if (!item.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.message,
                style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 4),
              Text(
                item.createdAt,
                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
