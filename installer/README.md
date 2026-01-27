# LIPS Windows Installer

This directory contains files needed to create a Windows installer for the LIPS application.

## Quick Start

### Automated Build (Recommended)

1. Double-click `build_installer.bat`
2. Wait for the build to complete
3. Find your installer at: `installer\output\LIPS_Setup_0.1.0.exe`

### Manual Build

See `BUILD_INSTALLER.md` for detailed instructions.

## Files

- `lips_installer.iss` - Inno Setup script for creating the installer
- `build_installer.bat` - Automated build script
- `BUILD_INSTALLER.md` - Detailed build instructions
- `output/` - Output directory (created after building)

## Requirements

- Flutter SDK
- Inno Setup 6 (Unicode version) - Download from: https://jrsoftware.org/isinfo.php

## What the Installer Does

- Installs the application to `C:\Program Files\LIPS\`
- Creates Start Menu shortcuts
- Optionally creates desktop shortcut
- Registers uninstaller in Windows Add/Remove Programs
- Includes all necessary DLLs and dependencies
- Supports Arabic language in installer UI

## Distribution

The generated `.exe` file is a standalone installer that can be:
- Copied to USB drives
- Uploaded to cloud storage
- Hosted on websites
- Emailed to users

No additional setup required on the user's machine!
