#!/usr/bin/env bash
set -Eeuo pipefail

for mod in \
    stage3 profile use_flags cflags portage overlays kernel desktop \
    system bootloader advanced summary quick_profiles wiki package_search; do
    source "${GFORGE_DIR}/lib/tui/${mod}.sh"
done

gforge_collect_config() {
    gforge_boot_mode_notice
    gforge_detect_wifi_live
    gforge_quick_profile_menu
    local qp
    qp="$(state_get QUICK_PROFILE custom)"
    if [[ "${qp}" != "custom" ]]; then
        if ! tui_yesno "Customize" "Customize quick profile settings?"; then
            gforge_show_summary
            gforge_sanity_warnings
            return 0
        fi
    fi
    vff_collect_config
    gforge_select_stage3
    gforge_select_profile
    gforge_configure_cflags
    gforge_configure_use_flags
    gforge_configure_video_cards
    gforge_configure_kernel
    gforge_select_defconfig
    gforge_manage_overlays
    gforge_accept_licenses
    gforge_configure_binhost
    gforge_desktop_use_suggestions
    gforge_configure_emerge_defaults
    gforge_configure_sync_type
    gforge_configure_mirrors
    gforge_configure_openrc_tuning
    gforge_configure_systemd_target
    gforge_configure_firewall
    gforge_configure_swap_file
    gforge_configure_grub_theme
    gforge_configure_bootloader_timeout
    gforge_configure_hostname_dhcp
    gforge_configure_nvidia
    gforge_configure_microcode
    gforge_configure_tmpfs
    gforge_configure_extra_groups
    gforge_configure_desktop_extras
    gforge_configure_tool_groups
    gforge_configure_auto_login
    gforge_configure_encrypted_swap
    gforge_configure_world_rebuild
    gforge_configure_telemetry
    gforge_configure_accept_keywords
    gforge_configure_reuse_home
    gforge_configure_ecryptfs
    gforge_configure_module_blacklist
    gforge_configure_post_install_script
    gforge_configure_world_file
    gforge_configure_btrfs_layout_descriptions
    gforge_configure_dualboot
    gforge_configure_estimated_time
    if tui_yesno "eix" "Install eix for fast package searching?"; then
        state_set INSTALL_EIX "yes"
    fi
    if tui_yesno "Gentoo Wiki" "Search the Gentoo Wiki for help?"; then
        gforge_wiki_search
    fi
    gforge_show_summary
    gforge_sanity_warnings
}