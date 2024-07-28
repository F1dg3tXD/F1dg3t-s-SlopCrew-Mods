# Define the web URL
$webUrl = "http://f1dg3t-xyz.duckdns.org/X/root/BRC/"

# Get the directory where the script is located
$userDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Ensure the path ends with a backslash
if (-Not $userDir.EndsWith("\")) {
    $userDir += "\"
}

# Define the path to the log file
$logFilePath = Join-Path -Path $userDir -ChildPath "sync_log.txt"

# List of files to ignore
$ignoreFiles = @("Updater.ps1", "Updater.ico", "Updater.exe", "sync_log.txt", "wget.exe")

# List of directories to ignore
$ignoreDirectories = @(
    "ModdingFolder/BRC-DripRemix/Characters", 
    "Bomb Rush Cyberfunk_Data", 
    "MonoBleedingEdge",
    "Bomb Rush Cyberfunk_Data/Managed",
    "Bomb Rush Cyberfunk_Data/Plugins",
    "Bomb Rush Cyberfunk_Data/Resources",
    "Bomb Rush Cyberfunk_Data/StreamingAssets",
    "Bomb Rush Cyberfunk_Data/Plugins/x86_64",
    "Bomb Rush Cyberfunk_Data/StreamingAssets/Assets",
    "Bomb Rush Cyberfunk_Data/StreamingAssets/Languages",
    "MonoBleedingEdge/EmbedRuntime",
    "MonoBleedingEdge/etc",
    "MonoBleedingEdge/etc/mono",
    "MonoBleedingEdge/etc/mono/2.0",
    "MonoBleedingEdge/etc/mono/4.0",
    "MonoBleedingEdge/etc/mono/mconfig",
    "MonoBleedingEdge/etc/mono/2.0/Browsers",
    "MonoBleedingEdge/etc/mono/4.0/Browsers",
    "MonoBleedingEdge/etc/mono/4.5/Browsers"
)

# Function to create a directory if it doesn't exist
function Create-Directory {
    param ($path)
    if (-Not (Test-Path -Path $path)) {
        New-Item -ItemType Directory -Path $path
    }
}

# Function to synchronize the directory structure recursively using wget
function Sync-Directory {
    param ($url, $localPath)

    # Create the local directory if it doesn't exist
    Create-Directory -path $localPath

    # Define the path to wget.exe
    $wgetBinary = Join-Path -Path $userDir -ChildPath "wget.exe"

    # Build wget arguments
    $wgetArgs = @(
        "--mirror",
        "--no-parent",
        "--no-check-certificate",
        "-nH",
        "--cut-dirs=3",
        "-P", "`"$localPath`"",
        "`"$url`""
    )

    # Start the wget process
    Write-Output "Running: $wgetBinary $wgetArgs"
    Start-Process -FilePath $wgetBinary -ArgumentList $wgetArgs -NoNewWindow -Wait -RedirectStandardOutput "$userDir\wget_output.txt" -RedirectStandardError "$userDir\wget_error.txt"
}

# Function to get a list of all files in a directory and subdirectories
function Get-LocalDirectoryFiles {
    param ($path)
    Get-ChildItem -Path $path -Recurse -File | ForEach-Object {
        [PSCustomObject]@{
            FullName = $_.FullName
            Name = $_.FullName.Substring($path.Length).Replace("\", "/")
        }
    }
}

# Function to get a list of all directories in a directory and subdirectories
function Get-LocalDirectoryPaths {
    param ($path)
    Get-ChildItem -Path $path -Recurse -Directory | ForEach-Object {
        [PSCustomObject]@{
            FullName = $_.FullName
            Name = $_.FullName.Substring($path.Length).Replace("\", "/")
        }
    }
}

# Function to check if a path is ignored
function Is-IgnoredPath {
    param ($path, $ignoreList)
    foreach ($ignore in $ignoreList) {
        if ($path.StartsWith($ignore)) {
            return $true
        }
    }
    return $false
}

# Get list of local files
$localFiles = Get-LocalDirectoryFiles -path $userDir

# Get list of local directories
$localDirectories = Get-LocalDirectoryPaths -path $userDir

# Sync the root web directory
Sync-Directory -url $webUrl -localPath $userDir

# Get list of local files again after sync
$localFilesAfterSync = Get-LocalDirectoryFiles -path $userDir

# Get list of local directories again after sync
$localDirectoriesAfterSync = Get-LocalDirectoryPaths -path $userDir

# Compare local files to web files and remove files that are no longer in the web directory
foreach ($localFile in $localFiles) {
    $relativePath = $localFile.Name.Replace("\", "/")
    if (-Not ($localFilesAfterSync.Name -contains $relativePath) -and -Not ($ignoreFiles -contains $localFile.Name) -and -Not (Is-IgnoredPath -path $relativePath -ignoreList $ignoreDirectories)) {
        Write-Output "Local file $($relativePath) no longer exists in the web directory. Removing..."
        Remove-Item -Path $localFile.FullName -Force
    }
}

# Compare local directories to web directories and remove directories that are no longer in the web directory
foreach ($localDirectory in $localDirectories) {
    $relativePath = $localDirectory.Name.Replace("\", "/")
    if (-Not ($localDirectoriesAfterSync.Name -contains ($relativePath + "/")) -and -Not (Is-IgnoredPath -path $relativePath -ignoreList $ignoreDirectories)) {
        Write-Output "Local directory $($relativePath) no longer exists in the web directory. Removing..."
        Remove-Item -Path $localDirectory.FullName -Recurse -Force
    }
}

Write-Output "File synchronization complete."
