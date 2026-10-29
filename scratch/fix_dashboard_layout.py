import os
import re

files_to_check = [
    r"lib/features/dashboard/screens/admin_dashboard_screen.dart",
    r"lib/features/dashboard/screens/operator_dashboard_screen.dart",
    r"lib/features/dashboard/screens/petugas_dashboard_screen.dart",
    r"lib/features/dashboard/screens/verifikator_dashboard_screen.dart",
    r"lib/features/dashboard/screens/pemohon_dashboard_screen.dart"
]

for f in files_to_check:
    if not os.path.exists(f): continue
    
    with open(f, 'r', encoding='utf-8') as file:
        content = file.read()
    
    new_content = content
    
    # Replace padding in SingleChildScrollView
    # Usually padding: const EdgeInsets.all(20),
    new_content = re.sub(r"padding:\s*const\s*EdgeInsets\.all\(20\),", r"padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 220),", new_content)
    
    # Also replace childAspectRatio: 1.5 with childAspectRatio: 1.25
    # Be careful not to replace it if it's already 1.25
    new_content = re.sub(r"childAspectRatio:\s*1\.5,", r"childAspectRatio: 1.25,", new_content)
    
    if new_content != content:
        with open(f, 'w', encoding='utf-8') as file:
            file.write(new_content)
        print(f"Updated {f}")
