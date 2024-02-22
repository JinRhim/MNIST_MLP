import sys

# Check if the correct number of arguments is provided
if len(sys.argv) != 2:
    print("Usage: python change_width.py <input_file>")
    sys.exit(1)

input_file = sys.argv[1]

# Open the input file for reading
with open(input_file, 'r') as file:
    content = file.read()

# Replace all occurrences of 16'h with 512'h
new_content = content.replace("16'h", "512'h")

# Open the input file for writing with the updated content
with open(input_file, 'w') as file:
    file.write(new_content)

print(f"Widths changed from 16'h to 512'h in {input_file}")
