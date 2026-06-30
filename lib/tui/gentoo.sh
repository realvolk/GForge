#!/usr/bin/env bash
set -Eeuo pipefail

for mod in \
    stage3 profile use_flags cflags portage overlays kernel desktop \
    system bootloader advanced summary quick_profiles wiki package_search; do
    source "${GFORGE_DIR}/lib/tui/${mod}.sh"
done

gforge_submenu_system_identity() {
    while true; do
        local choice
        choice=$(tui_menu "System Identity" "Pick an item to configure:" \
            "Hostname      [$(state_get HOSTNAME gentoo)]" \
            "Back") || return
        case "${choice}" in
            Hostname*) gforge_configure_hostname_dhcp ;;
            Back*) return ;;
        esac
    done
}

gforge_submenu_stage3_profile() {
    while true; do
        local choice
        choice=$(tui_menu "Stage3 & Profile" "Pick an item to configure:" \
            "Stage3 variant     [$(state_get STAGE3_VARIANT openrc)]" \
            "Portage profile    [$(state_get PORTAGE_PROFILE default)]" \
            "Back") || return
        case "${choice}" in
            Stage3*) gforge_select_stage3 ;;
            Portage*) gforge_select_profile ;;
            Back*) return ;;
        esac
    done
}

gforge_submenu_compiler_flags() {
    while true; do
        local choice
        choice=$(tui_menu "Compiler Flags" "Pick an item to configure:" \
            "CFLAGS / MAKEOPTS  [$(state_get GENTOO_CFLAGS -march=native -O2 -pipe)]" \
            "RUSTFLAGS          [$(state_get GENTOO_RUSTFLAGS -C target-cpu=native)]" \
            "Per-package CFLAGS [$(if [[ -f /mnt/etc/portage/env/custom-cflags ]]; then echo configured; else echo not set; fi)]" \
            "Back") || return
        case "${choice}" in
            "CFLAGS"*) gforge_configure_cflags ;;
            "RUSTFLAGS"*) gforge_configure_rustflags ;;
            "Per-package"*) gforge_configure_per_package_cflags ;;
            Back*) return ;;
        esac
    done
}

gforge_submenu_use_gpu() {
    while true; do
        local choice
        choice=$(tui_menu "USE Flags & GPU" "Pick an item to configure:" \
            "USE flags          [$(state_get GLOBAL_USE)]" \
            "VIDEO_CARDS        [$(state_get VIDEO_CARDS)]" \
            "Desktop USE suggestions" \
            "Back") || return
        case "${choice}" in
            "USE flags"*) gforge_configure_use_flags ;;
            "VIDEO_CARDS"*) gforge_configure_video_cards ;;
            "Desktop USE"*) gforge_desktop_use_suggestions ;;
            Back*) return ;;
        esac
    done
}

gforge_submenu_kernel() {
    while true; do
        local choice
        choice=$(tui_menu "Kernel" "Pick an item to configure:" \
            "Kernel selection   [$(state_get KERNEL_CHOICE gentoo-kernel)]" \
            "Defconfig snippet  [$(state_get KERNEL_DEFCONFIG none)]" \
            "Microcode          [$(state_get MICROCODE_PACKAGE none)]" \
            "Back") || return
        case "${choice}" in
            "Kernel selection"*) gforge_configure_kernel; gforge_select_defconfig ;;
            "Defconfig"*) gforge_select_defconfig ;;
            "Microcode"*) gforge_configure_microcode ;;
            Back*) return ;;
        esac
    done
}

