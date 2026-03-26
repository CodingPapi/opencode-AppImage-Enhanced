#!/bin/sh
set -eu
ARCH=$(uname -m)
VERSION=$(pacman -Q openspec | awk '{print $2; exit}')
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"

# 创建桌面文件和图标目录
mkdir -p ./AppDir/usr/share/icons/hicolor/128x128/apps
mkdir -p ./AppDir/usr/share/applications

# 下载官方图标
curl -L "https://raw.githubusercontent.com/Fission-AI/OpenSpec/main/assets/icon.png" \
    -o ./AppDir/usr/share/icons/hicolor/128x128/apps/openspec.png 2>/dev/null || \
    convert -size 128x128 xc:#1a1a2e ./AppDir/usr/share/icons/hicolor/128x128/apps/openspec.png

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

# openspec 是 Node.js 脚本，需要同时部署 node 运行时
quick-sharun \
    /usr/bin/openspec \
    /usr/bin/node

# Turn AppDir into AppImage
quick-sharun --make-appimage
