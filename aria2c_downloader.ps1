# ==============================================================================
# Universal PowerShell script with a GUI for aria2c.
# Version 10.2 - THE FINAL VERSION
# - Fixed a critical syntax error (ParserError) that prevented the script from launching.
# ==============================================================================

# --- Function to Handle Prerequisite (aria2c) Installation ---
function Install-Aria2c {
    param([Action[string]]$writeLogAction)
    $scriptRoot = $PSScriptRoot; if (-not $scriptRoot) { $scriptRoot = Get-Location }
    $toolsDir = Join-Path -Path $scriptRoot -ChildPath "tools"
    $aria2Path = Join-Path -Path $toolsDir -ChildPath "aria2c.exe"
    if (Test-Path -Path $aria2Path) { $writeLogAction.Invoke("Aria2c prerequisite found locally."); return $aria2Path }
    $writeLogAction.Invoke("----------------- SETUP -----------------")
    $writeLogAction.Invoke("aria2c not found. Attempting to download...")
    try {
        if (-not (Test-Path -Path $toolsDir)) { New-Item -ItemType Directory -Path $toolsDir | Out-Null }
        $aria2VersionNumber = "1.37.0"; $aria2VersionName = "aria2-1.37.0"; $aria2AssetName = "$($aria2VersionName)-win-64bit-build1.zip"
        $downloadUrl = "https://github.com/aria2/aria2/releases/download/release-$($aria2VersionNumber)/$($aria2AssetName)"
        $zipPath = Join-Path -Path $toolsDir -ChildPath "aria2.zip"
        $writeLogAction.Invoke("Downloading from: $downloadUrl")
        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath
        $writeLogAction.Invoke("Extracting files...")
        Expand-Archive -Path $zipPath -DestinationPath $toolsDir -Force
        $unzippedSubfolder = Join-Path -Path $toolsDir -ChildPath "$($aria2VersionName)-win-64bit-build1"
        Get-ChildItem -Path $unzippedSubfolder | Move-Item -Destination $toolsDir -Force
        Remove-Item -Path $unzippedSubfolder -Force -Recurse; Remove-Item -Path $zipPath -Force
        if (-not (Test-Path -Path $aria2Path)) { throw "Aria2c setup failed." }
        $writeLogAction.Invoke("✅ Aria2c has been successfully set up.")
        return $aria2Path
    } catch {
        $writeLogAction.Invoke("❌ ERROR: $($_.Exception.Message)")
        [System.Windows.Forms.MessageBox]::Show("An error during setup: $($_.Exception.Message)", "Error", "OK", "Error")
        return $null
    }
}

# --- Function to Search for Torrents using a JSON API ---
function Search-Torrents {
    param([string]$query, [System.Windows.Forms.ListView]$listView, [Action[string]]$writeLogAction)
    $listView.Items.Clear()
    $sanitizedQuery = [uri]::EscapeDataString($query)
    $searchUrl = "https://apibay.org/q.php?q=$($sanitizedQuery)"
    $writeLogAction.Invoke("Searching for '$query' via API...")
    try {
        $results = Invoke-RestMethod -Uri $searchUrl
        if ($results.name -eq "No results") { $writeLogAction.Invoke("No results found."); return }
        $writeLogAction.Invoke("Found $($results.Count) results. Populating list...")
        foreach ($result in $results) {
            $name = $result.name
            $sizeInBytes = [long]$result.size
            $size = if ($sizeInBytes -gt 1GB) { "{0:N2} GB" -f ($sizeInBytes / 1GB) } else { "{0:N2} MB" -f ($sizeInBytes / 1MB) }
            $categoryName = switch ($result.category) {
                { $_ -like '1*' } { 'Audio' }; { $_ -like '2*' } { 'Video' }; { $_ -like '3*' } { 'Apps' }; { $_ -like '4*' } { 'Games' }; default { 'Other' }
            }
            $seeds = $result.seeders; $leeches = $result.leechers; $infoHash = $result.info_hash
            $magnetLink = "magnet:?xt=urn:btih:$($infoHash)&dn=$([uri]::EscapeDataString($name))"
            $item = New-Object System.Windows.Forms.ListViewItem($name)
            $item.SubItems.Add($size); $item.SubItems.Add($categoryName); $item.SubItems.Add($seeds); $item.SubItems.Add($leeches); $item.Tag = $magnetLink
            $listView.Items.Add($item) | Out-Null
        }
    } catch { $writeLogAction.Invoke("❌ ERROR: Failed to fetch search results. $($_.Exception.Message)") }
}

