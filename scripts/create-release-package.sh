#!/bin/bash
# Create release package for Windows ARM64 build

set -e

BUILD_DIR="build-windows-arm64"
RELEASE_DIR="release-package"
ARCHIVE_NAME="vectorscan-windows-arm64.tar.gz"

echo "Creating release package..."

# Create directory structure
mkdir -p $RELEASE_DIR/lib
mkdir -p $RELEASE_DIR/bin
mkdir -p $RELEASE_DIR/include

# Copy libraries
echo "Copying static libraries..."
cp $BUILD_DIR/lib/libhs.a $RELEASE_DIR/lib/
cp $BUILD_DIR/lib/libhs_runtime.a $RELEASE_DIR/lib/
cp $BUILD_DIR/lib/libhs.dll.a $RELEASE_DIR/lib/
cp $BUILD_DIR/lib/libhs_runtime.dll.a $RELEASE_DIR/lib/

# Copy DLLs (including runtime dependencies)
echo "Copying DLLs..."
cp $BUILD_DIR/bin/libhs.dll $RELEASE_DIR/bin/
cp $BUILD_DIR/bin/libhs_runtime.dll $RELEASE_DIR/bin/

# Copy all runtime dependency DLLs
echo "Copying runtime dependency DLLs..."
for dll in $BUILD_DIR/bin/*.dll; do
  dll_name=$(basename "$dll")
  # Skip our main libraries (already copied above)
  if [[ "$dll_name" != "libhs.dll" && "$dll_name" != "libhs_runtime.dll" ]]; then
    echo "  Adding runtime DLL: $dll_name"
    cp "$dll" $RELEASE_DIR/bin/
  fi
done

# Copy example executables
echo "Copying example executables..."
if [ -f "$BUILD_DIR/bin/simplegrep.exe" ]; then
  cp $BUILD_DIR/bin/simplegrep.exe $RELEASE_DIR/bin/
fi
if [ -f "$BUILD_DIR/bin/hsbench.exe" ]; then
  cp $BUILD_DIR/bin/hsbench.exe $RELEASE_DIR/bin/
fi
if [ -f "$BUILD_DIR/bin/hscheck.exe" ]; then
  cp $BUILD_DIR/bin/hscheck.exe $RELEASE_DIR/bin/
fi

# Copy headers
echo "Copying headers..."
cp -r src/hs*.h $RELEASE_DIR/include/ 2>/dev/null || true
cp -r include/* $RELEASE_DIR/include/ 2>/dev/null || true

# Create README
echo "Creating README..."
cat > $RELEASE_DIR/README.md << 'EOF'
# Vectorscan Windows ARM64 Build

This package contains the Windows ARM64 build of Vectorscan.

## Contents

### Libraries
- `lib/libhs.a` - Static library (full Vectorscan)
- `lib/libhs_runtime.a` - Static runtime-only library
- `lib/libhs.dll.a` - Import library for shared library
- `lib/libhs_runtime.dll.a` - Import library for runtime DLL

### DLLs
- `bin/libhs.dll` - Shared library (full Vectorscan)
- `bin/libhs_runtime.dll` - Runtime-only shared library
- `bin/*.dll` - Required runtime dependencies (C++ runtime, threading, etc.)

### Tools
- `bin/simplegrep.exe` - Simple grep example
- `bin/hsbench.exe` - Benchmarking tool
- `bin/hscheck.exe` - Database verification tool

## Usage

To use these libraries in your project:

1. Copy the appropriate libraries to your project
2. Include the headers from the `include/` directory
3. Link against the static libraries or use the DLLs as needed
4. **Important**: When using the DLLs, ensure all files from the `bin/` directory are available at runtime

For runtime-only applications, use the `*_runtime.*` variants.

## Requirements

- Windows on ARM64 (AArch64) architecture
- All runtime DLLs included in this package (no additional runtime installation required)

Built with MSYS2 CLANGARM64 toolchain.
EOF

# Create archive
echo "Creating archive..."
tar -czf $ARCHIVE_NAME -C $RELEASE_DIR .

echo ""
echo "Release package created: $ARCHIVE_NAME"
ls -lh $ARCHIVE_NAME

echo ""
echo "Package contents:"
echo "  Libraries: $(find $RELEASE_DIR/lib -name "*.a" -o -name "*.dll.a" | wc -l) files"
echo "  DLLs: $(find $RELEASE_DIR/bin -name "*.dll" | wc -l) files"
echo "  Executables: $(find $RELEASE_DIR/bin -name "*.exe" | wc -l) files"
echo "  Headers: $(find $RELEASE_DIR/include -name "*.h" | wc -l) files"

echo "✓ Release package created successfully!"
