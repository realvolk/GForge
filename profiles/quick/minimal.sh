#!/usr/bin/env bash
source "${GFORGE_DIR}/profiles/gentoo.sh"

INIT="${INIT:-openrc}"
KERNEL_CHOICE="${KERNEL_CHOICE:-gentoo-kernel}"
KERNEL_CONFIG_METHOD="binary"
STAGE3_VARIANT="${STAGE3_VARIANT:-openrc}"

WM_DE="none"
DISPLAY_MANAGER="none"
AUDIO_STACK="none"
NETWORK_STACK="dhcpcd+iwd"

GLOBAL_USE="-X -wayland -pulseaudio -gtk -qt5 -qt6 -gnome -kde -cups -bluetooth elogind ipv6"
ACCEPTED_LICENSES="@FREE"

BASE_PACKAGES+=(
    app-admin/sudo
    app-editors/nano
    sys-apps/pciutils
    sys-apps/usbutils
)

EXTRAS=""

GENTOO_CFLAGS="-march=native -O2 -pipe"
GENTOO_MAKEOPTS="-j$(nproc)"

USE_BINHOST="no"