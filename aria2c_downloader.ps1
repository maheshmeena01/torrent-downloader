# ==============================================================================
# Universal PowerShell script with a GUI for aria2c.
# Version 5.1 - Fixed a variable scope issue preventing downloads from starting.
# ==============================================================================

# --- Function to Handle Prerequisite (aria2c) Installation ---
# This keeps the setup logic separate from the GUI logic.
function Install-Aria2c {
    param(
        [System.Windows.Forms.TextBox]$logBox,
        [Action[string]]$writeLogAction
    )

    $scriptRoot = $PSScriptRoot
    if (-not $scriptRoot) { $scriptRoot = Get-Location } # Fallback for ISE/direct execution
    $toolsDir = Join-Path -Path $scriptRoot -ChildPath "tools"
    $aria2Path = Join-Path -Path $toolsDir -ChildPath "aria2c.exe"

    # Define variables for the aria2c download.
    $aria2VersionNumber = "1.37.0"
    $aria2VersionName = "aria2-1.37.0"
    $aria2AssetName = "$($aria2VersionName)-win-64bit-build1.zip"

    # Check if aria2c.exe already exists.
    if (Test-Path -Path $aria2Path) {
        $writeLogAction.Invoke("Aria2c prerequisite found locally.")
        return $aria2Path
    }

    $writeLogAction.Invoke("----------------- SETUP -----------------")
    $writeLogAction.Invoke("aria2c not found. Attempting to download...")
    
    try {
        if (-not (Test-Path -Path $toolsDir)) {
            New-Item -ItemType Directory -Path $toolsDir | Out-Null
        }

        $downloadUrl = "https://github.com/aria2/aria2/releases/download/release-$($aria2VersionNumber)/$($aria2AssetName)"
        $zipPath = Join-Path -Path $toolsDir -ChildPath "aria2.zip"

        $writeLogAction.Invoke("Downloading from: $downloadUrl")
        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath

        $writeLogAction.Invoke("Extracting files...")
        Expand-Archive -Path $zipPath -DestinationPath $toolsDir -Force

        $unzippedSubfolder = Join-Path -Path $toolsDir -ChildPath "$($aria2VersionName)-win-64bit-build1"
        Get-ChildItem -Path $unzippedSubfolder | Move-Item -Destination $toolsDir
        Remove-Item -Path $unzippedSubfolder -Force -Recurse
        Remove-Item -Path $zipPath -Force

        if (-not (Test-Path -Path $aria2Path)) {
            throw "Aria2c setup failed. Executable not found after extraction."
        }

        $writeLogAction.Invoke("✅ Aria2c has been successfully set up.")
        $writeLogAction.Invoke("----------------------------------------")
        return $aria2Path
    }
    catch {
        $writeLogAction.Invoke("❌ ERROR: $($_.Exception.Message)")
        [System.Windows.Forms.MessageBox]::Show("An error occurred during setup: $($_.Exception.Message)", "Error", "OK", "Error")
        return $null
    }
}

# --- GUI Creation ---

# Load the required .NET assemblies for the GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the main form (window)
$form = New-Object System.Windows.Forms.Form
$form.Text = "Aria2c Downloader 5.1"
$form.Size = New-Object System.Drawing.Size(600, 620)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedSingle'
$form.MaximizeBox = $false
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$form.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)

# --- Create GUI Elements ---
$margin = 15

# --- Group 1: Download Details ---
$groupDetails = New-Object System.Windows.Forms.GroupBox
$groupDetails.Location = New-Object System.Drawing.Point($margin, $margin)
$groupDetails.Size = New-Object System.Drawing.Size(555, 190)
$groupDetails.Text = "Download Details"
$form.Controls.Add($groupDetails)

# 1.1 Download Name
$labelName = New-Object System.Windows.Forms.Label
$labelName.Location = New-Object System.Drawing.Point($margin, 30)
$labelName.Size = New-Object System.Drawing.Size(200, 20)
$labelName.Text = "Download Name (used for subfolder):"
$groupDetails.Controls.Add($labelName)

$textName = New-Object System.Windows.Forms.TextBox
$textName.Location = New-Object System.Drawing.Point($margin, 55)
$textName.Size = New-Object System.Drawing.Size(525, 20)
$textName.Text = "My_Download"
$groupDetails.Controls.Add($textName)

