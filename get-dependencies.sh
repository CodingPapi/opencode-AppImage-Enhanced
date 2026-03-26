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

# 创建 wrapper 脚本，动态解析 AppImage 挂载路径
cat <<'EOF' > /usr/bin/openspec-run
#!/bin/sh
APPDIR=$(dirname "$(dirname "$(readlink -f "$0")")")
exec "$APPDIR/bin/node" "$APPDIR/usr/lib/openspec/dist/cli/index.js" "$@"
EOF
chmod +x /usr/bin/openspec-run