# --- GUI Creation ---
Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing
$form = New-Object System.Windows.Forms.Form
$form.Text = "Aria2c Downloader 10.2 - Stable"
$form.Size = New-Object System.Drawing.Size(720, 850)
$form.MinimumSize = New-Object System.Drawing.Size(550, 700)
$form.StartPosition = "CenterScreen"; $form.FormBorderStyle = 'Sizable'; $form.MaximizeBox = $true
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9); $form.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
$margin = 15

$groupMode = New-Object System.Windows.Forms.GroupBox; $groupMode.Location = New-Object System.Drawing.Point($margin, $margin); $groupMode.Size = New-Object System.Drawing.Size(670, 60); $groupMode.Text = "1. Select Download Mode"; $groupMode.Anchor = 'Top, Left, Right'; $form.Controls.Add($groupMode)
$labelMode = New-Object System.Windows.Forms.Label; $labelMode.Location = New-Object System.Drawing.Point($margin, 25); $labelMode.AutoSize = $true; $labelMode.Text = "Mode:"; $groupMode.Controls.Add($labelMode)
$comboMode = New-Object System.Windows.Forms.ComboBox; $comboMode.Location = New-Object System.Drawing.Point(70, 22); $comboMode.Size = New-Object System.Drawing.Size(200, 20); $comboMode.DropDownStyle = "DropDownList"; $comboMode.Items.AddRange(@("Search & Download (Torrents)", "Manual URL Download")); $comboMode.SelectedIndex = 0; $groupMode.Controls.Add($comboMode)
$groupSearch = New-Object System.Windows.Forms.GroupBox; $groupSearch.Location = New-Object System.Drawing.Point($margin, 85); $groupSearch.Size = New-Object System.Drawing.Size(670, 250); $groupSearch.Text = "2. Search for a Torrent"; $groupSearch.Anchor = 'Top, Left, Right'; $form.Controls.Add($groupSearch)
$labelSearch = New-Object System.Windows.Forms.Label; $labelSearch.Location = New-Object System.Drawing.Point($margin, 30); $labelSearch.AutoSize = $true; $labelSearch.Text = "Search Term:"; $groupSearch.Controls.Add($labelSearch)
$textSearchQuery = New-Object System.Windows.Forms.TextBox; $textSearchQuery.Location = New-Object System.Drawing.Point(100, 27); $textSearchQuery.Size = New-Object System.Drawing.Size(430, 20); $textSearchQuery.Anchor = 'Top, Left, Right'; $groupSearch.Controls.Add($textSearchQuery)
$btnSearch = New-Object System.Windows.Forms.Button; $btnSearch.Location = New-Object System.Drawing.Point(545, 26); $btnSearch.Size = New-Object System.Drawing.Size(105, 23); $btnSearch.Text = "Search"; $btnSearch.Anchor = 'Top, Right'; $groupSearch.Controls.Add($btnSearch)
$listViewResults = New-Object System.Windows.Forms.ListView; $listViewResults.Location = New-Object System.Drawing.Point($margin, 60); $listViewResults.Size = New-Object System.Drawing.Size(640, 175); $listViewResults.View = "Details"; $listViewResults.FullRowSelect = $true; $listViewResults.GridLines = $true; $listViewResults.Anchor = 'Top, Bottom, Left, Right'; $listViewResults.Columns.Add("Name", 360) | Out-Null; $listViewResults.Columns.Add("Size", 80) | Out-Null; $listViewResults.Columns.Add("Category", 70) | Out-Null; $listViewResults.Columns.Add("Seeds", 50) | Out-Null; $listViewResults.Columns.Add("Leeches", 50) | Out-Null; $groupSearch.Controls.Add($listViewResults)
$groupDetails = New-Object System.Windows.Forms.GroupBox; $groupDetails.Location = New-Object System.Drawing.Point($margin, 345); $groupDetails.Size = New-Object System.Drawing.Size(670, 120); $groupDetails.Text = "3. Download Details"; $groupDetails.Anchor = 'Top, Left, Right'; $form.Controls.Add($groupDetails)
$labelName = New-Object System.Windows.Forms.Label; $labelName.Location = New-Object System.Drawing.Point($margin, 30); $labelName.AutoSize = $true; $labelName.Text = "Download Name (used for subfolder):"; $groupDetails.Controls.Add($labelName)
$textName = New-Object System.Windows.Forms.TextBox; $textName.Location = New-Object System.Drawing.Point($margin, 55); $textName.Size = New-Object System.Drawing.Size(640, 20); $textName.Anchor = 'Top, Left, Right'; $groupDetails.Controls.Add($textName)
$labelSource = New-Object System.Windows.Forms.Label; $labelSource.Location = New-Object System.Drawing.Point($margin, 85); $labelSource.AutoSize = $true; $labelSource.Text = "Source (URL/Magnet):"; $groupDetails.Controls.Add($labelSource)
$textSource = New-Object System.Windows.Forms.TextBox; $textSource.Location = New-Object System.Drawing.Point(140, 83); $textSource.Size = New-Object System.Drawing.Size(510, 20); $textSource.Anchor = 'Top, Left, Right'; $groupDetails.Controls.Add($textSource)
$groupConfig = New-Object System.Windows.Forms.GroupBox; $groupConfig.Location = New-Object System.Drawing.Point($margin, 475); $groupConfig.Size = New-Object System.Drawing.Size(670, 90); $groupConfig.Text = "4. Configuration"; $groupConfig.Anchor = 'Top, Left, Right'; $form.Controls.Add($groupConfig)
$labelPath = New-Object System.Windows.Forms.Label; $labelPath.Location = New-Object System.Drawing.Point($margin, 30); $labelPath.AutoSize = $true; $labelPath.Text = "Download Location:"; $groupConfig.Controls.Add($labelPath)
$textPath = New-Object System.Windows.Forms.TextBox; $textPath.Location = New-Object System.Drawing.Point(140, 28); $textPath.Size = New-Object System.Drawing.Size(400, 20); $textPath.Text = "$env:USERPROFILE\Downloads"; $textPath.Anchor = 'Top, Left, Right'; $groupConfig.Controls.Add($textPath)
$btnBrowsePath = New-Object System.Windows.Forms.Button; $btnBrowsePath.Location = New-Object System.Drawing.Point(555, 27); $btnBrowsePath.Size = New-Object System.Drawing.Size(95, 23); $btnBrowsePath.Text = "Browse..."; $btnBrowsePath.Anchor = 'Top, Right'; $groupConfig.Controls.Add($btnBrowsePath)
$labelSpeed = New-Object System.Windows.Forms.Label; $labelSpeed.Location = New-Object System.Drawing.Point($margin, 58); $labelSpeed.AutoSize = $true; $labelSpeed.Text = "Speed Limit (e.g., 5M):"; $groupConfig.Controls.Add($labelSpeed)
$textSpeed = New-Object System.Windows.Forms.TextBox; $textSpeed.Location = New-Object System.Drawing.Point(140, 56); $textSpeed.Size = New-Object System.Drawing.Size(150, 20); $groupConfig.Controls.Add($textSpeed)
$groupProgress = New-Object System.Windows.Forms.GroupBox; $groupProgress.Location = New-Object System.Drawing.Point($margin, 575); $groupProgress.Size = New-Object System.Drawing.Size(670, 80); $groupProgress.Text = "5. Download Progress"; $groupProgress.Anchor = 'Bottom, Left, Right'; $form.Controls.Add($groupProgress)
$progressLabel = New-Object System.Windows.Forms.Label; $progressLabel.Location = New-Object System.Drawing.Point($margin, 25); $progressLabel.Size = New-Object System.Drawing.Size(640, 20); $progressLabel.Text = "Waiting to start download..."; $progressLabel.Anchor = 'Top, Left, Right'; $groupProgress.Controls.Add($progressLabel)
$progressBar = New-Object System.Windows.Forms.ProgressBar; $progressBar.Location = New-Object System.Drawing.Point($margin, 45); $progressBar.Size = New-Object System.Drawing.Size(640, 20); $progressBar.Anchor = 'Top, Left, Right'; $groupProgress.Controls.Add($progressBar)
$btnStart = New-Object System.Windows.Forms.Button; $btnStart.Location = New-Object System.Drawing.Point($margin, 665); $btnStart.Size = New-Object System.Drawing.Size(670, 45); $btnStart.Text = "Start Download"; $btnStart.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold); $btnStart.BackColor = [System.Drawing.Color]::FromArgb(40, 167, 69); $btnStart.ForeColor = [System.Drawing.Color]::White; $btnStart.Anchor = 'Bottom, Left, Right'; $form.Controls.Add($btnStart)
$btnCancel = New-Object System.Windows.Forms.Button; $btnCancel.Location = New-Object System.Drawing.Point($margin, 665); $btnCancel.Size = New-Object System.Drawing.Size(670, 45); $btnCancel.Text = "Cancel Download"; $btnCancel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold); $btnCancel.BackColor = [System.Drawing.Color]::FromArgb(220, 53, 69); $btnCancel.ForeColor = [System.Drawing.Color]::White; $btnCancel.Anchor = 'Bottom, Left, Right'; $btnCancel.Visible = $false; $form.Controls.Add($btnCancel)
$logBox = New-Object System.Windows.Forms.TextBox; $logBox.Location = New-Object System.Drawing.Point($margin, 720); $logBox.Size = New-Object System.Drawing.Size(670, 70); $logBox.Multiline = $true; $logBox.ScrollBars = "Vertical"; $logBox.ReadOnly = $true; $logBox.Font = New-Object System.Drawing.Font("Consolas", 9); $logBox.Anchor = 'Bottom, Left, Right'; $form.Controls.Add($logBox)

