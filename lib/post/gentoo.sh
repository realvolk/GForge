#!/usr/bin/env bash
set -Eeuo pipefail

gforge_show_news() {
    local news_items
    news_items=$(pkg_chroot eselect news list 2>/dev/null | grep 'unread' || true)
    if [[ -n "${news_items}" ]]; then
        if tui_yesno "Gentoo News" "There are unread news items. Read now?"; then
            pkg_chroot bash -c 'eselect news read' | while IFS= read -r line; do log_info "${line}"; done
            tui_msg "News" "News items displayed in log."
        fi
    fi
}

gforge_service_picker() {
    local init="${INIT:-openrc}"
    if ! tui_yesno "Services" "Configure boot services?"; then return 0; fi
    local -a available=()
    case "${init}" in
        openrc)
            for svc in /mnt/etc/init.d/*; do
                [[ -x "${svc}" ]] && available+=("$(basename "${svc}")")
            done
            ;;
        systemd)
            available=("sshd" "cronie" "dbus" "display-manager")
            ;;
    esac
    [[ ${#available[@]} -gt 0 ]] || return 0
    local sel
    sel=$(tui_multiselect "Boot Services" "Type to search, Space to toggle:" "Search services..." 0 0 "${available[@]}") || true
    for s in ${sel}; do
        case "${init}" in
            openrc) pkg_chroot rc-update add "${s}" default ;;
            systemd) pkg_chroot systemctl enable "${s}" ;;
        esac
        log_info "Enabled service: ${s}"
    done
}

gforge_post_install_extras() {
    local dm init
    dm="$(state_get DISPLAY_MANAGER none)"
    init="$(state_get INIT openrc)"

    if [[ "$(state_get USE_INSTALLKERNEL)" == "yes" ]]; then
        local use_flags="$(state_get INSTALLKERNEL_USE)"
        mkdir -p /mnt/etc/portage/package.use
        echo "sys-kernel/installkernel ${use_flags}" > /mnt/etc/portage/package.use/installkernel
        pkg_install sys-kernel/installkernel
    fi
    if [[ "$(state_get ENABLE_OS_PROBER)" == "yes" ]]; then
        pkg_install sys-boot/os-prober
        echo 'GRUB_DISABLE_OS_PROBER=false' >> /mnt/etc/default/grub
        mkdir -p /mnt/run/udev
        mount -o bind /run/udev /mnt/run/udev 2>/dev/null || true
        mount --make-rslave /mnt/run/udev 2>/dev/null || true
    fi
    if [[ "${init}" == "systemd" ]]; then
        pkg_chroot systemd-machine-id-setup
        pkg_chroot systemd-firstboot --prompt --locale="$(state_get LOCALE)" --timezone="$(state_get TIMEZONE)" --hostname="$(state_get HOSTNAME)"
    fi
    if [[ "$(state_get USE_BINHOST)" == "yes" ]]; then
        pkg_chroot getuto
    fi
    if [[ -n "$(state_get VIDEO_CARDS)" ]]; then
        mkdir -p /mnt/etc/portage/package.use
        echo "*/* VIDEO_CARDS: -* $(state_get VIDEO_CARDS)" > /mnt/etc/portage/package.use/00video_cards
    fi
    [[ "$(state_get INSTALL_VULKAN)" == "yes" ]] && pkg_install media-libs/vulkan-loader mesa-vulkan-drivers
    [[ "$(state_get INSTALL_PRINTER)" == "yes" ]] && { pkg_install net-print/cups system-config-printer; enable_service cupsd; }
    [[ "$(state_get INSTALL_BLUETOOTH)" == "yes" ]] && { pkg_install net-wireless/bluez; enable_service bluetooth; }
    [[ "$(state_get INSTALL_TLP)" == "yes" ]] && { pkg_install sys-power/tlp; enable_service tlp; }
    [[ "$(state_get ENABLE_TRIM)" == "yes" ]] && { pkg_install sys-apps/util-linux; pkg_chroot systemctl enable fstrim.timer 2>/dev/null || true; }
    [[ "$(state_get INSTALL_NM_APPLET)" == "yes" ]] && pkg_install gnome-extra/nm-applet gnome-base/gnome-keyring
    [[ "$(state_get INSTALL_FONTS)" == "yes" ]] && pkg_install media-fonts/noto media-fonts/dejavu
    [[ "$(state_get INPUT_METHOD)" == "ibus" ]] && pkg_install app-i18n/ibus
    [[ "$(state_get INPUT_METHOD)" == "fcitx" ]] && pkg_install app-i18n/fcitx
    [[ "$(state_get INSTALL_VIRT)" == "yes" ]] && { pkg_install app-emulation/libvirt app-emulation/virt-manager app-emulation/qemu; enable_service libvirtd; }
    [[ "$(state_get INSTALL_CONTAINERS)" == "yes" ]] && { pkg_install app-containers/docker app-containers/podman; enable_service docker; }
    [[ "$(state_get INSTALL_DEVTOOLS)" == "yes" ]] && pkg_install sys-devel/gcc sys-devel/make dev-vcs/git dev-util/strace dev-util/ltrace dev-util/valgrind dev-util/gdb
    [[ "$(state_get INSTALL_GAMING)" == "yes" ]] && pkg_install games-util/steam app-emulation/wine games-util/lutris games-util/gamemode
    [[ "$(state_get FIREWALL_PACKAGE)" == "firewalld" ]] && { pkg_install net-firewall/firewalld; enable_service firewalld; }
    [[ "$(state_get FIREWALL_PACKAGE)" == "ufw" ]] && { pkg_install net-firewall/ufw; enable_service ufw; }
    [[ "$(state_get FIREWALL_PACKAGE)" == "nftables" ]] && { pkg_install net-firewall/nftables; enable_service nftables; }
    if [[ "$(state_get ENABLE_SSHD)" == "yes" ]]; then
        pkg_install net-misc/openssh
        pkg_chroot rc-update add sshd default 2>/dev/null || true
        pkg_chroot ssh-keygen -A
    fi
    if [[ -n "$(state_get SWAP_FILE_SIZE)" ]]; then
        local size="${SWAP_FILE_SIZE:-2G}"
        pkg_chroot fallocate -l "${size}" /swapfile
        pkg_chroot chmod 600 /swapfile
        pkg_chroot mkswap /swapfile
        pkg_chroot swapon /swapfile
        echo "/swapfile none swap sw 0 0" >> /mnt/etc/fstab
    fi
    [[ "$(state_get TMPFS_TMP)" == "yes" ]] && echo "tmpfs /tmp tmpfs defaults,noatime 0 0" >> /mnt/etc/fstab
    [[ "$(state_get GRUB_THEME)" == "yes" ]] && pkg_install sys-boot/grub-theme
    [[ -n "$(state_get MICROCODE_PACKAGE)" ]] && pkg_install "$(state_get MICROCODE_PACKAGE)"
    [[ "$(state_get USE_ECRYPTFS)" == "yes" ]] && { pkg_install sys-fs/ecryptfs-utils; pkg_chroot ecryptfs-migrate-home -u "$(state_get USER_NAME)" 2>/dev/null || true; }
    [[ -n "$(state_get BLACKLIST_MODULES)" ]] && { for mod in $(state_get BLACKLIST_MODULES); do echo "blacklist ${mod}" >> /mnt/etc/modprobe.d/blacklist.conf; done; }
    [[ "$(state_get REBUILD_WORLD)" == "yes" ]] && { log_info "Starting emerge -e @world..."; pkg_chroot emerge -e @world; }
    [[ "$(state_get POST_INSTALL_SCRIPT)" == "yes" ]] && chmod +x /mnt/root/post-install.sh
    [[ -n "$(state_get WORLD_PACKAGES)" ]] && { for pkg in $(state_get WORLD_PACKAGES); do echo "${pkg}" >> /mnt/var/lib/portage/world; done; }
    if [[ "$(state_get AUTO_LOGIN)" == "yes" && "${dm}" != "none" ]]; then
        case "${dm}" in
            gdm) pkg_chroot sed -i '/^\[daemon\]/a AutomaticLoginEnable=true\nAutomaticLogin='"$(state_get USER_NAME)" /etc/gdm/custom.conf 2>/dev/null || true ;;
            sddm) mkdir -p /mnt/etc/sddm.conf.d; echo -e "[Autologin]\nUser=$(state_get USER_NAME)\nSession=$(state_get WM_DE).desktop" > /mnt/etc/sddm.conf.d/autologin.conf ;;
            lightdm) pkg_chroot sed -i 's/^#autologin-user=/autologin-user='"$(state_get USER_NAME)"'/' /etc/lightdm/lightdm.conf 2>/dev/null || true ;;
        esac
    fi

    [[ -x /mnt/usr/bin/updatedb ]] && pkg_chroot updatedb &
    log_info "Merging configuration file changes..."
    pkg_chroot dispatch-conf

    if tui_yesno "Depclean" "Remove unnecessary packages before reboot?"; then
        pkg_chroot emerge --depclean
    fi

    if [[ "$(state_get ENABLE_OS_PROBER)" == "yes" ]]; then
        umount /mnt/run/udev 2>/dev/null || true
    fi

    gforge_dump_emerge_info
    gforge_write_first_boot_checklist
}

