# Read version from version.txt
$version = Get-Content -Path ".\version.txt" -Raw

# Trim any leading or trailing whitespace or newline characters from $version
$version = $version.Trim()

# Construct output executable filename with .exe extension
$outputFilename = ".\F1dg3t_Modpack_Installer_$version.exe"

# Define ps2exe command
$ps2exeCommand = "ps2exe .\F1dg3t_Modpack_Installer.ps1 $outputFilename -requireAdmin -icon .\icon.ico"

# Execute ps2exe command
Write-Host "Compiling installer version $version..."
Invoke-Expression $ps2exeCommand

Write-Host "Installer compiled: $outputFilename"

# Execute the compiled executable using the call operator &
#Write-Host "Running compiled installer..."
#& $outputFilename