# --- GUI Event Handlers (The Logic) ---
$script:aria2Path = $null; $script:downloadJob = $null
$timer = New-Object System.Windows.Forms.Timer; $timer.Interval = 1000
$script:progressRegex = [regex] '^\[#\w+\s+(?<downloaded>[\d\.]+[BKMGTi]+)\/(?<total>[\d\.]+[BKMGTi]+)\((?<percent>\d+)%\)\s.*?DL:(?<speed>[\d\.]+[BKMGTi]+)'

function Write-Log { param($message) $timestamp = Get-Date -Format "HH:mm:ss"; $logBox.AppendText("[$timestamp] $message`r`n") }
function Update-Download-Mode { if ($comboMode.SelectedItem -eq "Search & Download (Torrents)") { $groupSearch.Enabled = $true; $textName.ReadOnly = $true; $textSource.ReadOnly = $true; $groupDetails.Text = "3. Download Details (auto-filled)" } else { $groupSearch.Enabled = $false; $textName.ReadOnly = $false; $textSource.ReadOnly = $false; $groupDetails.Text = "3. Download Details (manual)" } }
function Set-Download-State { param([bool]$isDownloading) { $btnStart.Visible = -not $isDownloading; $btnCancel.Visible = $isDownloading; $groupMode.Enabled = -not $isDownloading; $groupSearch.Enabled = -not $isDownloading; $groupDetails.Enabled = -not $isDownloading; $groupConfig.Enabled = -not $isDownloading } }

