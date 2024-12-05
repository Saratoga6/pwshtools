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

#### Obfuscation
To obfuscate a file:
```powershell
.\ScriptName.ps1 /ob
