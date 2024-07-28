Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$configFilePath = "BepInEx\config\SlopCrew.Plugin.cfg"
$gameExecutable = "Bomb Rush Cyberfunk.exe"

# Function to read config file into a hashtable
function Read-Config {
    $config = @{}
    $section = ""
    foreach ($line in Get-Content -Path $configFilePath) {
        if ($line -match '^\s*\[([^\]]+)\]') {
            $section = $matches[1]
            continue
        }
        if ($line -match '^\s*([^#][^=]+?)\s*=\s*(.*)') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            $config["$section.$key"] = $value
        }
    }
    return $config
}

# Function to write config back to file
function Write-Config ($config) {
    $output = ""
    $section = ""
    foreach ($line in Get-Content -Path $configFilePath) {
        if ($line -match '^\s*\[([^\]]+)\]') {
            $section = $matches[1]
            $output += "$line`n"
            continue
        }
        if ($line -match '^\s*([^#][^=]+?)\s*=\s*(.*)') {
            $key = $matches[1].Trim()
            $fullKey = "$section.$key"
            if ($config.ContainsKey($fullKey)) {
                $output += "$key = $($config[$fullKey])`n"
            } else {
                $output += "$line`n"
            }
        } else {
            $output += "$line`n"
        }
    }
    Set-Content -Path $configFilePath -Value $output
}

# Read the initial config
$config = Read-Config

# Create form
$form = New-Object System.Windows.Forms.Form
$form.Text = "SlopCrew Config Editor"
$form.Size = New-Object System.Drawing.Size(400, 600)  # Increased height for better spacing
$form.StartPosition = "CenterScreen"

# Create controls for each config option
$y = 10
$controls = @{}
foreach ($key in $config.Keys) {
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $key
    $label.Location = New-Object System.Drawing.Point(10, $y)
    $label.Size = New-Object System.Drawing.Size(180, 20)
    $form.Controls.Add($label)

    $textbox = New-Object System.Windows.Forms.TextBox
    $textbox.Text = $config[$key]
    $textbox.Location = New-Object System.Drawing.Point(200, $y)
    $textbox.Size = New-Object System.Drawing.Size(150, 20)
    $form.Controls.Add($textbox)

    $controls[$key] = $textbox
    $y += 30
}

# Adjust y position for buttons
$y += 20

# Save button
$saveButton = New-Object System.Windows.Forms.Button
$saveButton.Text = "Save"
$saveButton.Location = New-Object System.Drawing.Point(50, $y)
$saveButton.Size = New-Object System.Drawing.Size(125, 30)
$saveButton.Add_Click({
    foreach ($key in $controls.Keys) {
        $config[$key] = $controls[$key].Text
    }
    Write-Config $config
    [System.Windows.Forms.MessageBox]::Show("Configuration saved.", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
})
$form.Controls.Add($saveButton)

# Save and Start button
$startButton = New-Object System.Windows.Forms.Button
$startButton.Text = "Save and Start Game"
$startButton.Location = New-Object System.Drawing.Point(200, $y)
$startButton.Size = New-Object System.Drawing.Size(125, 30)
$startButton.Add_Click({
    foreach ($key in $controls.Keys) {
        $config[$key] = $controls[$key].Text
    }
    Write-Config $config
    Start-Process $gameExecutable
    $form.Close()
})
$form.Controls.Add($startButton)

# Run the form
[void] $form.ShowDialog()
