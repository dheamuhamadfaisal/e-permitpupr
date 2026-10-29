import re

file_path = "d:\\Project\\Kerja Praktik\\pupr_perizinan\\lib\\features\\admin\\screens\\admin_jenis_perizinan_screen.dart"

with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# Replace `builder: (context, setState) {` followed by `return AlertDialog(`
# with the try-catch block

pattern = r"(builder: \(context, setState\) \{)(\s*)(return AlertDialog\()"
replacement = r"""\1\2try {\n\2  \3"""

content = re.sub(pattern, replacement, content)

# Now we need to find the `);` that closes `AlertDialog` and append `} catch (e, stack) { return AlertDialog(...); }`
# The `AlertDialog` starts at `return AlertDialog(`
# The closing `);` is before `actions: [`? No, `actions: [` is inside `AlertDialog`.
# So it ends after `actions: [ ... ],` -> `);`

pattern_end = r"(\s+)(\],)(\s+)\);(\s+\},\s+\),\s+\);)"
replacement_end = r"""\1\2\3);\4""" # Wait, this doesn't add catch. Let's do it manually.

# Let's split by lines and count brackets for `AlertDialog`? 
# Or just replace the exact end string.

end_str = """                ),
              ],
            );
        },
      ),
    );"""

new_end_str = """                ),
              ],
            );
          } catch (e, stack) {
            return AlertDialog(
              title: const Text('Crash Detected', style: TextStyle(color: Colors.red)),
              content: SingleChildScrollView(child: Text('$e\\n\\n$stack')),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Tutup'))
              ]
            );
          }
        },
      ),
    );"""

content = content.replace(end_str, new_end_str)

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Added try-catch")