# 1.2 Download Type
$labelType = New-Object System.Windows.Forms.Label
$labelType.Location = New-Object System.Drawing.Point($margin, 95)
$labelType.Size = New-Object System.Drawing.Size(120, 20)
$labelType.Text = "Download Type:"
$groupDetails.Controls.Add($labelType)

$comboType = New-Object System.Windows.Forms.ComboBox
$comboType.Location = New-Object System.Drawing.Point($margin, 120)
$comboType.Size = New-Object System.Drawing.Size(150, 20)
$comboType.DropDownStyle = "DropDownList"
$comboType.Items.AddRange(@("URL / Magnet", "Torrent File"))
$comboType.SelectedIndex = 0
$groupDetails.Controls.Add($comboType)

# 1.3 Download Source
$labelSource = New-Object System.Windows.Forms.Label
$labelSource.Location = New-Object System.Drawing.Point(180, 95)
$labelSource.Size = New-Object System.Drawing.Size(350, 20)
$labelSource.Text = "Source (URL, Magnet Link, or Torrent File Path):"
$groupDetails.Controls.Add($labelSource)

$textSource = New-Object System.Windows.Forms.TextBox
$textSource.Location = New-Object System.Drawing.Point(180, 120)
$textSource.Size = New-Object System.Drawing.Size(255, 20)
$groupDetails.Controls.Add($textSource)

$btnBrowseSource = New-Object System.Windows.Forms.Button
$btnBrowseSource.Location = New-Object System.Drawing.Point(445, 119)
$btnBrowseSource.Size = New-Object System.Drawing.Size(95, 23)
$btnBrowseSource.Text = "Browse..."
$btnBrowseSource.Enabled = $false # Disabled by default
$groupDetails.Controls.Add($btnBrowseSource)

# --- Group 2: Configuration ---
$groupConfig = New-Object System.Windows.Forms.GroupBox
$groupConfig.Location = New-Object System.Drawing.Point($margin, 220)
$groupConfig.Size = New-Object System.Drawing.Size(555, 150)
$groupConfig.Text = "Configuration"
$form.Controls.Add($groupConfig)

# 2.1 Download Path
$labelPath = New-Object System.Windows.Forms.Label
$labelPath.Location = New-Object System.Drawing.Point($margin, 30)
$labelPath.Size = New-Object System.Drawing.Size(200, 20)
$labelPath.Text = "Download Location (Base Folder):"
$groupConfig.Controls.Add($labelPath)

$textPath = New-Object System.Windows.Forms.TextBox
$textPath.Location = New-Object System.Drawing.Point($margin, 55)
$textPath.Size = New-Object System.Drawing.Size(415, 20)
$textPath.Text = "$env:USERPROFILE\Downloads"
$groupConfig.Controls.Add($textPath)

$btnBrowsePath = New-Object System.Windows.Forms.Button
$btnBrowsePath.Location = New-Object System.Drawing.Point(445, 54)
$btnBrowsePath.Size = New-Object System.Drawing.Size(95, 23)
$btnBrowsePath.Text = "Browse..."
$groupConfig.Controls.Add($btnBrowsePath)

# 2.2 Speed Limit
$labelSpeed = New-Object System.Windows.Forms.Label
$labelSpeed.Location = New-Object System.Drawing.Point($margin, 95)
$labelSpeed.Size = New-Object System.Drawing.Size(350, 20)
$labelSpeed.Text = "Speed Limit (e.g., 5M or 500K). Blank = unlimited:"
$groupConfig.Controls.Add($labelSpeed)

$textSpeed = New-Object System.Windows.Forms.TextBox
$textSpeed.Location = New-Object System.Drawing.Point($margin, 115)
$textSpeed.Size = New-Object System.Drawing.Size(150, 20)
$groupConfig.Controls.Add($textSpeed)

# --- Start Button ---
$btnStart = New-Object System.Windows.Forms.Button
$btnStart.Location = New-Object System.Drawing.Point($margin, 385)
$btnStart.Size = New-Object System.Drawing.Size(555, 45)
$btnStart.Text = "Start Download"
$btnStart.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$btnStart.BackColor = [System.Drawing.Color]::FromArgb(40, 167, 69)
$btnStart.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($btnStart)

# --- Status Log Box ---
$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Location = New-Object System.Drawing.Point($margin, 445)
$logBox.Size = New-Object System.Drawing.Size(555, 110)
$logBox.Multiline = $true
$logBox.ScrollBars = "Vertical"
$logBox.ReadOnly = $true
$logBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$form.Controls.Add($logBox)


