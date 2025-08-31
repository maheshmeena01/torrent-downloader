# PowerShell Aria2c Downloader

![Version 10.3](https://img.shields.io/badge/version-10.3-blue.svg)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

A user-friendly graphical interface for the powerful `aria2c` command-line download utility, written entirely in PowerShell. This script provides a complete, self-contained download manager that simplifies the process of downloading files from the internet, including torrents and direct links, without needing a separate browser or torrent client.

---

## Features

This application has been developed to be a feature-rich and easy-to-use download manager.

* **Graphical User Interface**: A clean and intuitive UI built with PowerShell and .NET WinForms.
* **Automatic Setup**: Automatically downloads and sets up the `aria2c.exe` prerequisite if it's not found.
* **Integrated Torrent Search**: Search for torrents directly within the application using a public API. Results include file size, category, and seed/leech counts.
* **Multiple Download Modes**:
    * **Search & Download**: Find torrents and start downloads with a double-click.
    * **Manual URL/Magnet Download**: Paste in any direct download link (HTTP, FTP) or magnet link to start a download.
* **Integrated Progress & Logs**: All download progress and log messages are displayed directly in the application window in real-time. **No separate pop-up console windows.**
* **Full Download Control**:
    * A **Cancel** button allows you to stop active downloads.
    * Set custom download speed limits.
* **Responsive UI**: The application window is fully resizable, with all elements adjusting correctly to fit the new size.

---

## Requirements

* **Operating System**: Windows 10 or Windows 11
* **PowerShell**: Version 5.1 or later (this is included by default in modern Windows versions).

---

## How to Use

Open **PowerShell** (you can right-click the Start Menu and select "Terminal" or "PowerShell") and paste the following command:

```powershell
cd ~\Downloads; Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-WebRequest -Uri https://raw.githubusercontent.com/maheshmeena01/torrent-downloader/main/aria2c_downloader.ps1 -UseBasicParsing | Invoke-Expression```
The application window should now appear, and you can start downloading.

---

## Troubleshooting

* **"Script cannot be loaded because running scripts is disabled on this system."**: This is the most common issue. Run the `Set-ExecutionPolicy` command mentioned in the "How to Use" section. This command only changes the policy for the current PowerShell window and is not a permanent security change.

* **Search Returns No Results**: The script relies on a free, public API (`apibay.org`) for torrent searches. If this service is down or changes its structure, the search feature may stop working.

---

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## Acknowledgments

* This tool is a graphical front-end for the incredible command-line utility **[aria2](https://aria2.github.io/)**.
* Torrent search functionality is powered by the public API at **apibay.org**.
