# Building LIPS for Linux

## Good News! 🎉

Your application is **already compatible with Linux**! All the dependencies you're using are cross-platform:

- ✅ `drift` - Cross-platform SQLite ORM
- ✅ `sqlite3_flutter_libs` - Supports Linux
- ✅ `path_provider` - Cross-platform file paths
- ✅ `google_fonts` - Cross-platform
- ✅ `flutter_bloc` - Cross-platform
- ✅ `go_router` - Cross-platform

## Prerequisites

1. **Flutter SDK** with Linux desktop support enabled
2. **Linux development dependencies** installed

### Install Flutter Linux Dependencies

#### Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install -y \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    liblzma-dev \
    libsqlite3-dev
```

#### Fedora:
```bash
sudo dnf install -y \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    gtk3-devel \
    xz-devel \
    sqlite-devel
```

#### Arch Linux:
```bash
sudo pacman -S --needed \
    clang \
    cmake \
    ninja \
    pkg-config \
    gtk3 \
    xz \
    sqlite
```

## Building for Linux

### 1. Enable Linux Desktop Support

```bash
flutter config --enable-linux-desktop
```

### 2. Verify Linux Support

```bash
flutter doctor
```

Make sure Linux toolchain shows as available.

### 3. Build Release Version

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build Linux release
flutter build linux --release
```

The build output will be in: `build/linux/x64/release/bundle/`

## Running the Application

### Development Mode:
```bash
flutter run -d linux
```

### Release Mode:
```bash
cd build/linux/x64/release/bundle
./inventory_management_system
```

## Creating a Linux Installer/Package

### Option 1: AppImage (Recommended - Single File)

1. Install `appimagetool`:
```bash
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage
```

2. Create AppDir structure:
```bash
mkdir -p LIPS.AppDir/usr/bin
mkdir -p LIPS.AppDir/usr/share/applications
mkdir -p LIPS.AppDir/usr/share/icons/hicolor/512x512/apps

# Copy application files
cp -r build/linux/x64/release/bundle/* LIPS.AppDir/usr/bin/

# Create desktop file
cat > LIPS.AppDir/usr/share/applications/lips.desktop << EOF
[Desktop Entry]
Name=LIPS
Comment=Local Inventory & POS System
Exec=inventory_management_system
Icon=lips
Type=Application
Categories=Office;
EOF

# Copy icon (if you have one)
# cp icon.png LIPS.AppDir/usr/share/icons/hicolor/512x512/apps/lips.png

# Create AppRun
cat > LIPS.AppDir/AppRun << EOF
#!/bin/bash
HERE="\$(dirname "\$(readlink -f "\${0}")")"
exec "\${HERE}"/usr/bin/inventory_management_system "\$@"
EOF
chmod +x LIPS.AppDir/AppRun

# Create AppImage
./appimagetool-x86_64.AppImage LIPS.AppDir LIPS-0.1.0-x86_64.AppImage
```

### Option 2: DEB Package (Debian/Ubuntu)

Create a simple DEB package structure:

```bash
mkdir -p lips-deb/DEBIAN
mkdir -p lips-deb/usr/bin
mkdir -p lips-deb/usr/share/applications
mkdir -p lips-deb/usr/share/icons/hicolor/512x512/apps

# Copy application
cp -r build/linux/x64/release/bundle/* lips-deb/usr/bin/

# Create control file
cat > lips-deb/DEBIAN/control << EOF
Package: lips
Version: 0.1.0
Section: office
Priority: optional
Architecture: amd64
Depends: libgtk-3-0, libsqlite3-0
Maintainer: Your Name <your.email@example.com>
Description: Local Inventory & POS System
 LIPS is a local inventory and point-of-sale system
 designed for the Iraqi market.
EOF

# Create desktop file
cat > lips-deb/usr/share/applications/lips.desktop << EOF
[Desktop Entry]
Name=LIPS
Comment=Local Inventory & POS System
Exec=/usr/bin/inventory_management_system
Icon=lips
Type=Application
Categories=Office;
EOF

# Build DEB package
dpkg-deb --build lips-deb lips_0.1.0_amd64.deb
```

### Option 3: Flatpak (Universal Linux Package)

Create `com.example.lips.yml`:

```yaml
app-id: com.example.lips
runtime: org.freedesktop.Platform
runtime-version: '22.08'
sdk: org.freedesktop.Sdk
command: inventory_management_system
finish-args:
  - --share=ipc
  - --socket=x11
  - --socket=wayland
  - --device=dri
modules:
  - name: lips
    buildsystem: simple
    build-commands:
      - install -Dm755 inventory_management_system /app/bin/inventory_management_system
      - install -Dm644 data/flutter_assets/* /app/share/lips/
    sources:
      - type: dir
        path: build/linux/x64/release/bundle
```

Build:
```bash
flatpak-builder build-dir com.example.lips.yml --install --user
flatpak build-export repo build-dir
flatpak build-bundle repo lips.flatpak com.example.lips
```

## Database Location on Linux

The database will be stored at:
```
~/.local/share/com.example.inventory_management_system/lips_database.db
```

This is handled automatically by `path_provider` - no code changes needed!

## Testing

1. **Test on your development machine:**
   ```bash
   flutter run -d linux
   ```

2. **Test the release build:**
   ```bash
   flutter build linux --release
   cd build/linux/x64/release/bundle
   ./inventory_management_system
   ```

3. **Test on a clean Linux system:**
   - Copy the bundle folder to a fresh Linux installation
   - Ensure required libraries are installed (GTK3, SQLite)
   - Run the application

## Troubleshooting

### Error: "GTK not found"
Install GTK3 development libraries:
```bash
sudo apt-get install libgtk-3-dev  # Ubuntu/Debian
sudo dnf install gtk3-devel         # Fedora
```

### Error: "SQLite not found"
Install SQLite development libraries:
```bash
sudo apt-get install libsqlite3-dev  # Ubuntu/Debian
sudo dnf install sqlite-devel       # Fedora
```

### Application won't start
Check dependencies:
```bash
ldd build/linux/x64/release/bundle/inventory_management_system
```

### Font rendering issues
Ensure Cairo font is available:
```bash
sudo apt-get install fonts-cairo  # Ubuntu/Debian
```

## Distribution

Choose the packaging format based on your target users:

- **AppImage**: Single file, works on most Linux distributions
- **DEB**: For Debian/Ubuntu users
- **RPM**: For Fedora/RedHat users (similar to DEB)
- **Flatpak**: Universal, works on all distributions with Flatpak support
- **Snap**: Universal, works on Ubuntu and other Snap-enabled systems

## Notes

- The application code is **100% cross-platform** - no changes needed!
- Database location is handled automatically by `path_provider`
- All UI components work identically on Linux
- RTL (Arabic) support works on Linux
- Fonts are loaded dynamically via `google_fonts`
