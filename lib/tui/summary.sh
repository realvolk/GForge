#!/usr/bin/env bash
set -Eeuo pipefail

gforge_show_summary() {
    local summary
    printf -v summary \
"Disk:           %s
Boot mode:      %s
Stage3 variant:  %s
Portage profile: %s
Filesystem:      %s
LUKS:            %s
LVM:             %s
Bootloader:      %s
Kernel:          %s
Kernel config:   %s
Init:            %s
Desktop:         %s
Display Manager: %s
VIDEO_CARDS:     %s
Audio:           %s
Network:         %s
Hostname:        %s
Timezone:        %s
Locale:          %s
Keymap:          %s
CFLAGS:          %s
MAKEOPTS:        %s
USE flags:       %s
Licenses:        %s
Binhost:         %s
Overlays:        %s
Extras:          %s
Shell:           %s
Privilege esc:   %s" \
        "$(state_get DISK)" \
        "${VFF_BOOT_MODE}" \
        "$(state_get STAGE3_VARIANT)" \
        "$(state_get PORTAGE_PROFILE)" \
        "$(state_get FS_TYPE)" \
        "$(state_get USE_LUKS no)" \
        "$(state_get USE_LVM no)" \
        "$(state_get BOOTLOADER)" \
        "$(state_get KERNEL_CHOICE)" \
        "$(state_get KERNEL_CONFIG_METHOD)" \
        "$(state_get INIT)" \
        "$(state_get WM_DE)" \
        "$(state_get DISPLAY_MANAGER)" \
        "$(state_get VIDEO_CARDS)" \
        "$(state_get AUDIO_STACK)" \
        "$(state_get NETWORK_STACK)" \
        "$(state_get HOSTNAME)" \
        "$(state_get TIMEZONE)" \
        "$(state_get LOCALE)" \
        "$(state_get KEYMAP)" \
        "$(state_get GENTOO_CFLAGS)" \
        "$(state_get GENTOO_MAKEOPTS)" \
        "$(state_get GLOBAL_USE)" \
        "$(state_get ACCEPTED_LICENSES)" \
        "$(state_get USE_BINHOST)" \
        "$(state_get ENABLED_OVERLAYS)" \
        "$(state_get EXTRAS)" \
        "$(state_get USER_SHELL)" \
        "$(state_get PRIV_ESCALATION)"
    tui_msg "Installation Summary" "${summary}"
    if ! tui_yesno "Proceed?" "Proceed with installation?"; then
        exit 0
    fi
    if [[ -n "${FORGE_TUI_DAEMON:-}" ]]; then
        unset FORGE_TUI_DAEMON
        [[ -S "${FORGE_TUI_SOCKET:-}" ]] && printf '{"widget":"quit"}\n' | nc -U "${FORGE_TUI_SOCKET}" 2>/dev/null
        rm -f "${FORGE_TUI_SOCKET}"
    fi
}

gforge_sanity_warnings() {
    local warnings=()
    [[ "${VFF_BOOT_MODE}" == "bios" ]] && warnings+=("BIOS boot mode — UEFI-only features disabled")
    [[ "$(state_get KERNEL_CHOICE)" =~ source && "$(state_get KERNEL_CONFIG_METHOD)" == "manual" ]] && warnings+=("Manual kernel config — ensure essential drivers")
    [[ "$(state_get USE_BINHOST)" == "yes" ]] && warnings+=("Binhost enabled — prebuilt binaries will be used")
    [[ "$(state_get GLOBAL_USE)" == *"lto"* ]] && warnings+=("USE=lto may break packages")
    [[ "$(state_get GLOBAL_USE)" == *"systemd"* && "$(state_get INIT)" == "openrc" ]] && warnings+=("USE=systemd with OpenRC may cause issues")

    local extras="$(state_get EXTRAS)"
    local wm="$(state_get WM_DE)"
    if [[ "${extras}" =~ firefox || "${wm}" =~ (gnome|kde) ]]; then
        if ! pkg_chroot bash -c 'command -v rustc' &>/dev/null; then
            warnings+=("Packages may require Rust (dev-lang/rust or dev-lang/rust-bin). Consider enabling binhost or installing rust-bin for faster builds.")
        fi
    fi

    if [[ ${#warnings[@]} -gt 0 ]]; then
        local msg
        msg=$(printf ' - %s\n' "${warnings[@]}")
        tui_msg "Sanity Warnings" "${msg}"
    fi
}

gforge_boot_mode_notice() {
    if [[ "${VFF_BOOT_MODE}" == "bios" ]]; then
        tui_msg_quick "BIOS Mode" "Legacy BIOS boot detected. UEFI-only features are disabled."
    fi
}