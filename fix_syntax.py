import re

file_path = "d:\\Project\\Kerja Praktik\\pupr_perizinan\\lib\\features\\admin\\screens\\admin_jenis_perizinan_screen.dart"

with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# We need to find the `} catch (e, stack) {` that was wrongly inserted
# and completely remove it, restoring the file.

# Look at the end of the file or the end of showFormDialog.
# The error says line 342 has `}` issues.
# I will just write a regex to clean up everything from `} catch (e, stack) {`
# to the end of _showFormDialog and replace it with the correct closing.

pattern = r"\}\s*catch\s*\(e,\s*stack\)\s*\{[\s\S]*?\}\s*\},"
replacement = "},"

content = re.sub(pattern, replacement, content)

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Done")
