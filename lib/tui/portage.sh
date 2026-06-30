#!/usr/bin/env bash
set -Eeuo pipefail

gforge_accept_licenses() {
    local -a licenses=(
        "@FREE" "@BINARY-REDISTRIBUTABLE" "@EULA"
        "GPL-2" "GPL-3" "LGPL-2.1" "BSD" "MIT" "Apache-2.0"
    )
    local selected
    selected=$(tui_multiselect "Licenses" "Type to search, Space to toggle:" "Search licenses..." 0 0 "${licenses[@]}") || true
    state_set ACCEPTED_LICENSES "${selected//$'\n'/ }"
    mkdir -p /mnt/etc/portage
    if [[ -f /mnt/etc/portage/make.conf ]]; then
        if grep -q "^ACCEPT_LICENSE=" /mnt/etc/portage/make.conf 2>/dev/null; then
            sed -i "s/^ACCEPT_LICENSE=.*/ACCEPT_LICENSE=\"${selected//$'\n'/ }\"/" /mnt/etc/portage/make.conf
        else
            echo "ACCEPT_LICENSE=\"${selected//$'\n'/ }\"" >> /mnt/etc/portage/make.conf
        fi
    else
        echo "ACCEPT_LICENSE=\"${selected//$'\n'/ }\"" >> /mnt/etc/portage/make.conf
    fi
}

gforge_configure_emerge_defaults() {
    if tui_yesno "EMERGE_DEFAULTS" "Configure emerge default options and features?"; then
        local -a features=(
            "ccache" "buildpkg" "parallel-install" "keep-going"
            "userpriv" "quiet-build" "getbinpkg" "binpkg-request-signature"
        )
        local selected
        selected=$(tui_multiselect "FEATURES" "Type to search, Space to toggle:" "Search features..." 0 0 "${features[@]}") || true
        state_set EMERGE_FEATURES "${selected//$'\n'/ }"
        local -a opts=("--jobs=4" "--load-average=8")
        local opts_selected
        opts_selected=$(tui_multiselect "EMERGE_DEFAULT_OPTS" "Type to search, Space to toggle:" "Search options..." 0 0 "${opts[@]}") || true
        state_set EMERGE_DEFAULT_OPTS "${opts_selected//$'\n'/ }"

        local features_str="${selected//$'\n'/ }"
        if [[ -n "${features_str}" ]]; then
            mkdir -p /mnt/etc/portage
            if [[ -f /mnt/etc/portage/make.conf ]] && grep -q "^FEATURES=" /mnt/etc/portage/make.conf 2>/dev/null; then
                sed -i "s/^FEATURES=\"/FEATURES=\"${features_str} /" /mnt/etc/portage/make.conf
            else
                echo "FEATURES=\"${features_str}\"" >> /mnt/etc/portage/make.conf
            fi
        fi
        local opts_str="${opts_selected//$'\n'/ }"
        if [[ -n "${opts_str}" ]]; then
            if [[ -f /mnt/etc/portage/make.conf ]] && grep -q "^EMERGE_DEFAULT_OPTS=" /mnt/etc/portage/make.conf 2>/dev/null; then
                sed -i "s/^EMERGE_DEFAULT_OPTS=\"/EMERGE_DEFAULT_OPTS=\"${opts_str} /" /mnt/etc/portage/make.conf
            else
                echo "EMERGE_DEFAULT_OPTS=\"${opts_str}\"" >> /mnt/etc/portage/make.conf
            fi
        fi

        if [[ "${selected}" =~ "ccache" ]]; then
            if tui_yesno "ccache size" "Set ccache cache size? (default 5G)"; then
                local size
                size=$(tui_input "ccache size" "Enter size (e.g. 10G):" "5G")
                state_set CCACHE_SIZE "${size}"
                echo "CCACHE_SIZE=\"${size}\"" >> /mnt/etc/portage/make.conf
            fi
        fi
    fi
}

gforge_configure_binhost() {
    if tui_yesno "Binary Packages" "Use Gentoo binhost for faster installation?"; then
        state_set USE_BINHOST "yes"
        local binhost_url
        if gforge_detect_x86_64_v3; then
            tui_msg_quick "x86-64-v3" "Your CPU supports x86-64-v3. Using optimized binhost."
            binhost_url="${X86_64_V3_BINHOST}"
        else
            binhost_url="${GENTOO_BINHOST}"
        fi
        binhost_url=$(tui_input "Binhost URL" "Enter binhost URL:" "${binhost_url}")
        state_set BINHOST_URL "${binhost_url}"
        if gforge_detect_x86_64_v3 && [[ "${binhost_url}" == *"x86-64-v3"* ]]; then
            state_set USE_DUAL_BINHOST "yes"
        fi
    else
        state_set USE_BINHOST "no"
    fi
}

gforge_detect_x86_64_v3() {
    grep -q 'avx2' /proc/cpuinfo 2>/dev/null && return 0
    return 1
}

gforge_configure_sync_type() {
    local sync
    sync=$(tui_menu "Portage Sync" "Sync method:" "rsync" "git") || sync="rsync"
    state_set PORTAGE_SYNC_TYPE "${sync%% *}"
}

