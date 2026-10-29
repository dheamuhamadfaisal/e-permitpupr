import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/petugas_provider.dart';
import '../../../providers/jenis_perizinan_provider.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/api_exception.dart';
import '../../../core/widgets/global_empty_state.dart';

class PetugasArsipScreen extends StatefulWidget {
  const PetugasArsipScreen({super.key});

  @override
  State<PetugasArsipScreen> createState() => _PetugasArsipScreenState();
}

class _PetugasArsipScreenState extends State<PetugasArsipScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PetugasProvider>();
      final jenisProvider = context.read<JenisPerizinanProvider>();
      
      jenisProvider.fetchJenisPerizinan();
      
      // Default: jenis = '', kategori = 'survei', periode = 'semua'
      provider.setArsipFilter(jenis: '', kategori: 'survei', periode: 'semua');
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _downloadFile(String filePath) async {
    final url = '${ApiConstants.baseUrl}/storage/$filePath';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        context.showWarningMessage('Tidak dapat membuka file dokumen.');
      }
    }
  }

  Widget _buildFilterHeader(PetugasProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              // Segmented Control untuk Kategori (Survei vs Terbit)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildKategoriButton(provider, 'Survei', 'survei'),
                    _buildKategoriButton(provider, 'Surat Terbit', 'terbit'),
                  ],
                ),
              ),
              
              // Dropdown Periode
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: provider.arsipPeriode,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primaryColor),
                    style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        provider.setArsipFilter(periode: newValue);
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 'hari_ini', child: Text('Hari Ini')),
                      DropdownMenuItem(value: 'minggu_ini', child: Text('7 Hari Terakhir')),
                      DropdownMenuItem(value: 'bulan_ini', child: Text('30 Hari Terakhir')),
                      DropdownMenuItem(value: 'semua', child: Text('Semua Waktu')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKategoriButton(PetugasProvider provider, String label, String value) {
    final isSelected = provider.arsipKategori == value;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          provider.setArsipFilter(kategori: value);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PetugasProvider>();
    final jenisProvider = context.watch<JenisPerizinanProvider>();
    
    final tabLength = jenisProvider.items.length + 1;
    
    return DefaultTabController(
      length: tabLength,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC), // Modern sleek background
      appBar: AppBar(
        title: const Text('Arsip & Pencatatan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.textPrimary)),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: TabBar(
              onTap: (index) {
                final selectedJenis = index == 0 ? '' : jenisProvider.items[index - 1].kode;
                if (provider.arsipJenis != selectedJenis) {
                  provider.setArsipFilter(jenis: selectedJenis);
                }
              },
              isScrollable: true,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.grey.shade500,
              indicatorColor: AppTheme.primaryColor,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              tabs: [
                const Tab(text: 'Semua'),
                ...jenisProvider.items.map((j) => Tab(text: j.kode)),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.fetchArsip(page: 1),
        color: AppTheme.primaryColor,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildFilterHeader(provider),
            ),
            if (provider.isArsipLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
              )
            else if (provider.error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(provider.error!, style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              )
            else if (provider.arsipItems.isEmpty)
              const SliverFillRemaining(
                child: GlobalEmptyState(
                  title: 'Tidak Ada Arsip',
                  subtitle: 'Belum ada data arsip pada periode ini.',
                  imagePath: 'assets/images/no arsip.png',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = provider.arsipItems[index];
                      final isSurvei = provider.arsipKategori == 'survei';
                      final isKRK = item.jenisPerizinan?.kode == 'KRK';
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              // Left Accent Line
                              Positioned(
                                left: 0,
                                top: 0,
                                bottom: 0,
                                width: 4,
                                child: Container(color: isKRK ? Colors.blueAccent : Colors.orangeAccent),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header: Kategori & Tanggal
                                    Wrap(
                                      alignment: WrapAlignment.spaceBetween,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: (isKRK ? Colors.blueAccent : Colors.orangeAccent).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                isKRK ? Icons.domain_rounded : Icons.map_rounded,
                                                size: 12,
                                                color: isKRK ? Colors.blueAccent : Colors.orangeAccent,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                item.jenisPerizinan?.nama ?? '-',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: isKRK ? Colors.blueAccent : Colors.orangeAccent,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(item.updatedAt)),
                                          style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    // Title & Name
                                    Text(
                                      item.nomorPermohonan,
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 15),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.person_outline_rounded, size: 16, color: Colors.grey.shade600),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            item.pemohon?.name ?? 'Pemohon Tidak Diketahui',
                                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    
                                    // Content Area
                                    if (isSurvei) ...[
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: const Color(0xFFE2E8F0)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Catatan Survei:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                                            const SizedBox(height: 4),
                                            Text(
                                              item.hasilSurvey ?? "-",
                                              style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      if (item.fileHasilSurvey != null)
                                        SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton.icon(
                                            onPressed: () => _downloadFile(item.fileHasilSurvey!),
                                            icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                                            label: const Text('Unduh Berkas Survei (PDF)', style: TextStyle(fontSize: 12)),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppTheme.textPrimary,
                                              side: BorderSide(color: Colors.grey.shade300),
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                          ),
                                        ),
                                    ] else ...[
                                      if (item.fileSuratTerbit != null)
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () => _downloadFile(item.fileSuratTerbit!),
                                            icon: const Icon(Icons.cloud_download_rounded, color: Colors.white, size: 18),
                                            label: const Text('Unduh Surat Izin Terbit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppTheme.primaryColor,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                          ),
                                        )
                                      else
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
                                              SizedBox(width: 8),
                                              Expanded(child: Text('Surat Terbit belum diunggah / tersedia', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold))),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: provider.arsipItems.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }
}
