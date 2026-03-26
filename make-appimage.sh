#!/bin/sh
set -eu
ARCH=$(uname -m)
VERSION=$(pacman -Q openspec | awk '{print $2; exit}')
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"

# openspec 是 CLI 工具，没有图标和桌面文件，手动创建
mkdir -p ./AppDir/usr/share/icons/hicolor/128x128/apps
mkdir -p ./AppDir/usr/share/applications

# 内嵌最小合法 PNG 占位图标，不依赖任何工具
echo 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==' \
    | base64 -d > ./AppDir/usr/share/icons/hicolor/128x128/apps/openspec.png

export ICON=./AppDir/usr/share/icons/hicolor/128x128/apps/openspec.png

cat <<EOF > ./AppDir/usr/share/applications/openspec.desktop
[Desktop Entry]
Name=OpenSpec
Exec=openspec-standalone
Icon=openspec
Type=Application
Categories=Development;
StartupWMClass=openspec
EOF

export DESKTOP=./AppDir/usr/share/applications/openspec.desktop
export DEPLOY_OPENGL=0
export DEPLOY_P11KIT=0

# 部署 bun 编译好的单文件二进制
quick-sharun \
    /usr/bin/openspec-standalone

# Turn AppDir into AppImage
quick-sharun --make-appimage
