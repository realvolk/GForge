#!/usr/bin/env bash
set -Eeuo pipefail

gforge_configure_kernel() {
    local kernel_choice
    kernel_choice="$(state_get KERNEL_CHOICE gentoo-kernel)"
    case "${kernel_choice}" in
        gentoo-sources)
            if tui_yesno "Kernel Config" "Use genkernel for automated configuration?"; then
                state_set KERNEL_CONFIG_METHOD "genkernel"
            else
                state_set KERNEL_CONFIG_METHOD "manual"
            fi
            if tui_yesno "Dracut" "Use dracut instead of genkernel for initramfs?"; then
                state_set USE_DRACUT "yes"
            fi
            if [[ "$(state_get KERNEL_CONFIG_METHOD)" == "manual" ]]; then
                tui_msg_quick "menuconfig" "You will be dropped into menuconfig during install."
            fi
            ;;
        gentoo-sources-genkernel)
            state_set KERNEL_CONFIG_METHOD "genkernel"
            ;;
        *)
            state_set KERNEL_CONFIG_METHOD "binary"
            if tui_yesno "Kernel Config Diff" "View differences from the default distribution kernel config?"; then
                gforge_kernel_config_diff
            fi
            ;;
    esac
    if tui_yesno "installkernel" "Use sys-kernel/installkernel to automate kernel installation and initramfs?"; then
        state_set USE_INSTALLKERNEL "yes"
        local installkernel_use=""
        if [[ "$(state_get USE_DRACUT)" == "yes" ]]; then
            installkernel_use+=" dracut"
        fi
        if [[ "${VFF_BOOT_MODE}" != "bios" ]]; then
            if tui_yesno "UKI" "Generate Unified Kernel Images?"; then
                installkernel_use+=" uki"
                state_set GENERATE_UKI "yes"
            fi
        fi
        local bl="$(state_get BOOTLOADER grub)"
        case "${bl}" in
            grub) installkernel_use+=" grub" ;;
            systemd-boot) installkernel_use+=" systemd-boot systemd" ;;
            efistub) installkernel_use+=" efistub" ;;
        esac
        state_set INSTALLKERNEL_USE "${installkernel_use}"
    fi
}

gforge_kernel_config_diff() {
    local default_config=""
    for candidate in /usr/src/linux/arch/x86/configs/x86_64_defconfig /usr/src/linux/arch/x86/configs/generic-64_defconfig; do
        [[ -f "${candidate}" ]] && { default_config="${candidate}"; break; }
    done
    if [[ -z "${default_config}" ]]; then
        tui_msg "Config Diff" "No default config found to compare against."
        return 0
    fi
    local diff_output
    diff_output=$(diff -u "${default_config}" /usr/src/linux/.config 2>/dev/null | head -200 || true)
    if [[ -n "${diff_output}" ]]; then
        tui_show_file "Kernel Config Diff" <(echo "${diff_output}")
    else
        tui_msg "Config Diff" "No differences from the default configuration."
    fi
}

gforge_select_defconfig() {
    local kernel_choice method
    kernel_choice="$(state_get KERNEL_CHOICE gentoo-kernel)"
    method="$(state_get KERNEL_CONFIG_METHOD binary)"
    if [[ "${kernel_choice}" != "gentoo-sources" && "${kernel_choice}" != "gentoo-sources-genkernel" ]]; then
        return 0
    fi
    if [[ "${method}" != "manual" ]]; then
        return 0
    fi
    if ! tui_yesno "Kernel Defconfig" "Start from a pre-built minimal config?"; then
        return 0
    fi
    local -a defconfigs=()
    local defconfig_dir="${GFORGE_DIR}/lib/kernel/defconfigs"
    for f in "${defconfig_dir}"/*.config; do
        [[ -f "${f}" ]] && defconfigs+=("$(basename "${f}" .config)")
    done
    if [[ ${#defconfigs[@]} -eq 0 ]]; then
        return 0
    fi
    local chosen
    chosen=$(tui_menu "Defconfig" "Choose a base configuration:" "${defconfigs[@]}") || return 0
    mkdir -p /mnt/usr/src/linux
    cp "${defconfig_dir}/${chosen}.config" "/mnt/usr/src/linux/.config"
    log_info "Copied ${chosen}.config"
    state_set KERNEL_DEFCONFIG "${chosen}"
    if tui_yesno "Edit config" "Edit the kernel configuration now?"; then
        tui_edit "Kernel .config" "/mnt/usr/src/linux/.config"
    fi
}