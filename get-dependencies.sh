#!/bin/sh
set -eu
ARCH=$(uname -m)
echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm patchelf curl nodejs npm
echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano
make-aur-package openspec

# 用 pkg 编译成单文件二进制
npm install -g @yao-pkg/pkg
ENTRY=$(pacman -Ql openspec | grep 'dist/cli/index.js' | grep -v '\.map' | awk '{print $2}' | tr -d '\n')
case "$ARCH" in
    x86_64) PKG_ARCH="x64" ;;
    aarch64) PKG_ARCH="arm64" ;;
    *) PKG_ARCH="x64" ;;
esac
pkg "$ENTRY" --targets "node20-linux-${PKG_ARCH}" --output /usr/bin/openspec-standalone
