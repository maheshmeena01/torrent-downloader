# ==============================================================================
# Universal PowerShell script with automatic prerequisite (aria2c) installation.
# Version 2.0 - Fixed for one-liner execution.
# ==============================================================================

# --- Setup & Prerequisite Check ---

# Define the root directory based on the user's current location. This is more reliable for one-liners.
$scriptRoot = Get-Location
$toolsDir = Join-Path -Path $scriptRoot -ChildPath "tools"
$aria2Path = Join-Path -Path $toolsDir -ChildPath "aria2c.exe"
$aria2Version = "aria2-1.37.0" # Specify a known stable version

# Check if aria2c.exe already exists in our local tools folder.
if (-not (Test-Path -Path $aria2Path)) {
    Write-Host "----------------- SETUP -----------------" -ForegroundColor Yellow
    Write-Host "aria2c not found. Attempting to download it for you."
    Write-Host "This is a one-time setup."
    Write-Host "The 'tools' folder will be created here: $($scriptRoot)"
    Write-Host "-----------------------------------------"
    Write-Host ""

    try {
        # Create the tools directory if it doesn't exist
        if (-not (Test-Path -Path $toolsDir)) {
            New-Item -ItemType Directory -Path $toolsDir | Out-Null
        }

        # Define download URLs and paths
        $downloadUrl = "https://github.com/aria2/aria2/releases/download/release-$($aria2Version)/$($aria2Version)-win-64bit-build1.zip"
        $zipPath = Join-Path -Path $toolsDir -ChildPath "aria2.zip"

        # Download the file
        Write-Host "Downloading aria2 from the official GitHub repository..." -ForegroundColor Green
        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath

        # Unzip the file
        Write-Host "Extracting files..." -ForegroundColor Green
        Expand-Archive -Path $zipPath -DestinationPath $toolsDir -Force

        # The zip extracts to a subfolder, so we need to move the files up
        $unzippedSubfolder = Join-Path -Path $toolsDir -ChildPath "$($aria2Version)-win-64bit-build1"
        Get-ChildItem -Path $unzippedSubfolder | Move-Item -Destination $toolsDir

        # Clean up the empty subfolder and the zip file
        Remove-Item -Path $unzippedSubfolder -Force -Recurse
        Remove-Item -Path $zipPath -Force

        # Final check
        if (-not (Test-Path -Path $aria2Path)) {
            throw "Aria2c setup failed. The executable was not found after extraction."
        }

        Write-Host "Aria2c has been successfully set up in the 'tools' folder." -ForegroundColor Cyan
        Write-Host ""
    }
    catch {
        Write-Host ""
        Write-Host "----------------- ERROR -----------------" -ForegroundColor Red
        Write-Host "An error occurred during the automatic setup:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Write-Host "Please try running the script again. If the issue persists, check your internet connection." -ForegroundColor Yellow
        Write-Host "-----------------------------------------" -ForegroundColor Red
        Write-Host ""
        Read-Host "Press Enter to exit."
        exit
    }
} else {
    Write-Host "Aria2c prerequisite found locally." -ForegroundColor Green
}


# --- Main Application Logic ---

# 1. Prompt for user input
$downloadName = Read-Host -Prompt "Enter a name for your download (e.g., My_Awesome_Game)"
$magnetLink = Read-Host -Prompt "Paste the magnet link"

# Create a sanitized directory path from the user's input
$sanitizedDownloadName = $downloadName -replace '[^a-zA-Z0-9_\-]', '_'
$downloadDirectory = "$env:USERPROFILE\Downloads\$sanitizedDownloadName"

# 2. Create proper directories
New-Item -ItemType Directory -Path "$env:USERPROFILE\.aria2" -Force | Out-Null
New-Item -ItemType Directory -Path $downloadDirectory -Force | Out-Null
Write-Host "Created download directory at: $downloadDirectory"

# 3. Create a robust aria2 configuration file
@"
# --- Robust Aria2 Configuration File ---
dir=$downloadDirectory
disk-cache=64M
file-allocation=falloc
save-session-interval=60
dht-file-path=$env:USERPROFILE\.aria2\dht.dat
dht-file-path6=$env:USERPROFILE\.aria2\dht6.dat
bt-enable-lpd=true
enable-dht=true
enable-dht6=true
bt-max-peers=200
seed-time=0
bt-require-crypto=true
bt-tracker=udp://tracker.opentrackr.org:1337/announce,udp://open.demonii.com:1337/announce,udp://tracker.openbittorrent.com:6969/announce,udp://tracker.coppersurfer.tk:6969/announce,udp://p4p.arenabg.com:1337/announce,udp://tracker.internetwarriors.net:1337/announce,udp://exodus.desync.com:6969/announce,udp://tracker.tiny-vps.com:6969/announce,udp://tracker.moeking.me:6969/announce,udp://tracker.leechers-paradise.org:6969/announce
"@ | Out-File -FilePath "$env:USERPROFILE\.aria2\aria2.conf" -Encoding ASCII

# 4. Start the download using the LOCAL aria2c executable
Write-Host "Starting download with robust configuration for: $magnetLink"
# Use the call operator '&' to execute the command from the path stored in the variable
& $aria2Path --conf-path="$env:USERPROFILE\.aria2\aria2.conf" "$magnetLink"

Write-Host ""
Write-Host "Download process finished. Press Enter to exit."
Read-Host
