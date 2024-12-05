<#
.SYNOPSIS
    A PowerShell script for obfuscating and unobfuscating text files based on a CSV mapping.

.DESCRIPTION
    This script provides functionality to:
    - Obfuscate sensitive information in text files by replacing patterns with random variables.
    - Unobfuscate these files back to their original content using a mapping file.

    The script reads from a CSV file (`mapping.csv`) which should initially contain the original text 
    patterns. After obfuscation, this file is updated with the corresponding obfuscated variables.

.PARAMETER operation
    Optional switch to specify the operation:
    - /ob for obfuscation
    - /unob for unobfuscation
    If no operation is specified, a menu will prompt the user to select an option.

.EXAMPLE
    .\ScriptName.ps1 /ob
    Obfuscates a file based on user input for the file path.

.EXAMPLE
    .\ScriptName.ps1 /unob
    Unobfuscates a previously obfuscated file.

.EXAMPLE
    .\ScriptName.ps1
    Displays a menu for choosing between obfuscation and unobfuscation.

.VERSION
    0.03
#>
param(
    [string]$operation = ""
)

function Generate-RandomString {
    param (
        [int]$length = 8
    )
    $characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    $randomString = -join ($characters[(Get-Random -Count $length -InputObject $(0..($characters.Length-1)))] | Get-Random -Count $length)
    return "VAR_" + $randomString
}

function Read-FileContent {
    param(
        [string]$path
    )
    try {
        $path = $path.Trim('"')
        $content = [System.Text.StringBuilder]::new()
        $reader = [System.IO.StreamReader]::new($path, [System.Text.Encoding]::UTF8)
        while ($null -ne ($line = $reader.ReadLine())) {
            [void]$content.AppendLine($line)
        }
        $reader.Close()
        return $content.ToString()
    } catch {
        Write-Error "Error reading file content: $_"
        return $null
    }
}

function Obfuscate-Text {
    param(
        [string]$filePath,
        [hashtable]$mapping
    )
    $filePath = $filePath.Trim('"')
    $content = Read-FileContent -path $filePath
    if ($null -eq $content) { return }

    foreach ($key in $mapping.Keys) {
        $content = $content -replace [regex]::Escape($key), $mapping[$key]
    }

    if (Test-Path $filePath -PathType Leaf) {
        $fileNameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($filePath)
        $outputFilePath = Join-Path (Split-Path $filePath -Parent) ($fileNameWithoutExt + ".obfuscated.txt")
        try {
            $content | Out-File -FilePath $outputFilePath -Encoding utf8 -ErrorAction Stop
            Write-Output $content
        } catch {
            Write-Error "Error writing obfuscated content to file: $_"
        }
    } else {
        Write-Error "The file path provided does not exist."
    }
}

function Unobfuscate-Text {
    param(
        [string]$filePath,
        [hashtable]$mapping
    )
    $filePath = $filePath.Trim('"')
    $content = Read-FileContent -path $filePath
    if ($null -eq $content) { return }

    # Create a reverse mapping
    $reverseMapping = @{}
    foreach ($key in $mapping.Keys) {
        $reverseMapping[$mapping[$key]] = $key
    }

    # Use regex replacement for better accuracy
    foreach ($value in $reverseMapping.Keys) {
        $content = $content -replace [regex]::Escape($value), $reverseMapping[$value]
    }

    # Additional regex patterns to ensure all edge cases are covered
    foreach ($value in $reverseMapping.Keys) {
        $content = $content -replace [regex]::Escape("(?<=\s|^)$value(?=\s|$)"), $reverseMapping[$value]
        $content = $content -replace [regex]::Escape("$value$"), $reverseMapping[$value]  # For end of line cases
    }

    if (Test-Path $filePath -PathType Leaf) {
        $fileNameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($filePath)
        $outputFilePath = Join-Path (Split-Path $filePath -Parent) ($fileNameWithoutExt + ".unobfuscated.txt")
        try {
            $content | Out-File -FilePath $outputFilePath -Encoding utf8 -ErrorAction Stop
            Write-Output $content
        } catch {
            Write-Error "Error writing unobfuscated content to file: $_"
        }
    } else {
        Write-Error "The file path provided does not exist."
    }
}

function Show-Menu {
    Write-Host "Please select an option:"
    Write-Host "1. Obfuscate"
    Write-Host "2. Unobfuscate"
    $choice = Read-Host "Enter your choice"
    return $choice
}

# Read the mapping file
$mappingPath = "C:\scripts\powershell\obfuscate\mapping.csv"
$mapping = @{}
try {
    Import-Csv -Path $mappingPath -Header "A", "B" -Encoding UTF8 | ForEach-Object {
        if (-not $_.B) {
            $randomName = Generate-RandomString
            $mapping[$_.A] = $randomName
        } else {
            $mapping[$_.A] = $_.B
        }
    }
} catch {
    Write-Error "Failed to read or process mapping file: $_"
}

# Function to check if the content of a file has changed
function HasContentChanged {
    param(
        [string]$FilePath,
        [hashtable]$NewContent
    )
    $oldContent = Import-Csv -Path $FilePath -Header "A", "B" -Encoding UTF8
    $oldContentHash = @{}
    foreach ($row in $oldContent) {
        $oldContentHash[$row.A] = $row.B
    }
    foreach ($key in $NewContent.Keys) {
        if (-not $oldContentHash.ContainsKey($key) -or $oldContentHash[$key] -ne $NewContent[$key]) {
            return $true
        }
    }
    return $false
}

# Save the updated mapping back to CSV if it was changed
if (HasContentChanged -FilePath $mappingPath -NewContent $mapping) {
    $mappingData = $mapping.GetEnumerator() | ForEach-Object {
        [PSCustomObject]@{A = $_.Key; B = $_.Value}
    }
    try {
        $mappingData | Export-Csv -Path $mappingPath -NoTypeInformation -Encoding UTF8 -ErrorAction Stop
    } catch {
        Write-Error "Failed to update mapping file: $_"
    }
}

if ($operation -eq "/ob") {
    $fileToObfuscate = (Read-Host "Enter the path to the file you want to obfuscate").Trim('"')
    Obfuscate-Text -filePath $fileToObfuscate -mapping $mapping
} elseif ($operation -eq "/unob") {
    $fileToUnobfuscate = (Read-Host "Enter the path to the obfuscated file to unobfuscate").Trim('"')
    Unobfuscate-Text -filePath $fileToUnobfuscate -mapping $mapping
} else {
    $menuChoice = Show-Menu
    switch ($menuChoice) {
        '1' {
            $fileToObfuscate = (Read-Host "Enter the path to the file you want to obfuscate").Trim('"')
            Obfuscate-Text -filePath $fileToObfuscate -mapping $mapping
        }
        '2' {
            $fileToUnobfuscate = (Read-Host "Enter the path to the obfuscated file to unobfuscate").Trim('"')
            Unobfuscate-Text -filePath $fileToUnobfuscate -mapping $mapping
        }
        default {
            Write-Output "Invalid choice. Exiting script."
        }
    }
}
