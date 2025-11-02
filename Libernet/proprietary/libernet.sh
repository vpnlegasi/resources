#!/bin/bash
# libernet.sh (bootstrapper minimal)

# Pastikan run sebagai root
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

REPO="https://github.com/vpnlegasi/libernet.git"
TMP_DIR="/tmp/libernet"

function fixes_os() {
  DISTFILE="/etc/opkg/distfeeds.conf"
  RELEASE_FILE="/etc/openwrt_release"

  # baca info asas
  if [ -f "$RELEASE_FILE" ]; then
    ver=$(grep -oE "[0-9]+\.[0-9]+\.[0-9]+" "$RELEASE_FILE")
    target_info=$(grep DISTRIB_TARGET "$RELEASE_FILE" | cut -d"'" -f2)
    arch=$(grep DISTRIB_ARCH "$RELEASE_FILE" | cut -d"'" -f2)
  fi

  # fallback jika version tak valid
  if [ -z "$ver" ] || [[ "$ver" == *SNAPSHOT* ]]; then
    echo "⚠️  Detected SNAPSHOT or unknown version — using stable fallback 23.05.3"
    ver="23.05.3"
  fi

  # pecahkan target/subtarget
  target=$(echo "$target_info" | cut -d'/' -f1)
  subtarget=$(echo "$target_info" | cut -d'/' -f2)
  cpu=$(uname -m)

  # fallback CPU-based mapping
  case "$cpu" in
    aarch64)
      arch="${arch:-aarch64_generic}"
      target="${target:-rockchip}"
      subtarget="${subtarget:-armv8}"
      ;;
    armv8l)
      arch="${arch:-aarch64_cortex-a53}"
      target="${target:-mediatek}"
      subtarget="${subtarget:-mt7981}"
      ;;
    armv7l)
      arch="${arch:-arm_cortex-a9_vfpv3-d16}"
      target="${target:-ramips}"
      subtarget="${subtarget:-mt7621}"
      ;;
    mips)
      arch="${arch:-mips_24kc}"
      target="${target:-ath79}"
      subtarget="${subtarget:-generic}"
      ;;
    mipsel)
      arch="${arch:-mipsel_24kc}"
      target="${target:-ramips}"
      subtarget="${subtarget:-mt7621}"
      ;;
    x86_64)
      arch="${arch:-x86_64}"
      target="${target:-x86}"
      subtarget="${subtarget:-64}"
      ;;
    i686|i386)
      arch="${arch:-x86_generic}"
      target="${target:-x86}"
      subtarget="${subtarget:-generic}"
      ;;
    *)
      arch="${arch:-aarch64_generic}"
      target="${target:-rockchip}"
      subtarget="${subtarget:-armv8}"
      ;;
  esac

  echo "🛠  Generating distfeeds.conf for OpenWrt $ver ($arch → $target/$subtarget)"

  cat > "$DISTFILE" <<EOF
src/gz openwrt_core https://downloads.openwrt.org/releases/${ver}/targets/${target}/${subtarget}/packages
src/gz openwrt_base https://downloads.openwrt.org/releases/${ver}/packages/${arch}/base
src/gz openwrt_luci https://downloads.openwrt.org/releases/${ver}/packages/${arch}/luci
src/gz openwrt_packages https://downloads.openwrt.org/releases/${ver}/packages/${arch}/packages
src/gz openwrt_routing https://downloads.openwrt.org/releases/${ver}/packages/${arch}/routing
src/gz openwrt_telephony https://downloads.openwrt.org/releases/${ver}/packages/${arch}/telephony
EOF
}

fixes_os

# Pastikan clean dulu
rm -rf ~/Downloads/libernet
rm -rf "$TMP_DIR"

# Periksa sama ada git ada, kalau tak ada cuba install
if ! command -v git >/dev/null 2>&1; then
    echo "Git not found, installing..."
    opkg update >/dev/null 2>&1
    opkg install git
fi

# Clone repo
echo "Cloning Libernet repository..."
git clone --depth 1 "$REPO" "$TMP_DIR" || {
    echo "Failed to clone repository."
    exit 1
}

# Masuk folder repo & jalankan installer sebenar
cd "$TMP_DIR" || exit
echo "Running installer..."
bash install.sh
