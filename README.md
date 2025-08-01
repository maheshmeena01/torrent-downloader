# Aria2c Torrent Downloader Scripts

This repository contains universal scripts for downloading torrents via magnet links using the command-line utility `aria2c`.

The PowerShell script is fully self-contained and will automatically download the `aria2c` prerequisite on its first run.

## Features

- **Automatic Setup (PowerShell):** No need to install anything! The PowerShell script will download `aria2c` for you into a local `tools` folder.
- **Easy to Use:** Just run the script and follow the prompts.
- **Optimized for Speed:** Creates a configuration file with an extensive tracker list to maximize peer connections.
- **Cross-compatible:**
    - `aria2c_downloader.ps1`: The recommended, self-installing version for modern Windows.
    - `aria2c_downloader.bat`: A legacy Batch version (requires manual `aria2c` installation).

## How to Use

### PowerShell (Recommended)

1.  Download the `aria2c_downloader.ps1` script.
2.  Right-click the file, go to **Properties**, and click the **Unblock** checkbox at the bottom. This is required to run scripts downloaded from the internet.
3.  Open a PowerShell terminal, navigate to the folder where you saved the script.
4.  Run the script: `.\aria2c_downloader.ps1`
5.  The first time you run it, it will automatically download and set up `aria2c`. Subsequent runs will be instant.
6.  Follow the on-screen prompts.

### Batch (Legacy)

This version requires you to manually install `aria2c` and add it to your system's PATH.

1.  Download and install `aria2c` from the [official releases page](https://github.com/aria2/aria2/releases).
2.  Ensure the folder containing `aria2c.exe` is added to your system's PATH environment variable.
3.  Double-click `aria2c_downloader.bat` and follow the prompts.