gforge_submenu_portage() {
    while true; do
        local choice
        choice=$(tui_menu "Portage Configuration" "Pick an item to configure:" \
            "Licenses           [$(state_get ACCEPTED_LICENSES @FREE)]" \
            "Binhost            [$(state_get USE_BINHOST no)]" \
            "EMERGE_DEFAULTS" \
            "Sync type          [$(state_get PORTAGE_SYNC_TYPE rsync)]" \
            "Mirrors            [$(state_get GENTOO_MIRRORS)]" \
            "Overlays           [$(state_get ENABLED_OVERLAYS)]" \
            "ACCEPT_KEYWORDS    [$(state_get ACCEPT_KEYWORDS_GLOBAL amd64)]" \
            "Telemetry opt-out" \
            "Back") || return
        case "${choice}" in
            Licenses*) gforge_accept_licenses ;;
            Binhost*) gforge_configure_binhost ;;
            "EMERGE_DEFAULTS"*) gforge_configure_emerge_defaults ;;
            "Sync type"*) gforge_configure_sync_type ;;
            Mirrors*) gforge_configure_mirrors ;;
            Overlays*) gforge_manage_overlays ;;
            "ACCEPT_KEYWORDS"*) gforge_configure_accept_keywords ;;
            "Telemetry"*) gforge_configure_telemetry ;;
            Back*) return ;;
        esac
    done
}

gforge_submenu_network() {
    while true; do
        local choice
        choice=$(tui_menu "Network & Firewall" "Pick an item to configure:" \
            "Firewall           [$(state_get FIREWALL_PACKAGE none)]" \
            "OpenRC tuning      [$(state_get OPENRC_OPTIONS)]" \
            "Systemd target     [$(state_get SYSTEMD_DEFAULT_TARGET graphical.target)]" \
            "Back") || return
        case "${choice}" in
            Firewall*) gforge_configure_firewall ;;
            "OpenRC"*) gforge_configure_openrc_tuning ;;
            "Systemd"*) gforge_configure_systemd_target ;;
            Back*) return ;;
        esac
    done
}

gforge_submenu_desktop() {
    while true; do
        local choice
        choice=$(tui_menu "Desktop Extras" "Pick an item to configure:" \
            "Desktop extras     [$(state_get INSTALL_VULKAN no)]" \
            "Auto-login         [$(state_get AUTO_LOGIN no)]" \
            "Back") || return
        case "${choice}" in
            "Desktop extras"*) gforge_configure_desktop_extras ;;
            "Auto-login"*) gforge_configure_auto_login ;;
            Back*) return ;;
        esac
    done
}

gforge_submenu_additional() {
    while true; do
        local choice
        choice=$(tui_menu "Additional Software" "Pick an item to configure:" \
            "Tool groups        [$(state_get INSTALL_VIRT no)]" \
            "Swap file          [$(state_get SWAP_FILE_SIZE none)]" \
            "tmpfs /tmp         [$(state_get TMPFS_TMP no)]" \
            "NVIDIA drivers     [$(state_get NVIDIA_PROPRIETARY no)]" \
            "Encrypted swap     [$(state_get ENCRYPTED_SWAP no)]" \
            "Home encryption    [$(state_get USE_ECRYPTFS no)]" \
            "Module blacklist   [$(state_get BLACKLIST_MODULES)]" \
            "World rebuild      [$(state_get REBUILD_WORLD no)]" \
            "Reuse /home        [$(state_get REUSE_HOME no)]" \
            "Post-install script" \
            "World file" \
            "BTRFS layout       [$(state_get BTRFS_LAYOUT standard)]" \
            "Extra groups       [$(state_get EXTRA_GROUPS)]" \
            "Build time estimate" \
            "Back") || return
        case "${choice}" in
            "Tool groups"*) gforge_configure_tool_groups ;;
            "Swap file"*) gforge_configure_swap_file ;;
            "tmpfs"*) gforge_configure_tmpfs ;;
            "NVIDIA"*) gforge_configure_nvidia ;;
            "Encrypted swap"*) gforge_configure_encrypted_swap ;;
            "Home encryption"*) gforge_configure_ecryptfs ;;
            "Module blacklist"*) gforge_configure_module_blacklist ;;
            "World rebuild"*) gforge_configure_world_rebuild ;;
            "Reuse /home"*) gforge_configure_reuse_home ;;
            "Post-install"*) gforge_configure_post_install_script ;;
            "World file"*) gforge_configure_world_file ;;
            "BTRFS layout"*) gforge_configure_btrfs_layout_descriptions ;;
            "Extra groups"*) gforge_configure_extra_groups ;;
            "Build time"*) gforge_configure_estimated_time ;;
            Back*) return ;;
        esac
    done
}

