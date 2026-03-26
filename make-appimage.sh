#!/bin/sh
set -eu
ARCH=$(uname -m)
VERSION=$(pacman -Q kiro-cli | awk '{print $2; exit}')
export ARCH VERSION
export OUTPATH=./dist
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"

# kiro-cli 没有图标和桌面文件，手动创建
mkdir -p ./AppDir/usr/share/icons/hicolor/128x128/apps
mkdir -p ./AppDir/usr/share/applications

# 内嵌最小合法 PNG，不依赖任何工具
echo 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==' \
    | base64 -d > ./AppDir/usr/share/icons/hicolor/128x128/apps/kiro-cli.png

export ICON=./AppDir/usr/share/icons/hicolor/128x128/apps/kiro-cli.png

cat <<EOF > ./AppDir/usr/share/applications/kiro-cli.desktop
[Desktop Entry]
Name=Kiro CLI
Exec=kiro-cli
Icon=kiro-cli
Type=Application
Categories=Development;
StartupWMClass=kiro-cli
EOF

export DESKTOP=./AppDir/usr/share/applications/kiro-cli.desktop
export DEPLOY_OPENGL=0
export DEPLOY_P11KIT=0

# 部署二进制
quick-sharun \
    /usr/bin/kiro-cli

# Turn AppDir into AppImage
quick-sharun --make-appimage
