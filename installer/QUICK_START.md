# Quick Start Guide - Creating Windows Installer

## Fastest Method (Automated)

1. **Double-click** `build_installer.bat` in the `installer` folder
2. Wait for the build to complete (~2-5 minutes)
3. Your installer will be at: `installer\output\LIPS_Setup_0.1.0.exe`

That's it! The installer is ready to distribute.

## Prerequisites

Before running the script, make sure you have:

1. **Flutter SDK** installed and in PATH
2. **Inno Setup 6** installed (download from https://jrsoftware.org/isinfo.php)
   - Install the Unicode version
   - Default installation path: `C:\Program Files (x86)\Inno Setup 6\`

## What You Get

After building, you'll have:
- **LIPS_Setup_0.1.0.exe** - A single installer file (~50-100 MB)
- Users can double-click this file to install
- No additional dependencies needed on user's machine
- Installs to `C:\Program Files\LIPS\`
- Creates Start Menu and Desktop shortcuts
- Includes uninstaller

## Manual Method

If the automated script doesn't work:

1. Open PowerShell in project root
2. Run: `flutter build windows --release`
3. Open Inno Setup Compiler
4. Open `installer\lips_installer.iss`
5. Click Build → Compile (F9)
6. Installer will be in `installer\output\`

## Troubleshooting

**Script can't find Inno Setup?**
- Edit `build_installer.bat`
- Update the `INNO_PATH` variable with your Inno Setup installation path

**Build fails?**
- Make sure Flutter is in your PATH: `flutter --version`
- Make sure you're in the project root directory
- Try running `flutter clean` first

**Installer works but app won't start?**
- Make sure Visual C++ Redistributable is installed on target machine
- Check Windows Event Viewer for error details

## Distribution

The installer file can be:
- ✅ Copied to USB drive
- ✅ Uploaded to Google Drive / Dropbox
- ✅ Hosted on your website
- ✅ Emailed to users
- ✅ Burned to CD/DVD

No additional setup required - just double-click and install!
