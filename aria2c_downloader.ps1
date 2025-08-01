# Universal PowerShell script to download a magnet link or torrent file with aria2c.
# Prompts the user for a download name and the magnet link.

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

# 4. Start the download
Write-Host "Starting download with robust configuration for: $magnetLink"
aria2c --conf-path="$env:USERPROFILE\.aria2\aria2.conf" "$magnetLink"

Write-Host "Download process finished. Press Enter to exit."
Read-Host