# --- GUI Event Handlers (The Logic) ---

# Global variable to hold the path to the executable
$script:aria2Path = $null

# Helper function for logging
function Write-Log {
    param($message)
    $timestamp = Get-Date -Format "HH:mm:ss"
    $logBox.AppendText("[$timestamp] $message`r`n")
}

# Event: When the form first loads
$form.Add_Load({
    Write-Log "Welcome! Initializing downloader..."
    # FIX: Use $script: scope to modify the script-level variable
    $script:aria2Path = Install-Aria2c -logBox $logBox -writeLogAction ${function:Write-Log}
})

# Event: When the user changes the download type
$comboType.add_SelectedIndexChanged({
    if ($comboType.SelectedItem -eq "Torrent File") {
        $btnBrowseSource.Enabled = $true
    } else {
        $btnBrowseSource.Enabled = $false
    }
})

# Event: When the user clicks the "Browse..." button for the source torrent
$btnBrowseSource.add_Click({
    $openDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openDialog.Title = "Select a torrent file"
    $openDialog.Filter = "Torrent Files (*.torrent)|*.torrent"
    if ($openDialog.ShowDialog() -eq "OK") {
        $textSource.Text = $openDialog.FileName
    }
})

# Event: When the user clicks the "Browse..." button for the download path
$btnBrowsePath.add_Click({
    $folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderDialog.Description = "Select a base directory for downloads"
    $folderDialog.SelectedPath = $textPath.Text
    if ($folderDialog.ShowDialog() -eq "OK") {
        $textPath.Text = $folderDialog.SelectedPath
    }
})

# Event: When the user clicks "Start Download"
$btnStart.add_Click({
    # Disable button to prevent multi-clicking
    $btnStart.Enabled = $false
    $logBox.AppendText("`r`n") # Add a separator

    # --- 1. Validation ---
    if ([string]::IsNullOrWhiteSpace($textName.Text) -or [string]::IsNullOrWhiteSpace($textSource.Text) -or [string]::IsNullOrWhiteSpace($textPath.Text)) {
        [System.Windows.Forms.MessageBox]::Show("Download Name, Source, and Path cannot be empty.", "Validation Error", "OK", "Warning")
        $btnStart.Enabled = $true
        return
    }

    # --- 2. Prerequisite Check ---
    if (-not $script:aria2Path) {
        Write-Log "❌ Cannot proceed without aria2c.exe. Check for errors above."
        $btnStart.Enabled = $true
        return
    }

    # --- 3. Prepare Download ---
    $downloadName = $textName.Text
    $downloadSource = $textSource.Text
    $speedLimit = $textSpeed.Text
    
    $sanitizedDownloadName = $downloadName -replace '[^a-zA-Z0-9_\-.]', '_'
    $downloadDirectory = Join-Path -Path $textPath.Text -ChildPath $sanitizedDownloadName
    
    try {
        if (-not (Test-Path -Path $downloadDirectory)) {
            New-Item -ItemType Directory -Path $downloadDirectory -Force | Out-Null
        }
        Write-Log "Download directory: $downloadDirectory"
    } catch {
        Write-Log "❌ ERROR: Could not create download directory. Check permissions."
        $btnStart.Enabled = $true
        return
    }

    # --- 4. Build aria2c command arguments ---
    $aria2Args = @(
        "--dir=`"$downloadDirectory`"",
        "--seed-time=0",
        "--bt-tracker=udp://tracker.opentrackr.org:1337/announce,udp://open.demonii.com:1337/announce,udp://tracker.openbittrent.com:6969/announce,udp://tracker.coppersurfer.tk:6969/announce",
        "`"$downloadSource`""
    )
    if (-not [string]::IsNullOrWhiteSpace($speedLimit)) {
        $aria2Args += "--max-download-limit=$speedLimit"
    }

    # --- 5. Launch Download ---
    Write-Log "🚀 Starting download in a new window..."
    
    # Start aria2c in a new console window so the GUI doesn't freeze.
    Start-Process -FilePath $script:aria2Path -ArgumentList $aria2Args
    
    Write-Log "✅ Download process initiated successfully."
    
    # Re-enable the button for the next download
    $btnStart.Enabled = $true
})


# --- Show the GUI ---
# This line must be at the end. It displays the form and waits for it to be closed.
$form.ShowDialog() | Out-Null