gforge_dump_emerge_info() {
    if tui_yesno "emerge --info" "Save emerge --info output for bug reports?"; then
        pkg_chroot emerge --info > /mnt/root/emerge-info.txt 2>/dev/null || true
        tui_msg_quick "Saved" "emerge --info written to /root/emerge-info.txt"
    fi
}

gforge_write_first_boot_checklist() {
    local dest="/mnt/root/gentooforge-first-boot.txt"
    {
        echo "GentooForge First Boot Checklist"
        echo "================================="
        echo ""
        echo "Hostname: $(state_get HOSTNAME)"
        echo "Network: $(state_get NETWORK_STACK)"
        echo "Init system: $(state_get INIT)"
        echo "Services enabled: cronie sysklogd chronyd $(state_get ENABLE_SSHD && echo sshd)"
        echo "Display manager: $(state_get DISPLAY_MANAGER)"
        echo "Desktop: $(state_get WM_DE)"
        echo ""
        echo "Next steps:"
        echo "1. Log in as $(state_get USER_NAME)"
        echo "2. Verify network: ping gentoo.org"
        echo "3. Review USE flags: emerge --info | grep USE"
        echo "4. Update system: emerge --sync && emerge -uDN @world"
        echo "5. Read news: eselect news read"
        if [[ "$(state_get USE_BINHOST)" == "yes" ]]; then
            echo "6. Binhost is configured. Binary packages will be used when available."
        fi
        if [[ -n "$(state_get VIDEO_CARDS)" ]]; then
            echo "7. VIDEO_CARDS set to: $(state_get VIDEO_CARDS)"
        fi
        echo ""
        echo "For help: links https://wiki.gentoo.org/wiki/Handbook:AMD64"
    } > "${dest}"
    tui_msg_quick "Checklist" "First boot checklist written to /root/gentooforge-first-boot.txt"
}

gforge_save_profile() {
    if tui_yesno "Save Profile" "Save installation configuration for reuse?"; then
        local dest="/mnt/etc/gentooforge-profile.conf"
        {
            for var in DISK FS_TYPE BOOTLOADER KERNEL_CHOICE INIT WM_DE DISPLAY_MANAGER NETWORK_STACK AUDIO_STACK PRIV_ESCALATION HOSTNAME TIMEZONE LOCALE KEYMAP GENTOO_CFLAGS GENTOO_MAKEOPTS GLOBAL_USE ACCEPTED_LICENSES USE_BINHOST BINHOST_URL ENABLED_OVERLAYS STAGE3_VARIANT PORTAGE_PROFILE QUICK_PROFILE VIDEO_CARDS; do
                echo "${var}=$(state_get "${var}")"
            done
        } > "${dest}"
        tui_msg_quick "Saved" "Profile saved to ${dest}"
    fi
}

gforge_show_log() {
    if tui_yesno "Install Log" "View the full installation log?"; then
        tui_show_file "Install Log" "${LOG_FILE:-/tmp/vff-installer.log}"
    fi
}