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
# 先确认 openspec 用的 node 版本
NODE_VER=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
pkg "$ENTRY" --targets "node${NODE_VER}-linux-${ARCH}" --output /usr/bin/openspec-standalone
