import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/api_exception.dart';
import '../../../core/widgets/global_empty_state.dart';
import '../../../core/widgets/global_error_bottom_sheet.dart';
import '../../../models/user_model.dart';
import '../../../providers/admin_provider.dart';
import 'create_edit_user_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  final List<Map<String, dynamic>> _roleOptions = [
    {'value': '', 'label': 'Semua Role', 'icon': Icons.group_outlined},
    {'value': 'admin', 'label': 'Admin', 'icon': Icons.admin_panel_settings_outlined},
    {'value': 'operator', 'label': 'Operator', 'icon': Icons.manage_accounts_outlined},
    {'value': 'petugas', 'label': 'Petugas', 'icon': Icons.engineering_outlined},
    {'value': 'pemohon', 'label': 'Pemohon', 'icon': Icons.person_outline},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData({int page = 1}) async {
    final provider = context.read<AdminProvider>();
    await provider.fetchUsers(page: page);
    if (!mounted) return;

    if (provider.error != null) {
      showGlobalErrorBottomSheet(
        context,
        errorMessage: provider.error!,
        onRetry: () => _fetchData(page: provider.userCurrentPage),
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onDeleteUser(UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus User'),
        content: Text('Apakah Anda Yakin Ingin Menghapus User "${user.name}"?'),
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

    final provider = context.read<AdminProvider>();
    final success = await provider.deleteUser(user.id);

    if (!mounted) return;

    if (success) {
      context.showSuccessMessage('User Berhasil Dihapus');
    } else if (provider.error != null) {
      context.showApiError(ApiException(message: provider.error!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pengguna (User)'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 110),
        child: FloatingActionButton(
          backgroundColor: AppTheme.goldColor,
          foregroundColor: AppTheme.primaryColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateEditUserScreen()),
            );
          },
          child: const Icon(Icons.person_add, size: 28),
        ),
      ),
      body: Column(
        children: [
          // Filter & Search
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari Nama / Email User...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              provider.setUserFilter(search: '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onChanged: (val) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      provider.setUserFilter(search: val.trim());
                    });
                  },
                  onSubmitted: (val) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    provider.setUserFilter(search: val.trim());
                  },
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _roleOptions.map((item) {
                    final isSelected = provider.userRoleFilter == item['value'];
                    final color = isSelected ? AppTheme.primaryColor : const Color(0xFF64748B);

                    return GestureDetector(
                      onTap: () => provider.setUserFilter(role: item['value'] as String),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryColor.withValues(alpha: 0.12)
                                      : Colors.grey.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  item['icon'] as IconData,
                                  color: color,
                                  size: 22,
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item['label'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // User List
          Expanded(
            child: provider.isUsersLoading && provider.users.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : provider.users.isEmpty
                        ? RefreshIndicator(
                            onRefresh: () => _fetchData(page: 1),
                            child: const GlobalEmptyState(
                              title: 'Belum Ada Pengguna',
                              subtitle: 'Tidak Ada Data Pengguna Yang Ditemukan.',
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => _fetchData(page: 1),
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 180),
                              itemCount: provider.users.length + (provider.userLastPage > 1 ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == provider.users.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 16, bottom: 24),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.chevron_left),
                                          onPressed: provider.userCurrentPage > 1
                                              ? () => _fetchData(page: provider.userCurrentPage - 1)
                                              : null,
                                        ),
                                        Text(
                                          'Halaman ${provider.userCurrentPage} dari ${provider.userLastPage}',
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.chevron_right),
                                          onPressed: provider.userCurrentPage < provider.userLastPage
                                              ? () => _fetchData(page: provider.userCurrentPage + 1)
                                              : null,
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                final user = provider.users[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppTheme.primaryColor,
                                      backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                                          ? NetworkImage(user.avatarUrl!)
                                          : null,
                                      child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                                          ? null
                                          : Text(
                                              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                    ),
                                    title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(user.isPemohon ? '${user.email} • ${user.phone ?? '-'}' : user.email),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                user.displayRole,
                                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  user.isActive ? Icons.check_circle : Icons.cancel,
                                                  size: 14,
                                                  color: user.isActive ? Colors.green : Colors.red,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  user.isActive ? 'Aktif' : 'Nonaktif',
                                                  style: TextStyle(fontSize: 11, color: user.isActive ? Colors.green : Colors.red),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryColor),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => CreateEditUserScreen(user: user)),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                                          onPressed: () => _onDeleteUser(user),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
