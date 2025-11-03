#!/bin/bash
# libernet.sh (bootstrapper minimal + Arcadyan/Qualcomm support + wget fallback)
# by vpnlegasi

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

REPO="https://github.com/vpnlegasi/libernet.git"
TMP_DIR="/tmp/libernet"
ZIP_FILE="/tmp/libernet.zip"

cleanup() {
  echo "Cleaning temporary files..."
  rm -rf "$TMP_DIR" /tmp/libernet-main "$ZIP_FILE"
}
trap cleanup EXIT

fixes_os() {
  DISTFILE="/etc/opkg/distfeeds.conf"
  RELEASE_FILE="/etc/openwrt_release"

  if [ -f "$RELEASE_FILE" ]; then
    ver=$(grep -oE "[0-9]+\.[0-9]+\.[0-9]+" "$RELEASE_FILE")
    target_info=$(grep DISTRIB_TARGET "$RELEASE_FILE" | cut -d"'" -f2)
    arch=$(grep DISTRIB_ARCH "$RELEASE_FILE" | cut -d"'" -f2)
  fi

  if [ -z "$ver" ] || [[ "$ver" == *SNAPSHOT* ]]; then
    echo "Detected SNAPSHOT or unknown version - using fallback 23.05.3"
    ver="23.05.3"
  fi

  target=$(echo "$target_info" | cut -d'/' -f1)
  subtarget=$(echo "$target_info" | cut -d'/' -f2)
  cpu=$(uname -m)

  if grep -qiE "arcadyan|qualcomm|ipq" /proc/cpuinfo 2>/dev/null || [[ "$target_info" == ipq* ]]; then
    echo "Qualcomm/Arcadyan device detected"
    case "$target_info" in
      *ipq807x*|*qualcommax*)
        arch="aarch64_cortex-a53"
        target="qualcommax"
        subtarget="ipq807x"
        ;;
      *ipq60xx*|*ipq50xx*)
        arch="aarch64_cortex-a53"
        target="qualcommax"
        subtarget="ipq60xx"
        ;;
      *ipq40xx*|*ipq4*)
        arch="arm_cortex-a7_neon-vfpv4"
        target="ipq40xx"
        subtarget="generic"
        ;;
      *)
        arch="${arch:-aarch64_cortex-a53}"
        target="${target:-qualcommax}"
        subtarget="${subtarget:-ipq807x}"
        ;;
    esac
  else
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
  fi

  echo "Generating new distfeeds.conf for OpenWrt $ver ($arch -> $target/$subtarget)"
  cat > "$DISTFILE" <<EOF
src/gz openwrt_core https://downloads.openwrt.org/releases/${ver}/targets/${target}/${subtarget}/packages
src/gz openwrt_base https://downloads.openwrt.org/releases/${ver}/packages/${arch}/base
src/gz openwrt_luci https://downloads.openwrt.org/releases/${ver}/packages/${arch}/luci
src/gz openwrt_packages https://downloads.openwrt.org/releases/${ver}/packages/${arch}/packages
src/gz openwrt_routing https://downloads.openwrt.org/releases/${ver}/packages/${arch}/routing
src/gz openwrt_telephony https://downloads.openwrt.org/releases/${ver}/packages/${arch}/telephony
EOF
}

# Test opkg update dulu — kalau gagal baru run fixes_os()
echo "Testing opkg update..."
if ! opkg update >/dev/null 2>&1; then
  echo "opkg update failed - regenerating distfeeds.conf"
  fixes_os
  echo "Retrying opkg update..."
  opkg update
else
  echo "opkg update successful"
fi

rm -rf ~/Downloads/libernet
rm -rf "$TMP_DIR"

if ! command -v git >/dev/null 2>&1; then
  echo "Git not found, installing..."
  opkg install git
fi

echo "Cloning Libernet repository..."
if ! git clone --depth 1 "$REPO" "$TMP_DIR"; then
  echo "Git clone failed, using wget fallback..."
  mkdir -p "$TMP_DIR"

  if ! command -v unzip >/dev/null 2>&1; then
    echo "Installing unzip..."
    opkg install unzip
  fi

  wget -qO "$ZIP_FILE" "$REPO/archive/refs/heads/main.zip" || {
    echo "Failed to download Libernet archive."
    exit 1
  }

  unzip -q "$ZIP_FILE" -d /tmp || {
    echo "Failed to extract archive."
    exit 1
  }

  mv /tmp/libernet-main/* "$TMP_DIR"/ 2>/dev/null || {
    echo "Failed to move extracted files."
    exit 1
  }
fi

cd "$TMP_DIR" || exit
echo "Running installer..."
bash install.sh
