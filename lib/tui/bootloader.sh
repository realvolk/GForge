#!/usr/bin/env bash
set -Eeuo pipefail

gforge_configure_grub_theme() {
    if tui_yesno "GRUB theme" "Install a dark GRUB theme?"; then
        state_set GRUB_THEME "yes"
    fi
}

gforge_configure_bootloader_timeout() {
    local timeout
    timeout=$(tui_input "Bootloader timeout" "Seconds:" "5")
    timeout="${timeout:-5}"
    state_set BOOTLOADER_TIMEOUT "${timeout}"
    mkdir -p /mnt/etc/default
    if [[ -f /mnt/etc/default/grub ]]; then
        if grep -q "^GRUB_TIMEOUT=" /mnt/etc/default/grub 2>/dev/null; then
            sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=${timeout}/" /mnt/etc/default/grub
        else
            echo "GRUB_TIMEOUT=${timeout}" >> /mnt/etc/default/grub
        fi
    fi
}

gforge_configure_dualboot() {
    if tui_yesno "Dual-boot" "Enable os-prober to detect other OSes?"; then
        state_set ENABLE_OS_PROBER "yes"
    fi
}