# FIX: Corrected the corrupted variable name in this line.
$form.Add_Load({ Write-Log "Welcome!"; $script:aria2Path = Install-Aria2c -writeLogAction ${function:Write-Log}; Update-Download-Mode })

$comboMode.add_SelectedIndexChanged({ Update-Download-Mode })
$btnSearch.add_Click({ if ([string]::IsNullOrWhiteSpace($textSearchQuery.Text)) { return }; $btnSearch.Enabled = $false; Search-Torrents -query $textSearchQuery.Text -listView $listViewResults -writeLogAction ${function:Write-Log}; $btnSearch.Enabled = $true })
$listViewResults.add_DoubleClick({ if ($listViewResults.SelectedItems.Count -gt 0) { $selectedItem = $listViewResults.SelectedItems[0]; $textName.Text = $selectedItem.Text; $textSource.Text = $selectedItem.Tag; Write-Log "Selected: $($selectedItem.Text)" } })
$btnBrowsePath.add_Click({ $folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog; if ($folderDialog.ShowDialog() -eq "OK") { $textPath.Text = $folderDialog.SelectedPath } })

$btnStart.add_Click({
    if ([string]::IsNullOrWhiteSpace($textName.Text) -or [string]::IsNullOrWhiteSpace($textSource.Text) -or [string]::IsNullOrWhiteSpace($textPath.Text)) { [System.Windows.Forms.MessageBox]::Show("All details must be filled.", "Validation Error", "OK", "Warning"); return }
    if (-not $script:aria2Path) { Write-Log "❌ Cannot proceed without aria2c.exe."; return }
    Set-Download-State -isDownloading $true
    $sanitizedDownloadName = $textName.Text -replace '[^a-zA-Z0-9_\-.]', '_'; $downloadDirectory = Join-Path -Path $textPath.Text -ChildPath $sanitizedDownloadName
    try { if (-not (Test-Path -Path $downloadDirectory)) { New-Item -ItemType Directory -Path $downloadDirectory -Force | Out-Null }; Write-Log "Download directory: $downloadDirectory" } catch { Write-Log "❌ ERROR: Could not create download directory."; Set-Download-State -isDownloading $false; return }
    $aria2Args = New-Object System.Collections.Generic.List[string]; $aria2Args.Add("--dir=$downloadDirectory"); $aria2Args.Add("--seed-time=0"); $aria2Args.Add("--summary-interval=1")
    if (-not [string]::IsNullOrWhiteSpace($textSpeed.Text)) { $aria2Args.Add("--max-download-limit=$($textSpeed.Text)") }
    $aria2Args.Add($textSource.Text)
    $progressBar.Value = 0; $progressLabel.Text = "Starting download..."; Write-Log "🚀 Starting download in the background..."
    $script:downloadJob = Start-Job -ScriptBlock { param($Aria2Path, $Arguments) & $Aria2Path $Arguments } -ArgumentList $script:aria2Path, $aria2Args
    $timer.Start()
})

