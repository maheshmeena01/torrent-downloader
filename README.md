# Aria2c Torrent Downloader Scripts

This repository contains universal scripts in both PowerShell and Windows Batch for downloading torrents via magnet links using the command-line utility `aria2c`.

The scripts are designed to be easy to use, providing prompts for user input and generating a robust `aria2.conf` file on the fly for optimized download speeds.

## Features

- **User-Friendly:** Prompts for a download folder name and the magnet link.
- **Optimized for Speed:** Creates a configuration file with an extensive tracker list and settings to maximize peer connections.
- **Dynamic Configuration:** Automatically sets the download directory and paths for session files.
- **Cross-compatible:** Provides both a PowerShell (`.ps1`) version for modern Windows and a legacy Batch (`.bat`) version.

## Prerequisites

- [aria2c](https://aria2.github.io/) must be installed and accessible in your system's PATH.

## How to Use

### PowerShell (`aria2c_downloader.ps1`)

1.  Open a PowerShell terminal.
2.  Navigate to the directory where you saved the script.
3.  Run the script: `.\aria2c_downloader.ps1`
4.  Follow the on-screen prompts.

### Batch (`aria2c_downloader.bat`)

1.  Simply double-click the `aria2c_downloader.bat` file.
2.  A command prompt window will open.
3.  Follow the on-screen prompts.
