#!/bin/sh
set -eu
ARCH=$(uname -m)
VERSION=$(pacman -Q kiro-cli | awk '{print $2; exit}')
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"

# kiro-cli 没有图标和桌面文件，手动创建
mkdir -p ./AppDir/usr/share/icons/hicolor/128x128/apps
mkdir -p ./AppDir/usr/share/applications

# 尝试下载官方图标，失败则生成占位图
curl -L "https://kiro.dev/favicon.ico" \
    -o /tmp/kiro.ico 2>/dev/null && \
    convert /tmp/kiro.ico -resize 128x128 \
    ./AppDir/usr/share/icons/hicolor/128x128/apps/kiro-cli.png || \
    convert -size 128x128 xc:#232f3e \
    ./AppDir/usr/share/icons/hicolor/128x128/apps/kiro-cli.png

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
