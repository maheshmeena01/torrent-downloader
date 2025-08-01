# Aria2c Torrent Downloader 🚀

A self-installing PowerShell utility to download torrents and magnet links using `aria2c`.

This script requires no manual setup. Simply paste one command into PowerShell, and it will automatically handle its own dependencies (`aria2c`) and prompt you for a magnet link.

---

## 🚀 Quick Launch (One-Liner)

Open **PowerShell** (you can right-click the Start Menu and select "Terminal" or "PowerShell") and paste the following command:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-WebRequest -Uri https://raw.githubusercontent.com/maheshmeena01/torrent-downloader/main/aria2c_downloader.ps1 -UseBasicParsing | Invoke-Expression
```

---

### ✨ Features

* **Zero Installation:** No need to manually install aria2c or configure the PATH. The script handles it automatically on the first launch.
* **Easy to Use:** Simply run the one-liner and follow the prompts.
* **Optimized for Speed:** The script creates an `aria2.conf` file on the fly, complete with an extensive and up-to-date tracker list to maximize peer connections.
* **Self-Contained:** It downloads `aria2c` to a local `.\tools\` folder next to where the script is run, keeping your system clean.

---

### 🚀 How It Works

The one-liner command performs the following actions:

1.  `Set-ExecutionPolicy Bypass -Scope Process -Force`: Temporarily allows the execution of scripts for the current PowerShell session for maximum compatibility.
2.  `Invoke-WebRequest`: Downloads the raw code of the `aria2c_downloader.ps1` script from this GitHub repository.
3.  `Invoke-Expression`: Executes the downloaded script code directly in memory.

The script itself then checks if `aria2c.exe` exists in a local `.\tools\` folder. If not, it downloads the official aria2 release, unzips it, and places it there for future use.

---

### 💻 Manual / Local Usage

If you prefer to download the script before running it:

1.  Download the `aria2c_downloader.ps1` file from this repository.
2.  Right-click the downloaded file, go to **Properties**, and check the **Unblock** box at the bottom.
3.  Open a PowerShell terminal in the same folder where you saved the file.
4.  Run the script with the command: `.\aria2c_downloader.ps1`

---

### ⚠️ Security

Using **`Invoke-Expression`** from an internet source runs code on your system. This command downloads the script directly from this repository. Please review the code in `aria2c_downloader.ps1` if you have any security concerns.
