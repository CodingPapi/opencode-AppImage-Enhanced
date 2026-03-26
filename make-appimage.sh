#!/bin/sh
set -eu
ARCH=$(uname -m)
VERSION=$(pacman -Q openspec | awk '{print $2; exit}')
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"

mkdir -p ./AppDir/usr/share/icons/hicolor/128x128/apps
mkdir -p ./AppDir/usr/share/applications

echo 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==' \
    | base64 -d > ./AppDir/usr/share/icons/hicolor/128x128/apps/openspec.png

export ICON=./AppDir/usr/share/icons/hicolor/128x128/apps/openspec.png

cat <<EOF > ./AppDir/usr/share/applications/openspec.desktop
[Desktop Entry]
Name=OpenSpec
Exec=openspec
Icon=openspec
Type=Application
Categories=Development;
StartupWMClass=openspec
EOF

export DESKTOP=./AppDir/usr/share/applications/openspec.desktop
export DEPLOY_OPENGL=0
export DEPLOY_P11KIT=0

# 同时部署 node 运行时和 openspec 脚本
quick-sharun \
    /usr/bin/openspec \
    /usr/bin/node

# 把 openspec 的 lib 目录（包含 node_modules）复制进 AppDir
mkdir -p ./AppDir/usr/lib
cp -r /usr/lib/openspec ./AppDir/usr/lib/openspec

# Turn AppDir into AppImage
quick-sharun --make-appimage
