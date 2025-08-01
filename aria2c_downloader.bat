@echo off
title Aria2c Downloader

:: Universal .bat script to download a magnet link with aria2c.

:: 1. Prompt for user input
echo.
set /p downloadName="Enter a name for your download (e.g., My_Awesome_Game): "
echo.
set /p magnetLink="Paste the magnet link: "
echo.

set "downloadDirectory=%USERPROFILE%\Downloads\%downloadName%"

:: 2. Create proper directories
if not exist "%USERPROFILE%\.aria2" mkdir "%USERPROFILE%\.aria2"
if not exist "%downloadDirectory%" mkdir "%downloadDirectory%"
echo Created download directory at: %downloadDirectory%
echo.

:: 3. Create the aria2 configuration file
(
    echo # --- Optimized Aria2 Configuration File ---
    echo dir=%downloadDirectory%
    echo disk-cache=64M
    echo file-allocation=falloc
    echo save-session-interval=60
    echo dht-file-path=%USERPROFILE%\.aria2\dht.dat
    echo dht-file-path6=%USERPROFILE%\.aria2\dht6.dat
    echo bt-enable-lpd=true
    echo enable-dht=true
    echo enable-dht6=true
    echo bt-max-peers=200
    echo seed-time=0
    echo bt-require-crypto=true
    echo bt-tracker=udp://tracker.opentrackr.org:1337/announce,udp://open.demonii.com:1337/announce,udp://tracker.openbittorrent.com:6969/announce,udp://tracker.coppersurfer.tk:6969/announce,udp://p4p.arenabg.com:1337/announce,udp://tracker.internetwarriors.net:1337/announce,udp://exodus.desync.com:6969/announce,udp://tracker.tiny-vps.com:6969/announce,udp://tracker.moeking.me:6969/announce,udp://tracker.leechers-paradise.org:6969/announce
) > "%USERPROFILE%\.aria2\aria2.conf"

:: 4. Start the download
echo Starting download with optimized configuration...
echo.
aria2c --conf-path="%USERPROFILE%\.aria2\aria2.conf" "%magnetLink%"

:: 5. Pause at the end to see the final stats
echo.
echo Download finished. Press any key to exit.
pause > nul