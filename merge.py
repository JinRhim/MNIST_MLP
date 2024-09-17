import os

# Specify the files to be excluded from merging
# excluded_files = ("int_bias1_bram.sv", "int_biass2_bram.sv", "int_weight1_bram.sv", "int_weight2_bram.sv")
excluded_files = ""

# Define the output file where merged content will be saved
output_file = "merged_output.txt"

def clean_content(content):
    """Remove all tabs and newlines from the content."""
    return content.replace('\t', '').replace('\n', '')

def should_skip_line(line):
    """Determine if the line contains a memory assignment and should be skipped."""
    return line.strip().startswith('mem[')

def merge_files():
    # List all .sv files in the current directory excluding the specified files
    files = [f for f in os.listdir('.') if f.endswith('.sv') and f not in excluded_files]
    
    # Open the output file in write mode
    with open(output_file, 'w') as outfile:
        # Process each file
        for file in files:
            # Open the file in read mode
            with open(file, 'r') as infile:
                # Read the file line by line, skipping memory lines
                for line in infile:
                    if not should_skip_line(line):
                        # Clean and write the non-skipped lines to the output file
                        cleaned_line = clean_content(line)
                        outfile.write(cleaned_line)

# Call the function to merge the files
merge_files()
