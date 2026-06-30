#!/usr/bin/env bash
source "${GFORGE_DIR}/profiles/gentoo.sh"

INIT="${INIT:-openrc}"
KERNEL_CHOICE="${KERNEL_CHOICE:-gentoo-kernel-bin}"
KERNEL_CONFIG_METHOD="binary"
STAGE3_VARIANT="${STAGE3_VARIANT:-desktop-openrc}"

WM_DE="${WM_DE:-gnome}"
DISPLAY_MANAGER="${DISPLAY_MANAGER:-gdm}"
AUDIO_STACK="${AUDIO_STACK:-pipewire}"
NETWORK_STACK="${NETWORK_STACK:-networkmanager}"

GLOBAL_USE="X wayland pipewire networkmanager elogind bluetooth cups gtk -kde -qt5 -qt6 -systemd"
VIDEO_CARDS="${VIDEO_CARDS:-intel}"
ACCEPTED_LICENSES="@FREE @BINARY-REDISTRIBUTABLE"

BASE_PACKAGES+=(
    app-shells/bash-completion
    app-editors/nano
    sys-apps/pciutils
    sys-apps/usbutils
)

EXTRAS="firefox alacritty neovim mpv flatpak"

GENTOO_CFLAGS="-march=native -O2 -pipe"
GENTOO_MAKEOPTS="-j$(nproc)"

USE_BINHOST="yes"
INSTALL_EIX="yes"