#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm patchelf nodejs npm bun

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
make-aur-package openspec

# openspec 已装好，找入口文件并编译成单文件二进制
ENTRY=$(pacman -Ql openspec | grep 'dist/cli/index.js' | awk '{print $2}')
bun build "$ENTRY" --compile --outfile /usr/bin/openspec-standalone

# If the application needs to be manually built that has to be done down here