gforge_configure_mirrors() {
    if tui_yesno "GENTOO_MIRRORS" "Select download mirrors?"; then
        if command -v mirrorselect &>/dev/null; then
            mkdir -p /mnt/etc/portage
            mirrorselect -i -o >> /mnt/etc/portage/make.conf 2>/dev/null || true
        else
            local mirrors="https://gentoo.osuosl.org/ https://mirror.leaseweb.com/gentoo/"
            local custom
            custom=$(tui_input "Mirror URL" "Enter mirror URL (space separated):" "${mirrors}")
            state_set GENTOO_MIRRORS "${custom:-${mirrors}}"
            mkdir -p /mnt/etc/portage
            echo "GENTOO_MIRRORS=\"${custom:-${mirrors}}\"" >> /mnt/etc/portage/make.conf
        fi
    fi
}

gforge_configure_accept_keywords() {
    if tui_yesno "ACCEPT_KEYWORDS" "Use testing (~amd64) globally or per-package?"; then
        local scope
        scope=$(tui_menu "Testing scope" "Apply to:" "Global" "Per-package") || scope="Global"
        if [[ "$scope" == "Global"* ]]; then
            state_set ACCEPT_KEYWORDS_GLOBAL "~amd64"
            mkdir -p /mnt/etc/portage
            if [[ -f /mnt/etc/portage/make.conf ]] && grep -q "^ACCEPT_KEYWORDS=" /mnt/etc/portage/make.conf 2>/dev/null; then
                sed -i "s/^ACCEPT_KEYWORDS=.*/ACCEPT_KEYWORDS=\"~amd64\"/" /mnt/etc/portage/make.conf
            else
                echo 'ACCEPT_KEYWORDS="~amd64"' >> /mnt/etc/portage/make.conf
            fi
        fi
    fi
}

gforge_configure_telemetry() {
    if tui_yesno "Telemetry" "Mask Gentoo telemetry package (dev-libs/telemetry)?"; then
        state_set MASK_TELEMETRY "yes"
        mkdir -p /mnt/etc/portage
        echo "dev-libs/telemetry" >> /mnt/etc/portage/package.mask
    fi
}

gforge_configure_video_cards() {
    local gpu vm
    gpu=$(get_gpu_vendor)
    vm=$(detect_vm)

    if [[ "${vm}" != "none" ]]; then
        tui_msg_quick "VM Detected" "Running in ${vm}. Selecting appropriate GPU driver."
        case "${vm}" in
            qemu|kvm)
                state_set VIDEO_CARDS "virgl"
                state_set GPU_USE_FLAGS "-intel -nouveau -nvidia -radeon"
                ;;
            vmware)
                state_set VIDEO_CARDS "vmwgfx"
                state_set GPU_USE_FLAGS "-intel -nouveau -nvidia -radeon"
                ;;
            virtualbox)
                state_set VIDEO_CARDS "vboxvideo"
                state_set GPU_USE_FLAGS "-intel -nouveau -nvidia -radeon"
                ;;
        esac
        mkdir -p /mnt/etc/portage/package.use
        echo "*/* VIDEO_CARDS: -* $(state_get VIDEO_CARDS)" > /mnt/etc/portage/package.use/00video_cards
        mkdir -p /mnt/etc/portage
        if [[ -f /mnt/etc/portage/make.conf ]] && grep -q "^USE=" /mnt/etc/portage/make.conf 2>/dev/null; then
            sed -i "s/^USE=\"/USE=\"$(state_get GPU_USE_FLAGS) /" /mnt/etc/portage/make.conf
        else
            echo "USE=\"$(state_get GPU_USE_FLAGS)\"" >> /mnt/etc/portage/make.conf
        fi
        return 0
    fi

    if tui_yesno "VIDEO_CARDS" "Configure VIDEO_CARDS for detected GPU ($gpu)?"; then
        local driver=""
        local use_flags=""
        case "${gpu}" in
            nvidia)
                if [[ "$(state_get NVIDIA_PROPRIETARY)" == "yes" ]]; then
                    driver="nvidia"
                    use_flags="-intel -radeon -nouveau nvidia"
                else
                    driver="nouveau"
                    use_flags="-intel -radeon -nvidia nouveau"
                fi
                ;;
            intel)
                driver="intel"
                use_flags="-nouveau -nvidia -radeon intel"
                ;;
            amd)
                driver="amdgpu radeonsi"
                use_flags="-intel -nouveau -nvidia radeon"
                ;;
            *)
                driver="vesa"
                use_flags="-intel -nouveau -nvidia -radeon"
                ;;
        esac
        local custom
        custom=$(tui_input "VIDEO_CARDS" "Enter VIDEO_CARDS value:" "${driver}")
        state_set VIDEO_CARDS "${custom:-${driver}}"
        state_set GPU_USE_FLAGS "${use_flags}"
        tui_msg_quick "GPU USE Flags" "Setting: ${use_flags}"

        mkdir -p /mnt/etc/portage/package.use
        echo "*/* VIDEO_CARDS: -* ${custom:-${driver}}" > /mnt/etc/portage/package.use/00video_cards
        mkdir -p /mnt/etc/portage
        if [[ -f /mnt/etc/portage/make.conf ]] && grep -q "^USE=" /mnt/etc/portage/make.conf 2>/dev/null; then
            sed -i "s/^USE=\"/USE=\"${use_flags} /" /mnt/etc/portage/make.conf
        else
            echo "USE=\"${use_flags}\"" >> /mnt/etc/portage/make.conf
        fi
    fi
}