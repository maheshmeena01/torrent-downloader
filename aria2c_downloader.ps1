# ==============================================================================
# Universal PowerShell script with a GUI for aria2c.
# Version 4.0 - Rebuilt with a Windows Forms GUI for user-friendly operation.
# ==============================================================================

# --- Function to Handle Prerequisite (aria2c) Installation ---
# This keeps the setup logic separate from the GUI logic.
function Install-Aria2c {
    param(
        [System.Windows.Forms.TextBox]$logBox
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
        $logBox.AppendText("✅ Aria2c prerequisite found locally.`r`n")
        return $aria2Path
    }

    $logBox.AppendText("----------------- SETUP -----------------`r`n")
    $logBox.AppendText("aria2c not found. Attempting to download...`r`n")
    
    try {
        if (-not (Test-Path -Path $toolsDir)) {
            New-Item -ItemType Directory -Path $toolsDir | Out-Null
        }

        $downloadUrl = "https://github.com/aria2/aria2/releases/download/release-$($aria2VersionNumber)/$($aria2AssetName)"
        $zipPath = Join-Path -Path $toolsDir -ChildPath "aria2.zip"

        $logBox.AppendText("Downloading from: $downloadUrl`r`n")
        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath

        $logBox.AppendText("Extracting files...`r`n")
        Expand-Archive -Path $zipPath -DestinationPath $toolsDir -Force

        $unzippedSubfolder = Join-Path -Path $toolsDir -ChildPath "$($aria2VersionName)-win-64bit-build1"
        Get-ChildItem -Path $unzippedSubfolder | Move-Item -Destination $toolsDir
        Remove-Item -Path $unzippedSubfolder -Force -Recurse
        Remove-Item -Path $zipPath -Force

        if (-not (Test-Path -Path $aria2Path)) {
            throw "Aria2c setup failed. Executable not found after extraction."
        }

        $logBox.AppendText("✅ Aria2c has been successfully set up.`r`n")
        $logBox.AppendText("----------------------------------------`r`n")
        return $aria2Path
    }
    catch {
        $logBox.AppendText("❌ ERROR: $($_.Exception.Message)`r`n")
        [System.Windows.Forms.MessageBox]::Show("An error occurred during setup: $($_.Exception.Message)", "Error", "OK", "Error")
        return $null
    }
}

# --- GUI Creation ---

# Load the required .NET assemblies for the GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the main form (window)
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text = "Aria2c Downloader GUI"
$main_form.Size = New-Object System.Drawing.Size(550, 520)
$main_form.StartPosition = "CenterScreen"
$main_form.FormBorderStyle = 'FixedSingle'
$main_form.MaximizeBox = $false

# --- Create GUI Elements ---

# 1. Download Name
$label_name = New-Object System.Windows.Forms.Label
$label_name.Location = New-Object System.Drawing.Point(20, 20)
$label_name.Size = New-Object System.Drawing.Size(200, 20)
$label_name.Text = "Download Name (for folder):"
$main_form.Controls.Add($label_name)

$txt_name = New-Object System.Windows.Forms.TextBox
$txt_name.Location = New-Object System.Drawing.Point(20, 45)
$txt_name.Size = New-Object System.Drawing.Size(490, 20)
$txt_name.Text = "My_Download"
$main_form.Controls.Add($txt_name)

# 2. Download Type
$label_type = New-Object System.Windows.Forms.Label
$label_type.Location = New-Object System.Drawing.Point(20, 85)
$label_type.Size = New-Object System.Drawing.Size(120, 20)
$label_type.Text = "Download Type:"
$main_form.Controls.Add($label_type)

$combo_type = New-Object System.Windows.Forms.ComboBox
$combo_type.Location = New-Object System.Drawing.Point(20, 110)
$combo_type.Size = New-Object System.Drawing.Size(150, 20)
$combo_type.DropDownStyle = "DropDownList" # Prevents user from typing custom text
$combo_type.Items.AddRange(@("URL / Magnet", "Torrent File"))
$combo_type.SelectedIndex = 0
$main_form.Controls.Add($combo_type)

# 3. Download Source (URL, Magnet, or File Path)
$label_source = New-Object System.Windows.Forms.Label
$label_source.Location = New-Object System.Drawing.Point(20, 150)
$label_source.Size = New-Object System.Drawing.Size(300, 20)
$label_source.Text = "Source (URL, Magnet Link, or Torrent File Path):"
$main_form.Controls.Add($label_source)

$txt_source = New-Object System.Windows.Forms.TextBox
$txt_source.Location = New-Object System.Drawing.Point(20, 175)
$txt_source.Size = New-Object System.Drawing.Size(380, 20)
$main_form.Controls.Add($txt_source)

$btn_browse = New-Object System.Windows.Forms.Button
$btn_browse.Location = New-Object System.Drawing.Point(410, 174)
$btn_browse.Size = New-Object System.Drawing.Size(100, 23)
$btn_browse.Text = "Browse..."
$btn_browse.Enabled = $false # Disabled by default
$main_form.Controls.Add($btn_browse)

