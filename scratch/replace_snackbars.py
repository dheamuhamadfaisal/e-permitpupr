import os
import re

files_to_check = [
    r"lib/features/petugas/widgets/petugas_dialogs.dart",
    r"lib/features/petugas/screens/petugas_detail_screen.dart",
    r"lib/features/pemohon/screens/detail_permohonan_screen.dart",
    r"lib/features/operator/screens/kelola_informasi_layanan_screen.dart",
    r"lib/features/dashboard/screens/pemohon_dashboard_screen.dart",
    r"lib/features/profile/screens/profile_screen.dart"
]

import_statement = "import '../../../core/utils/api_exception.dart';"

def count_dirs_up(path):
    parts = path.split("/")
    return len(parts) - 2 # e.g. lib/features/profile/screens/profile_screen.dart -> 4 parts minus 1 for lib, but actually we just need correct relative path

for f in files_to_check:
    if not os.path.exists(f): continue
    
    with open(f, 'r', encoding='utf-8') as file:
        content = file.read()
    
    # Calculate relative import
    depth = f.count('/') - 1
    rel_import = "import '" + ("../" * depth) + "core/utils/api_exception.dart';"
    
    needs_import = False
    
    # Replacements
    # ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Catatan wajib diisi!')));
    # ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
    
    # Replace Warning / Error
    def replace_warning(match):
        return f"context.showWarningMessage({match.group(1)});"
    
    def replace_success(match):
        return f"context.showSuccessMessage({match.group(1)});"
        
    def replace_info(match):
        return f"context.showInfoMessage({match.group(1)});"

    new_content = content
    
    # Pattern 1: ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('...')));
    pattern_warning = r"ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*const SnackBar\(\s*content:\s*Text\((.*?)\)\s*\)\s*\);"
    
    # Actually let's just do generic replacements for known messages in the project
    
    if "ScaffoldMessenger.of(context).showSnackBar" in new_content:
        needs_import = True
        
        # Replace basic
        new_content = re.sub(r"ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*(?:const )?SnackBar\(\s*content:\s*Text\((.*?)\)\s*\)\s*\);", replace_warning, new_content)
        
        # Replace with background color
        new_content = re.sub(r"ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*(?:const )?SnackBar\(\s*content:\s*Text\((.*?)\),\s*backgroundColor:\s*Colors\.green.*?\)\s*\);", replace_success, new_content)
        
    # Inject import if needed
    if needs_import and "api_exception.dart" not in new_content:
        # Find the last import
        import_idx = new_content.rfind("import '")
        if import_idx != -1:
            end_of_line = new_content.find(";\n", import_idx)
            new_content = new_content[:end_of_line+2] + rel_import + "\n" + new_content[end_of_line+2:]
            
    if new_content != content:
        with open(f, 'w', encoding='utf-8') as file:
            file.write(new_content)
        print(f"Updated {f}")