gforge_submenu_bootloader() {
    while true; do
        local choice
        choice=$(tui_menu "Bootloader" "Pick an item to configure:" \
            "GRUB theme         [$(state_get GRUB_THEME no)]" \
            "Bootloader timeout [$(state_get BOOTLOADER_TIMEOUT 5)]" \
            "Dual-boot          [$(state_get ENABLE_OS_PROBER no)]" \
            "Back") || return
        case "${choice}" in
            "GRUB theme"*) gforge_configure_grub_theme ;;
            "Bootloader timeout"*) gforge_configure_bootloader_timeout ;;
            "Dual-boot"*) gforge_configure_dualboot ;;
            Back*) return ;;
        esac
    done
}

gforge_config_menu() {
    while true; do
        local choice
        choice=$(tui_menu "GentooForge Configuration" "Select a category to customize, or proceed:" \
            "System Identity      [host: $(state_get HOSTNAME gentoo)]" \
            "Stage3 & Profile     [init: $(state_get INIT openrc)]" \
            "Compiler Flags       [march: $(gforge_detect_march)]" \
            "USE Flags & GPU      [de: $(state_get WM_DE none)]" \
            "Kernel               [$(state_get KERNEL_CHOICE gentoo-kernel)]" \
            "Portage Config       [binhost: $(state_get USE_BINHOST no)]" \
            "Network & Firewall   [net: $(state_get NETWORK_STACK networkmanager)]" \
            "Desktop Extras       [dm: $(state_get DISPLAY_MANAGER none)]" \
            "Additional Software  [extras: $(state_get EXTRAS none)]" \
            "Bootloader           [$(state_get BOOTLOADER grub)]" \
            "▸ Proceed with installation" \
            "▸ View summary") || { tui_msg_quick "Cancelled" "Installation cancelled."; exit 0; }

        case "${choice}" in
            "System Identity"*)      gforge_submenu_system_identity ;;
            "Stage3 & Profile"*)     gforge_submenu_stage3_profile ;;
            "Compiler Flags"*)       gforge_submenu_compiler_flags ;;
            "USE Flags & GPU"*)      gforge_submenu_use_gpu ;;
            "Kernel"*)               gforge_submenu_kernel ;;
            "Portage Config"*)       gforge_submenu_portage ;;
            "Network & Firewall"*)   gforge_submenu_network ;;
            "Desktop Extras"*)       gforge_submenu_desktop ;;
            "Additional Software"*)  gforge_submenu_additional ;;
            "Bootloader"*)           gforge_submenu_bootloader ;;
            "▸ Proceed"*)
                if tui_yesno "eix" "Install eix for fast package searching?"; then
                    state_set INSTALL_EIX "yes"
                fi
                if tui_yesno "Gentoo Wiki" "Search the Gentoo Wiki for help?"; then
                    gforge_wiki_search
                fi
                gforge_show_summary
                gforge_sanity_warnings
                return 0
                ;;
            "▸ View summary"*)
                gforge_show_summary
                gforge_sanity_warnings
                ;;
        esac
    done
}

gforge_collect_config() {
    gforge_boot_mode_notice
    gforge_detect_wifi_live

    tui_msg_quick "Quick Profile" "Choose a starting point for your installation.\n\nEverything you skip will use a reasonable default.\nYou can customize any section later."
    gforge_quick_profile_menu

    local qp
    qp="$(state_get QUICK_PROFILE custom)"
    if [[ "${qp}" != "custom" ]]; then
        if ! tui_yesno "Customize" "Customize any settings from the quick profile?"; then
            gforge_show_summary
            gforge_sanity_warnings
            return 0
        fi
    fi

    tui_msg_quick "▸ Disk & Storage" "Configure your target disk and filesystem."
    vff_collect_config
    if [[ "${VFF_BOOT_MODE}" != "bios" ]]; then
        mkdir -p /mnt/etc/portage
        grep -q 'GRUB_PLATFORMS' /mnt/etc/portage/make.conf 2>/dev/null || \
            echo 'GRUB_PLATFORMS="efi-64"' >> /mnt/etc/portage/make.conf
    fi

    gforge_config_menu
}