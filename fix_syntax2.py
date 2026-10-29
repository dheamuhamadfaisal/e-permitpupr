import re

file_path = "d:\\Project\\Kerja Praktik\\pupr_perizinan\\lib\\features\\admin\\screens\\admin_jenis_perizinan_screen.dart"

with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# Replace the try { with just return AlertDialog(
content = content.replace("          try {\n            return AlertDialog(", "          return AlertDialog(")

# Remove the extra `),` at line 270 (which is right before `actions: [`)
content = content.replace("""                ),
                ),
              ),
            ),
            actions: [""", """                ),
                ),
              ),
            actions: [""")

# Wait, let's just make sure we remove ANY catch blocks if they exist.
# The previous script failed, so there's no catch block.

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Fixed")