# 4. Speed Limit
$label_speed = New-Object System.Windows.Forms.Label
$label_speed.Location = New-Object System.Drawing.Point(20, 215)
$label_speed.Size = New-Object System.Drawing.Size(300, 20)
$label_speed.Text = "Speed Limit (e.g., 5M or 500K). Leave blank for unlimited:"
$main_form.Controls.Add($label_speed)

$txt_speed = New-Object System.Windows.Forms.TextBox
$txt_speed.Location = New-Object System.Drawing.Point(20, 240)
$txt_speed.Size = New-Object System.Drawing.Size(150, 20)
$main_form.Controls.Add($txt_speed)

# 5. Status Log Box
$log_box = New-Object System.Windows.Forms.TextBox
$log_box.Location = New-Object System.Drawing.Point(20, 340)
$log_box.Size = New-Object System.Drawing.Size(490, 120)
$log_box.Multiline = $true
$log_box.ScrollBars = "Vertical"
$log_box.ReadOnly = $true
$main_form.Controls.Add($log_box)

# 6. Start Download Button
$btn_start = New-Object System.Windows.Forms.Button
$btn_start.Location = New-Object System.Drawing.Point(20, 280)
$btn_start.Size = New-Object System.Drawing.Size(490, 40)
$btn_start.Text = "Start Download"
$btn_start.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$btn_start.BackColor = [System.Drawing.Color]::PaleGreen
$main_form.Controls.Add($btn_start)

# --- GUI Event Handlers (The Logic) ---

# Event: When the user changes the download type
$combo_type.add_SelectedIndexChanged({
    if ($combo_type.SelectedItem -eq "Torrent File") {
        $btn_browse.Enabled = $true
    } else {
        $btn_browse.Enabled = $false
    }
})

# Event: When the user clicks the "Browse..." button
$btn_browse.add_Click({
    $open_dialog = New-Object System.Windows.Forms.OpenFileDialog
    $open_dialog.Title = "Select a torrent file"
    $open_dialog.Filter = "Torrent Files (*.torrent)|*.torrent"
    if ($open_dialog.ShowDialog() -eq "OK") {
        $txt_source.Text = $open_dialog.FileName
    }
})

# Event: When the user clicks "Start Download"
$btn_start.add_Click({
    # Disable button to prevent multi-clicking
    $btn_start.Enabled = $false
    $log_box.AppendText("`r`n") # Add a separator

    # --- 1. Validation ---
    if ([string]::IsNullOrWhiteSpace($txt_name.Text) -or [string]::IsNullOrWhiteSpace($txt_source.Text)) {
        [System.Windows.Forms.MessageBox]::Show("Download Name and Source cannot be empty.", "Validation Error", "OK", "Warning")
        $btn_start.Enabled = $true
        return
    }

    # --- 2. Prerequisite Check ---
    $aria2Path = Install-Aria2c -logBox $log_box
    if (-not $aria2Path) {
        $log_box.AppendText("❌ Cannot proceed without aria2c.exe.`r`n")
        $btn_start.Enabled = $true
        return
    }

    # --- 3. Prepare Download ---
    $downloadName = $txt_name.Text
    $downloadSource = $txt_source.Text
    $speedLimit = $txt_speed.Text
    
    $sanitizedDownloadName = $downloadName -replace '[^a-zA-Z0-9_\-]', '_'
    $downloadDirectory = "$env:USERPROFILE\Downloads\$sanitizedDownloadName"
    
    $aria2ConfigDir = "$env:USERPROFILE\.aria2"
    New-Item -ItemType Directory -Path $aria2ConfigDir -Force -ErrorAction SilentlyContinue | Out-Null
    New-Item -ItemType Directory -Path $downloadDirectory -Force -ErrorAction SilentlyContinue| Out-Null
    
    $log_box.AppendText("Download directory: $downloadDirectory`r`n")

    # --- 4. Build aria2c command arguments ---
    $aria2Args = @(
        "--dir=`"$downloadDirectory`"",
        "--seed-time=0",
        "--bt-tracker=udp://tracker.opentrackr.org:1337/announce,udp://open.demonii.com:1337/announce,udp://tracker.openbittorrent.com:6969/announce,udp://tracker.coppersurfer.tk:6969/announce",
        "`"$downloadSource`""
    )
    if (-not [string]::IsNullOrWhiteSpace($speedLimit)) {
        $aria2Args += "--max-download-limit=$speedLimit"
    }

    # --- 5. Launch Download ---
    $log_box.AppendText("🚀 Starting download in a new window...`r`n")
    
    # Start aria2c in a new console window so the GUI doesn't freeze.
    # The user can see the progress there.
    Start-Process -FilePath $aria2Path -ArgumentList $aria2Args
    
    $log_box.AppendText("✅ Download process initiated.`r`n")
    
    # Re-enable the button for the next download
    $btn_start.Enabled = $true
})


# --- Show the GUI ---
# This line must be at the end. It displays the form and waits for it to be closed.
$main_form.ShowDialog() | Out-Null
