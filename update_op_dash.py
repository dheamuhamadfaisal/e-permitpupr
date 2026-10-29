import os

fpath = r"d:\Project\Kerja Praktik\pupr_perizinan\lib\features\dashboard\screens\operator_dashboard_screen.dart"

with open(fpath, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add import if not present
import_stmt = "import 'package:pupr_perizinan/features/operator/screens/kelola_informasi_layanan_screen.dart';\n"
if "kelola_informasi_layanan_screen.dart" not in content:
    # find last import
    idx = content.rfind("import '")
    end_idx = content.find(";\n", idx) + 2
    content = content[:end_idx] + import_stmt + content[end_idx:]

# 2. Change subtitle
content = content.replace(
    "'Operator Bagian Umum — Pemeriksaan Administrasi & Disposisi'",
    "'Operator Bagian Umum — Pusat Pengelolaan Informasi Layanan Publik'"
)

# 3. Add shortcut banner after subtitle padding
header_block = """                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Halo ${user?.name ?? 'Operator'}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Operator Bagian Umum — Pusat Pengelolaan Informasi Layanan Publik',
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                ),
                              ],
                            ),
                          ),"""

shortcut_block = """
                          // Shortcut Kelola Informasi Layanan
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const KelolaInformasiLayananScreen()),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF2C4375), Color(0xFF3B4B72)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2C4375).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.edit_document, color: Colors.white, size: 32),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Kelola Informasi Layanan Publik',
                                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Atur deskripsi, alur, dan persyaratan perizinan',
                                            style: TextStyle(color: Colors.white70, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),"""

content = content.replace(header_block, header_block + shortcut_block)

# 4. Change Statistik title
content = content.replace(
    "'Statistik Administrasi'",
    "'Pantauan Sistem Perizinan'"
)

# 5. Change stat labels
content = content.replace("label: 'Permohonan Masuk'", "label: 'Total Masuk'")
content = content.replace("label: 'Belum Diperiksa'", "label: 'Antrean'")
content = content.replace("label: 'Tidak Lengkap'", "label: 'Ditolak'")
content = content.replace("label: 'Lengkap'", "label: 'Selesai Adm'")
content = content.replace("label: 'Diteruskan'", "label: 'Diproses Teknis'")

# 6 & 7. Change list title
content = content.replace(
    "'Permohonan Perlu Diperiksa'",
    "'Aktivitas Permohonan Terbaru'"
)
content = content.replace(
    "'Tidak Ada Permohonan Yang Perlu Diperiksa'",
    "'Tidak Ada Aktivitas Permohonan Terbaru'"
)

with open(fpath, 'w', encoding='utf-8') as f:
    f.write(content)

print("Operator dashboard modified successfully!")
