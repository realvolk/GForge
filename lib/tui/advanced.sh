#!/usr/bin/env bash
set -Eeuo pipefail

gforge_configure_firewall() {
    if tui_yesno "Firewall" "Install and enable a firewall?"; then
        local fw
        fw=$(tui_menu "Firewall" "Select:" "firewalld" "ufw" "nftables") || fw="firewalld"
        state_set FIREWALL_PACKAGE "${fw}"
    fi
}

gforge_configure_swap_file() {
    if [[ "$(state_get SWAP_ENABLED)" != "yes" ]] && tui_yesno "Swap file" "Create a swap file instead of partition?"; then
        local size
        size=$(tui_input "Swap file size" "Size (e.g. 4G):" "2G")
        state_set SWAP_FILE_SIZE "${size}"
        state_set SWAP_ENABLED "yes"
    fi
}

gforge_configure_tmpfs() {
    if tui_yesno "tmpfs /tmp" "Mount /tmp as tmpfs?"; then
        state_set TMPFS_TMP "yes"
    fi
}

gforge_configure_nvidia() {
    local gpu
    gpu=$(get_gpu_vendor)
    if [[ "${gpu}" == "nvidia" ]]; then
        if tui_yesno "NVIDIA Drivers" "Install proprietary NVIDIA drivers and blacklist nouveau?"; then
            state_set NVIDIA_PROPRIETARY "yes"
        fi
    fi
}

gforge_configure_microcode() {
    local cpu
    cpu=$(detect_cpu)
    if tui_yesno "Microcode" "Install CPU microcode?"; then
        if [[ "${cpu}" == "INTEL" ]]; then
            state_set MICROCODE_PACKAGE "sys-firmware/intel-microcode"
        else
            state_set MICROCODE_PACKAGE "sys-firmware/amd-microcode"
        fi
    fi
}

gforge_configure_encrypted_swap() {
    if [[ "$(state_get USE_LUKS)" == "yes" && "$(state_get SWAP_ENABLED)" == "yes" ]]; then
        if tui_yesno "Encrypted swap" "Encrypt swap with random key?"; then
            state_set ENCRYPTED_SWAP "yes"
        fi
    fi
}

gforge_configure_ecryptfs() {
    if tui_yesno "Home Encryption" "Encrypt user home directory with ecryptfs?"; then
        state_set USE_ECRYPTFS "yes"
    fi
}

gforge_configure_world_rebuild() {
    if tui_yesno "World Rebuild" "Run emerge -e @world after install? (Time consuming)"; then
        state_set REBUILD_WORLD "yes"
    fi
}

gforge_configure_module_blacklist() {
    if tui_yesno "Module Blacklist" "Blacklist kernel modules?"; then
        local mods
        mods=$(tui_input "Modules" "Space-separated list (e.g. nouveau):" "")
        state_set BLACKLIST_MODULES "${mods}"
    fi
}

gforge_configure_post_install_script() {
    if tui_yesno "Post-install script" "Create a first-boot post-install script?"; then
        tui_edit "Post-install script" "/mnt/root/post-install.sh"
        state_set POST_INSTALL_SCRIPT "yes"
    fi
}

gforge_configure_world_file() {
    if tui_yesno "World file" "Pre-populate @world with additional packages?"; then
        local pkgs
        pkgs=$(tui_input "Packages" "Space-separated list:" "")
        state_set WORLD_PACKAGES "${pkgs}"
    fi
}

gforge_configure_reuse_home() {
    if [[ -n "$(state_get ROOT_PART)" ]] && tui_yesno "Reuse /home" "Keep existing /home partition without formatting?"; then
        state_set REUSE_HOME "yes"
    fi
}

gforge_configure_btrfs_layout_descriptions() {
    if [[ "$(state_get FS_TYPE)" == "btrfs" ]]; then
        local layout
        layout=$(tui_menu "BTRFS Layout" "Choose subvolume layout:" \
            "standard (@, @home)" \
            "flat (single subvolume)" \
            "snapshot (@, @home, @log, @pkg, @snapshots)") || layout="standard"
        case "${layout}" in
            standard*) state_set BTRFS_LAYOUT "standard" ;;
            flat*)     state_set BTRFS_LAYOUT "flat" ;;
            snapshot*) state_set BTRFS_LAYOUT "snapshot" ;;
        esac
    fi
}

gforge_configure_estimated_time() {
    local src_count=0
    local kernel="$(state_get KERNEL_CHOICE)"
    if [[ "${kernel}" =~ source ]]; then src_count=$((src_count + 1)); fi
    local wm="${WM_DE:-none}"
    if [[ "${wm}" != "none" ]]; then src_count=$((src_count + 1)); fi
    # rough heuristic
    local cores=$(nproc)
    local minutes=$((src_count * 120 / cores))
    tui_msg_quick "Estimated Build Time" "Rough estimate: ${minutes} minutes for source packages."
}

gforge_detect_wifi_live() {
    if command -v wpa_supplicant &>/dev/null || command -v iwctl &>/dev/null; then
        if tui_yesno "WiFi Setup" "Connect to WiFi network before installation?"; then
            if command -v iwctl &>/dev/null; then
                iwctl
            else
                tui_msg "WiFi" "Run wpa_supplicant manually or use iwd."
            fi
        fi
    fi
}

gforge_configure_openrc_tuning() {
    if [[ "$(state_get INIT)" == "openrc" ]]; then
        if tui_yesno "OpenRC tuning" "Configure OpenRC parallel/hotplug?"; then
            local choices
            choices=$(tui_checklist "OpenRC Options" "Select:" "rc_parallel=YES" "rc_hotplug=YES") || true
            if [[ -n "${choices}" ]]; then
                state_set OPENRC_OPTIONS "${choices//$'\n'/ }"
            fi
        fi
    fi
}

gforge_configure_systemd_target() {
    if [[ "$(state_get INIT)" == "systemd" ]]; then
        local target
        target=$(tui_menu "Systemd Target" "Default target:" "graphical.target" "multi-user.target") || target="graphical.target"
        state_set SYSTEMD_DEFAULT_TARGET "${target}"
    fi
}

gforge_configure_auto_login() {
    local wm="${WM_DE:-none}"
    local dm="${DISPLAY_MANAGER:-none}"
    if [[ "${wm}" != "none" && "${dm}" != "none" ]]; then
        if tui_yesno "Auto-login" "Enable auto-login for first boot?"; then
            state_set AUTO_LOGIN "yes"
        fi
    fi
}

gforge_configure_tool_groups() {
    if tui_yesno "Additional Tools" "Select optional tool groups?"; then
        local groups
        groups=$(tui_checklist "Tool Groups" "Select:" \
            "Virtualization (libvirt/qemu)" \
            "Containers (docker/podman)" \
            "Development (gcc/make/gdb)" \
            "Gaming (steam/wine)") || true
        if [[ "${groups}" =~ "Virtualization" ]]; then state_set INSTALL_VIRT "yes"; fi
        if [[ "${groups}" =~ "Containers" ]]; then state_set INSTALL_CONTAINERS "yes"; fi
        if [[ "${groups}" =~ "Development" ]]; then state_set INSTALL_DEVTOOLS "yes"; fi
        if [[ "${groups}" =~ "Gaming" ]]; then state_set INSTALL_GAMING "yes"; fi
    fi
}