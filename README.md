# Text Obfuscation Tool

This PowerShell script provides a simple way to:

- **Obfuscate**: Replace sensitive text in files with random variables to mask PII or other sensitive information.
- **Unobfuscate**: Restore the original text using a mapping of these variables back to the original content.

## Purpose

The primary goal of this script is to help in securing documents or scripts by obfuscating identifiable information before sharing or processing, and then allowing for the information to be unobfuscated when necessary. This can be particularly useful in environments where data privacy is critical or when you need to perform operations on data without exposing its true content.

## Usage

### Requirements
- PowerShell 3.0 or higher

### Script Execution

Preparation
Create a new csv filre mapping.csv and alter the  path  you find in the script to agree with your mapping.csv
File Structure
mapping.csv: Initially contains the original text strings to be obfuscated. After obfuscation, 
this file is updated with the obfuscated variables format:
< Original String Pattern your want to obfuscate in the file no quote no commas>
After you obfuscated your input file, this  mapping.csv  will then format: 
"A","B"
"Original String Pattern","Obfuscated Variable"

#### Execution
To obfuscate a file:
```powershell  use pwsh cms line or ide
1 cmd line
.\ScriptName.ps1 /ob   # obfiscate
.\ScriptName.ps1 /unob  # unobfuscate
2 ide
or no argument
Select text in a IDE , run  debug mode , answer options 1 to obfiscate or 2 unobfuscate,
then paste path to the file.

Version
0.01

License
This project is released under the MIT License (LICENSE).



