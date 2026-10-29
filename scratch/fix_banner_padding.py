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
    
    # We want to replace the padding inside the Container (Banner) back to EdgeInsets.all(20)
    # The banner is inside a Container with width: double.infinity
    # Pattern: 
    #                         Container(
    #                           width: double.infinity,
    #                           padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 220),
    
    new_content = re.sub(
        r"Container\(\s*width:\s*double\.infinity,\s*padding:\s*const\s*EdgeInsets\.only\(left:\s*20,\s*right:\s*20,\s*top:\s*20,\s*bottom:\s*220\),",
        r"Container(\n                          width: double.infinity,\n                          padding: const EdgeInsets.all(20),",
        content
    )
    
    if new_content != content:
        with open(f, 'w', encoding='utf-8') as file:
            file.write(new_content)
        print(f"Fixed {f}")
