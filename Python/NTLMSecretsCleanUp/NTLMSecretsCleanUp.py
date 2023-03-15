"""
    .SYNOPSIS
        Script that parses columns in a file so a cleaned username:hash can be given to hashing tools
    .DESCRIPTION
        Script original built to be used in conjuction with "Impacket/secretsdump.py" script. This script simply takes the core columns that are dumped after using the secrets file and
        splits it into 2 fields by default. The script has an option for manual filter, e.g. 1,4,99. Which would filter column 1, 4 and 99. 
        
        The script has a tab autocompletion feature which is what readline module is used for and the OS import is used in conjunction with that. Sys module is used to check if the correct 
        modules are installed and if not error out correctly.
        
        Default settings grab the first column "0" and 4th column "3" and does the seperation on a : by default as this is the standard output for the secretsdump.py script.
        
        This script can be used on any standard text readable file like a csv, log or csv to name a few.
        
    .NOTES
    Created: L Webb - Redshift Cyber Security
    Revision Date: 2023
    Version: 1.0
    License: MIT License
"""
import sys
import os
try:
    import pyreadline as readline
except ImportError:
    try:
        import readline
    except ImportError:
        print("Error: PyReadline or Readline module not found. Please install one of these modules to enable tab completion.")
        print("Error: For Windows Users, please install pyreadline3 'pip install pyreadline3'.")
        print()
        sys.exit(1)

# Define a completer function that returns a list of possible completions for the input text
def path_completer(text, state):
    dir_name, base = os.path.split(text)
    if dir_name == '':
        dir_name = '.'
    try:
        options = [os.path.join(dir_name, f) for f in os.listdir(dir_name) if os.path.normcase(f).startswith(os.path.normcase(base))]
    except FileNotFoundError:
        options = []
    if state < len(options):
        return options[state]
    else:
        return None

# Set the completer function to be used by the readline library
readline.set_completer_delims('\t')
readline.parse_and_bind('tab: complete')
readline.set_completer(path_completer)

#Looking for where the file is as well as where it should output too
input_file_path = input("Enter path to input file: ")
output_file_path = input("Enter path to output file: ")

# Prompt the user for the delimiter used to split the columns (if any)
delimiter = input("Enter delimiter used to split columns (or leave blank to use default ':'): ")
if delimiter == '':
    delimiter = ':'

# Prompt the user for the fields to filter (if any)
field_numbers = input("Enter field numbers to filter (comma-separated, or leave blank to use defaults): ")
if field_numbers == '':
    field_numbers = [0, 3]
else:
    field_numbers = [int(x.strip()) for x in field_numbers.split(',')]

# Open the input and output files, and clean up the data
with open(input_file_path, 'r') as f_in, open(output_file_path, 'w') as f_out:
    lines = f_in.readlines()
    for line in lines:
        fields = line.strip().split(delimiter)
        cleaned_fields = [fields[i] for i in field_numbers if i < len(fields)]
        cleaned_line = delimiter.join(cleaned_fields) + '\n'
        f_out.write(cleaned_line)

# Print completion message
print("Conversion complete. Output file path:", output_file_path)
