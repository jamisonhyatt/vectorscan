#!/bin/bash
# Verify build artifacts for Windows ARM64 build

set -e

BUILD_DIR="build"

echo "Checking build artifacts..."

# Check static libraries
if [ -f "$BUILD_DIR/lib/libhs.a" ]; then
  echo "✓ libhs.a found ($(du -h $BUILD_DIR/lib/libhs.a | cut -f1))"
  file $BUILD_DIR/lib/libhs.a
else
  echo "✗ libhs.a not found"
  exit 1
fi

if [ -f "$BUILD_DIR/lib/libhs_runtime.a" ]; then
  echo "✓ libhs_runtime.a found ($(du -h $BUILD_DIR/lib/libhs_runtime.a | cut -f1))"
else
  echo "✗ libhs_runtime.a not found"
  exit 1
fi

# Check shared libraries
if [ -f "$BUILD_DIR/bin/libhs.dll" ]; then
  echo "✓ libhs.dll found ($(du -h $BUILD_DIR/bin/libhs.dll | cut -f1))"
  file $BUILD_DIR/bin/libhs.dll
else
  echo "✗ libhs.dll not found"
  exit 1
fi

if [ -f "$BUILD_DIR/bin/libhs_runtime.dll" ]; then
  echo "✓ libhs_runtime.dll found ($(du -h $BUILD_DIR/bin/libhs_runtime.dll | cut -f1))"
  file $BUILD_DIR/bin/libhs_runtime.dll
else
  echo "✗ libhs_runtime.dll not found"
  exit 1
fi

# Check runtime dependency DLLs
echo ""
echo "Checking runtime dependency DLLs..."
runtime_dlls_found=0

# Check for C++ runtime DLLs (Clang/LLVM)
if [ -f "$BUILD_DIR/bin/libc++.dll" ]; then
  echo "✓ libc++.dll found ($(du -h $BUILD_DIR/bin/libc++.dll | cut -f1))"
  runtime_dlls_found=1
fi

if [ -f "$BUILD_DIR/bin/libunwind.dll" ]; then
  echo "✓ libunwind.dll found ($(du -h $BUILD_DIR/bin/libunwind.dll | cut -f1))"
fi

# Check for C++ runtime DLLs (GCC)
if [ -f "$BUILD_DIR/bin/libstdc++-6.dll" ]; then
  echo "✓ libstdc++-6.dll found ($(du -h $BUILD_DIR/bin/libstdc++-6.dll | cut -f1))"
  runtime_dlls_found=1
fi

if [ -f "$BUILD_DIR/bin/libgcc_s_seh-1.dll" ]; then
  echo "✓ libgcc_s_seh-1.dll found ($(du -h $BUILD_DIR/bin/libgcc_s_seh-1.dll | cut -f1))"
fi

# Check for threading runtime DLL
if [ -f "$BUILD_DIR/bin/libwinpthread-1.dll" ]; then
  echo "✓ libwinpthread-1.dll found ($(du -h $BUILD_DIR/bin/libwinpthread-1.dll | cut -f1))"
fi

if [ $runtime_dlls_found -eq 0 ]; then
  echo "✗ No C++ runtime DLLs found - build may not have copied dependencies"
  exit 1
fi

# Check example executables
if [ -f "$BUILD_DIR/bin/simplegrep.exe" ]; then
  echo "✓ simplegrep.exe found ($(du -h $BUILD_DIR/bin/simplegrep.exe | cut -f1))"
  file $BUILD_DIR/bin/simplegrep.exe
else
  echo "✗ simplegrep.exe not found"
  exit 1
fi

# List all build artifacts
echo ""
echo "All build artifacts:"
find $BUILD_DIR -name "*.a" -o -name "*.dll" -o -name "*.exe" | sort

echo ""
echo "✓ All build artifacts verified successfully!"
