import os

files_to_fix_dashboard = [
    r"d:\Project\Kerja Praktik\pupr_perizinan\lib\features\dashboard\screens\admin_dashboard_screen.dart",
    r"d:\Project\Kerja Praktik\pupr_perizinan\lib\features\dashboard\screens\petugas_dashboard_screen.dart",
    r"d:\Project\Kerja Praktik\pupr_perizinan\lib\features\dashboard\screens\operator_dashboard_screen.dart",
]

for fpath in files_to_fix_dashboard:
    if os.path.exists(fpath):
        with open(fpath, "r", encoding="utf-8") as f:
            content = f.read()
            
        old_block = """                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF3B4B72)),
                    ),
                  ),"""
                  
        new_block = """                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      count.toString(),
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF3B4B72), height: 1.0),
                      textAlign: TextAlign.center,
                    ),
                  ),"""
                  
        content = content.replace(old_block, new_block)
        with open(fpath, "w", encoding="utf-8") as f:
            f.write(content)
        print("Fixed dashboard badge in " + os.path.basename(fpath))

# Fix petugas_permohonan_screen.dart
fpath_petugas = r"d:\Project\Kerja Praktik\pupr_perizinan\lib\features\petugas\screens\petugas_permohonan_screen.dart"
if os.path.exists(fpath_petugas):
    with open(fpath_petugas, "r", encoding="utf-8") as f:
        content = f.read()
        
    old_block_pet = """                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppTheme.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      badgeCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),"""
                                  
    new_block_pet = """                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      badgeCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        height: 1.0,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),"""
                                  
    content = content.replace(old_block_pet, new_block_pet)
    with open(fpath_petugas, "w", encoding="utf-8") as f:
        f.write(content)
    print("Fixed badge in " + os.path.basename(fpath_petugas))
