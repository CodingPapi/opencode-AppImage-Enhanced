#!/bin/sh
set -eu
ARCH=$(uname -m)
VERSION=$(pacman -Q opencode-bin | awk '{print $2; exit}')  # 改包名
export ARCH VERSION
export OUTPATH=./dist
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"

# opencode-bin 是纯 CLI，没有图标和桌面文件，需要手动创建
mkdir -p ./AppDir/usr/share/icons/hicolor/128x128/apps
curl -L "https://raw.githubusercontent.com/sst/opencode/main/packages/opencode/assets/icon.png" \
    -o ./AppDir/usr/share/icons/hicolor/128x128/apps/opencode.png
mkdir -p ./AppDir/usr/share/applications

# 创建一个最简桌面文件
cat <<EOF > ./AppDir/usr/share/applications/opencode.desktop
[Desktop Entry]
Name=opencode
Exec=opencode
Icon=opencode
Type=Application
Categories=Development;
StartupWMClass=opencode
EOF

# 用一个占位图标（如果有真实图标路径就替换）
export ICON=./AppDir/usr/share/icons/hicolor/128x128/apps/opencode.png
export DESKTOP=./AppDir/usr/share/applications/opencode.desktop

export DEPLOY_OPENGL=1
export DEPLOY_P11KIT=1

# 只部署 CLI 二进制
quick-sharun \
    /usr/bin/opencode

# bun 二进制处理
kek=.$(tr -dc 'A-Za-z0-9_=-' < /dev/urandom | head -c 10)
rm -f ./AppDir/bin/opencode ./AppDir/shared/bin/opencode
cp -v /usr/bin/opencode ./AppDir/bin/opencode
patchelf --set-interpreter /tmp/"$kek" ./AppDir/bin/opencode
patchelf --set-rpath '$ORIGIN/../lib' ./AppDir/bin/opencode

cat <<EOF > ./AppDir/bin/random-linker.src.hook
#!/bin/sh
cp -f "\$APPDIR"/shared/lib/ld-linux*.so* /tmp/"$kek"
EOF
chmod +x ./AppDir/bin/*.hook

# Turn AppDir into AppImage
quick-sharun --make-appimage
