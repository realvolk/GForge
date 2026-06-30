#!/usr/bin/env bash
source "${VFF_DIR}/profiles/gentoo.sh"
: "${VFF_BOOT_MODE:=uefi}"
DISTRO_NAME="Gentoo Linux"
DISTRO_ID="gentoo"
VFF_BOOTLOADER_ID="Gentoo"
VFF_REQUIRED_TOOLS="sgdisk parted partprobe mount lsblk wipefs mkfs.fat mkfs.ext4 jq"

ESP_MOUNT="/efi"

KERNEL_CHOICES=(
    "gentoo-kernel"        "Distribution kernel (source, automated)"
    "gentoo-kernel-bin"    "Distribution kernel (binary, precompiled)"
    "gentoo-sources"       "Manual kernel configuration"
    "gentoo-sources-genkernel" "Manual kernel with genkernel"
)

STAGE3_VARIANTS=(
    "openrc"              "OpenRC init system"
    "desktop-openrc"      "OpenRC with desktop packages"
    "systemd"             "systemd init system"
    "desktop-systemd"     "systemd with desktop packages"
    "hardened-openrc"     "Hardened profile (OpenRC)"
    "musl-openrc"         "Musl libc (OpenRC)"
    "selinux-openrc"      "SELinux enabled (OpenRC)"
)

BOOTLOADERS=()
if [[ "${VFF_BOOT_MODE}" == "bios" ]]; then
    BOOTLOADERS=("grub")
else
    BOOTLOADERS=("grub" "GRUB" "systemd-boot" "systemd-boot" "efistub" "EFIStub" "refind" "rEFInd")
fi

FS_TYPES=("ext4" "ext4 filesystem" "xfs" "XFS filesystem" "btrfs" "btrfs filesystem" "f2fs" "f2fs filesystem")
INIT_SYSTEMS=("openrc" "OpenRC" "systemd" "systemd")
NETWORK_STACKS=("networkmanager" "NetworkManager" "dhcpcd+iwd" "dhcpcd + iwd")
AUDIO_CHOICES=("pipewire" "PipeWire" "pulseaudio" "PulseAudio" "none" "No audio")

DESKTOP_CHOICES=("gnome" "GNOME" "kde" "KDE Plasma" "xfce" "XFCE" "i3" "i3 window manager" "none" "No desktop")

declare -A DESKTOP_PACKAGES
DESKTOP_PACKAGES=(
    ["gnome"]="gnome-base/gnome gnome-extra/gnome-tweaks gnome-base/gdm"
    ["kde"]="kde-plasma/plasma-meta kde-apps/dolphin kde-apps/konsole x11-misc/sddm"
    ["xfce"]="xfce-base/xfce4-meta xfce-extra/xfce4-goodies x11-misc/lightdm x11-misc/lightdm-gtk-greeter"
    ["i3"]="x11-wm/i3 x11-misc/i3status x11-misc/i3lock x11-misc/dmenu x11-terms/xterm x11-misc/lightdm x11-misc/lightdm-gtk-greeter"
    ["none"]=""
)

DISPLAY_MANAGER_CHOICES=("gdm" "GDM" "sddm" "SDDM" "lightdm" "LightDM" "none" "None")

declare -A AUDIO_PACKAGES
AUDIO_PACKAGES=(
    ["pipewire"]="media-video/pipewire media-sound/wireplumber media-sound/alsa-utils media-sound/pavucontrol"
    ["pulseaudio"]="media-sound/pulseaudio media-sound/pulseaudio-alsa media-sound/alsa-utils media-sound/pavucontrol"
    ["none"]=""
)

declare -A GPU_PACKAGES
GPU_PACKAGES=(
    ["nvidia"]="x11-drivers/nvidia-drivers"
    ["intel"]="x11-drivers/xf86-video-intel media-libs/mesa dev-libs/vulkan-intel"
    ["amd"]="x11-drivers/xf86-video-amdgpu media-libs/mesa dev-libs/vulkan-radeon"
    ["vmware"]="app-emulation/open-vm-tools x11-drivers/xf86-video-vmware"
    ["qemu"]="app-emulation/spice-vdagent app-emulation/qemu-guest-agent x11-drivers/xf86-video-qxl"
    ["virtualbox"]="app-emulation/virtualbox-guest-additions"
    ["unknown"]="media-libs/mesa x11-drivers/xf86-video-vesa"
)

SHELL_CHOICES=("bash" "Bash" "zsh" "Zsh" "fish" "Fish")
PRIV_ESCALATION_CHOICES=("sudo" "sudo" "doas" "doas" "none" "none")

declare -A EXTRA_PACKAGES
EXTRA_PACKAGES=(
    ["firefox"]="www-client/firefox"
    ["neovim"]="app-editors/neovim"
    ["alacritty"]="x11-terms/alacritty"
    ["mpv"]="media-video/mpv"
    ["flatpak"]="sys-apps/flatpak"
    ["firewalld"]="net-firewall/firewalld"
    ["git"]="dev-vcs/git"
    ["htop"]="sys-process/htop"
    ["tmux"]="app-misc/tmux"
    ["links"]="www-client/links"
)

GENTOO_BINHOST="${GENTOO_BINHOST:-https://distfiles.gentoo.org/releases/amd64/binpackages/23.0/x86-64/}"
X86_64_V3_BINHOST="https://distfiles.gentoo.org/releases/amd64/binpackages/23.0/x86-64-v3/"

declare -A USE_GLOBAL_DEFAULTS
USE_GLOBAL_DEFAULTS=(
    ["X"]="yes"
    ["wayland"]="no"
    ["pulseaudio"]="no"
    ["pipewire"]="yes"
    ["networkmanager"]="yes"
    ["gtk"]="yes"
    ["qt5"]="no"
    ["qt6"]="no"
    ["gnome"]="no"
    ["kde"]="no"
    ["systemd"]="no"
    ["elogind"]="yes"
    ["cups"]="no"
    ["bluetooth"]="yes"
    ["ipv6"]="yes"
)

declare -A DESKTOP_USE_SUGGESTIONS
DESKTOP_USE_SUGGESTIONS=(
    ["gnome"]="-kde -qt5 -qt6 gnome gtk wayland"
    ["kde"]="-gnome -gtk kde qt5 qt6"
    ["xfce"]="gtk -kde -qt5 -qt6 -gnome"
    ["i3"]="gtk -kde -qt5 -qt6 -gnome X"
)

BASE_PACKAGES+=(
    sys-process/cronie
    app-admin/sysklogd
    app-portage/gentoolkit
    sys-firmware/sof-firmware
    sys-apps/mlocate
    sys-block/io-scheduler-udev-rules
    sys-fs/xfsprogs
    sys-fs/e2fsprogs
    sys-fs/dosfstools
)

gentoo_post_install() {
    log_info "Running Gentoo post-install hooks..."
    pkg_chroot emerge --sync
    pkg_chroot eselect news read new
    pkg_chroot getuto
    if [[ "$(state_get INSTALL_EIX)" == "yes" ]]; then
        pkg_install app-portage/eix
        pkg_chroot eix-update
    fi

    pkg_install net-misc/chrony
    enable_service chronyd

    gforge_show_news
    gforge_service_picker

    local kernel_choice
    kernel_choice="$(state_get KERNEL_CHOICE)"
    if [[ "${kernel_choice}" =~ source || "${kernel_choice}" == "gentoo-kernel" ]]; then
        tui_msg_quick "Module Rebuild" "If you install external kernel modules later (nvidia-drivers, virtualbox-modules, zfs), run:\n\n  emerge @module-rebuild"
    fi
}