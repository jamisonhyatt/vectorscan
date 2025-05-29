#!/bin/bash
# Environment setup script for Windows ARM64 cross-compilation

echo "Setting up environment for Windows ARM64 cross-compilation..."

# Check if we're in MSYS2
if [[ -z "$MSYSTEM" ]]; then
    echo "Error: This script should be run in MSYS2 environment"
    echo "Please open MSYS2 MINGW64 terminal and run this script"
    exit 1
fi

echo "Current MSYSTEM: $MSYSTEM"

# Update package database
# echo "Updating package database..."
pacman -Sy --noconfirm

# Install MinGW-w64 ARM64 toolchain
echo "Installing MinGW-w64 ARM64 toolchain..."
pacman -S --noconfirm \
    mingw-w64-clang-aarch64-gcc \
    mingw-w64-clang-aarch64-gcc-compat \
    mingw-w64-clang-aarch64-cmake \
    mingw-w64-clang-aarch64-make \
    mingw-w64-clang-aarch64-pkg-config

# Install dependencies
echo "Installing dependencies..."
pacman -S --noconfirm \
    mingw-w64-clang-aarch64-boost \
    mingw-w64-clang-aarch64-sqlite3 \
    mingw-w64-clang-aarch64-ragel \
    mingw-w64-clang-aarch64-pcre

# Verify installation
echo ""
echo "Verifying installation..."
if command -v aarch64-w64-mingw32-gcc &> /dev/null; then
    echo "✓ ARM64 GCC found: $(which aarch64-w64-mingw32-gcc)"
    aarch64-w64-mingw32-gcc --version | head -1
else
    echo "✗ ARM64 GCC not found"
fi

if command -v aarch64-w64-mingw32-g++ &> /dev/null; then
    echo "✓ ARM64 G++ found: $(which aarch64-w64-mingw32-g++)"
else
    echo "✗ ARM64 G++ not found"
fi

if command -v cmake &> /dev/null; then
    echo "✓ CMake found: $(which cmake)"
    cmake --version | head -1
else
    echo "✗ CMake not found"
fi

if command -v ragel &> /dev/null; then
    echo "✓ Ragel found: $(which ragel)"
else
    echo "✗ Ragel not found"
fi

echo ""
echo "Environment setup complete!"
echo "You can now run the build script:"
echo "  ./build-windows-arm64.sh"
