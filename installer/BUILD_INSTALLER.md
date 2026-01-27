# Building Windows Installer for LIPS

This guide will help you create a single Windows installer file (.exe) for the LIPS application.

## Prerequisites

1. **Flutter SDK** - Make sure Flutter is installed and configured
2. **Inno Setup** - Download and install from: https://jrsoftware.org/isinfo.php
   - Download the Unicode version for Arabic support
   - During installation, make sure to install the "Inno Setup Preprocessor" component

## Step 1: Build Flutter Windows Release

1. Open PowerShell or Command Prompt in the project root directory

2. Clean previous builds (optional but recommended):
   ```powershell
   flutter clean
   ```

3. Get dependencies:
   ```powershell
   flutter pub get
   ```

4. Build the Windows release:
   ```powershell
   flutter build windows --release
   ```

   This will create the release build in: `build\windows\x64\runner\Release`

## Step 2: Prepare Installer Script

1. The installer script (`lips_installer.iss`) is already created in the `installer` folder

2. **Optional: Customize the installer**:
   - Edit `installer/lips_installer.iss`
   - Update `AppPublisher` with your company name
   - Update `AppURL` with your website
   - Change `SetupIconFile` path if you have a custom icon
   - Adjust `AppVersion` to match your version

## Step 3: Create the Installer

### Option A: Using Inno Setup Compiler GUI

1. Open **Inno Setup Compiler** (installed in Step 1)

2. Click **File** → **Open** and select `installer\lips_installer.iss`

3. Click **Build** → **Compile** (or press F9)

4. The installer will be created in: `installer\output\LIPS_Setup_0.1.0.exe`

### Option B: Using Command Line

1. Open PowerShell in the project root

2. Run:
   ```powershell
   & "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer\lips_installer.iss
   ```

   (Adjust the path if Inno Setup is installed in a different location)

3. The installer will be created in: `installer\output\LIPS_Setup_0.1.0.exe`

## Step 4: Test the Installer

1. Run the installer (`LIPS_Setup_0.1.0.exe`) on a test Windows machine

2. Follow the installation wizard

3. Verify the application runs correctly after installation

## Distribution

The installer file (`LIPS_Setup_0.1.0.exe`) is a standalone executable that can be:
- Distributed via USB drive
- Uploaded to cloud storage (Google Drive, Dropbox, etc.)
- Hosted on your website for download
- Emailed to users

Users can simply double-click the installer and follow the wizard - no additional setup required!

## Troubleshooting

### Error: "Cannot find the build directory"
- Make sure you've run `flutter build windows --release` first
- Check that the path in `lips_installer.iss` matches your build output location

### Error: "Application won't start after installation"
- Ensure all DLL files are included (the script uses `recursesubdirs` to include all files)
- Check Windows Event Viewer for error details
- Verify Visual C++ Redistributable is installed on the target machine

### Arabic text not displaying correctly
- Make sure you installed the Unicode version of Inno Setup
- The installer script includes Arabic language support

## Advanced: Code Signing (Optional)

For production releases, you may want to sign your installer:

1. Obtain a code signing certificate
2. Add to `lips_installer.iss`:
   ```
   SignTool=signtool
   SignedUninstaller=yes
   ```
3. Configure signing in Inno Setup Compiler settings

## Notes

- The installer requires administrator privileges to install
- The application will be installed to: `C:\Program Files\LIPS\`
- User data (database) will be stored in: `%USERPROFILE%\Documents\lips_database.db`
- The installer creates desktop and Start Menu shortcuts