$btnCancel.add_Click({
    if ($null -ne $script:downloadJob) {
        Write-Log "🛑 User requested to cancel download. Stopping job..."
        Stop-Job -Job $script:downloadJob
    }
})

$timer.Add_Tick({
    if ($null -eq $script:downloadJob) { $timer.Stop(); return }
    try {
        $output = Receive-Job -Job $script:downloadJob
        if ($output) {
            foreach ($line in $output) {
                $match = $script:progressRegex.Match($line)
                if ($match.Success) {
                    $percent = $match.Groups['percent'].Value
                    $downloaded = $match.Groups['downloaded'].Value
                    $total = $match.Groups['total'].Value
                    $speed = $match.Groups['speed'].Value
                    $progressBar.Value = [int]$percent
                    $progressLabel.Text = "Downloading: ${percent}%  |  ${downloaded} / ${total}  |  Speed: ${speed}"
                } elseif (-not [string]::IsNullOrWhiteSpace($line)) {
                    Write-Log $line
                }
            }
        }
    } catch { Write-Log "Error during progress update: $($_.Exception.Message)" }

    if ($script:downloadJob.State -in @('Completed', 'Failed', 'Stopped')) {
        $timer.Stop()
        Write-Log "Download job finished with state: $($script:downloadJob.State)."
        if ($script:downloadJob.State -eq 'Completed') {
            Receive-Job -Job $script:downloadJob | ForEach-Object { if (-not [string]::IsNullOrWhiteSpace($_)) { Write-Log $_ } }
            $progressBar.Value = 100; $progressLabel.Text = "✅ Download Complete!" 
        } elseif ($script:downloadJob.State -eq 'Stopped') {
            $progressLabel.Text = "🛑 Download Canceled."
        } else { $progressLabel.Text = "❌ Download Failed or Stopped. Check logs." }
        Remove-Job -Job $script:downloadJob; $script:downloadJob = $null
        Set-Download-State -isDownloading $false
    }
})

$form.Add_FormClosing({ if ($null -ne $script:downloadJob) { Stop-Job -Job $script:downloadJob; Remove-Job -Job $script:downloadJob } })
$form.ShowDialog() | Out-Null
