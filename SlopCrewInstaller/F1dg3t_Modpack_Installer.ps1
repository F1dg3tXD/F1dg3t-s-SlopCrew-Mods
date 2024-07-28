Add-Type -AssemblyName PresentationFramework

# XAML definition of the UI
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="F1dg3t Modpack Installer" Height="400" Width="400">
    <Grid>
        <Grid.Background>
            <ImageBrush ImageSource="C:\Users\drama\Downloads\F1dg3t's slop crew installer\slopcrewinstall.png"/>
        </Grid.Background>
        <Label Content="Select Bomb Rush Cyberfunk.exe" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="20,20,0,0"/>
        <TextBox Name="PathTextBox" HorizontalAlignment="Left" VerticalAlignment="Top" Width="250" Margin="20,50,0,0"/>
        <Button Content="Browse" Name="BrowseButton" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75" Margin="280,50,0,0"/>
        <Button Content="Install" Name="InstallButton" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75" Margin="150,100,0,0"/>
        <ProgressBar Name="ProgressBar" HorizontalAlignment="Left" VerticalAlignment="Top" Width="350" Height="20" Margin="20,140,0,0"/>
    </Grid>
</Window>
"@

# Load XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Find controls
$textBox = $window.FindName("PathTextBox")
$browseButton = $window.FindName("BrowseButton")
$installButton = $window.FindName("InstallButton")
$progressBar = $window.FindName("ProgressBar")

# Browse button click event
$browseButton.Add_Click({
    $openFileDialog = New-Object Microsoft.Win32.OpenFileDialog
    $openFileDialog.Filter = "Executable Files (*.exe)|*.exe"
    $openFileDialog.Title = "Select Bomb Rush Cyberfunk.exe"
    
    if ($openFileDialog.ShowDialog() -eq $true) {
        $textBox.Text = $openFileDialog.FileName
    }
})

# Install button click event
$installButton.Add_Click({
    $exePath = $textBox.Text
    Write-Host "Selected path: $exePath"
    if (-not [string]::IsNullOrWhiteSpace($exePath) -and (Test-Path -Path $exePath)) {
        $targetDir = Split-Path -Path $exePath -Parent
        Write-Host "Target directory: $targetDir"

        $bepInExPath = Join-Path -Path $targetDir -ChildPath "BepInEx"
        if (Test-Path -Path $bepInExPath) {
            Rename-Item -Path $bepInExPath -NewName "BepInEx.bak"
            Write-Host "Renamed BepInEx to BepInEx.bak"
        }

        $sourceDataDir = "data"
        if (Test-Path -Path $sourceDataDir) {
            $progressBar.Value = 50
            Copy-Item -Path (Join-Path -Path $sourceDataDir -ChildPath "*") -Destination $targetDir -Recurse -Force
            $progressBar.Value = 100
            [System.Windows.MessageBox]::Show("Installation complete.", "Success", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
        } else {
            [System.Windows.MessageBox]::Show("Source data directory not found.", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
        }
    } else {
        [System.Windows.MessageBox]::Show("Invalid file path.", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
    }
})

# Show window
$window.ShowDialog()
