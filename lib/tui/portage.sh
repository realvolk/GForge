#!/usr/bin/env bash
set -Eeuo pipefail

gforge_accept_licenses() {
    local -a licenses=(
        "@FREE" "@BINARY-REDISTRIBUTABLE" "@EULA"
        "GPL-2" "GPL-3" "LGPL-2.1" "BSD" "MIT" "Apache-2.0"
    )
    local selected
    selected=$(tui_checklist "Licenses" "Accept software licenses:" "${licenses[@]}") || true
    state_set ACCEPTED_LICENSES "${selected//$'\n'/ }"
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
            tui_msg_quick "Two binhosts" "Both base and v3 binhosts will be configured for fallback."
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

gforge_configure_emerge_defaults() {
    if tui_yesno "EMERGE_DEFAULTS" "Configure emerge default options and features?"; then
        local -a features=(
            "ccache" "buildpkg" "parallel-install" "keep-going" "userpriv" "quiet-build" "getbinpkg" "binpkg-request-signature"
        )
        local selected
        selected=$(tui_checklist "FEATURES" "Select FEATURES to enable:" "${features[@]}") || true
        state_set EMERGE_FEATURES "${selected//$'\n'/ }"
        local -a opts=(
            "--jobs=4" "--load-average=8"
        )
        local opts_selected
        opts_selected=$(tui_checklist "EMERGE_DEFAULT_OPTS" "Select default emerge options:" "${opts[@]}") || true
        state_set EMERGE_DEFAULT_OPTS "${opts_selected//$'\n'/ }"
        if [[ "${selected}" =~ "ccache" ]]; then
            if tui_yesno "ccache size" "Set ccache cache size? (default 5G)"; then
                local size
                size=$(tui_input "ccache size" "Enter size (e.g. 10G):" "5G")
                state_set CCACHE_SIZE "${size}"
            fi
        fi
    fi
}

gforge_configure_sync_type() {
    local sync
    sync=$(tui_menu "Portage Sync" "Sync method:" "rsync (default)" "git") || sync="rsync"
    state_set PORTAGE_SYNC_TYPE "${sync%% *}"
}

gforge_configure_mirrors() {
    if tui_yesno "GENTOO_MIRRORS" "Select download mirrors?"; then
        if command -v mirrorselect &>/dev/null; then
            mirrorselect -i -o >> /mnt/etc/portage/make.conf 2>/dev/null || true
        else
            local mirrors="https://gentoo.osuosl.org/ https://mirror.leaseweb.com/gentoo/"
            local custom
            custom=$(tui_input "Mirror URL" "Enter mirror URL (space separated):" "${mirrors}")
            state_set GENTOO_MIRRORS "${custom:-${mirrors}}"
        fi
    fi
}

gforge_configure_accept_keywords() {
    if tui_yesno "ACCEPT_KEYWORDS" "Use testing (~amd64) globally or per-package?"; then
        local scope
        scope=$(tui_menu "Testing scope" "Apply to:" "Global (~amd64)" "Per-package") || scope="Global"
        if [[ "$scope" == "Global"* ]]; then
            state_set ACCEPT_KEYWORDS_GLOBAL "~amd64"
        fi
    fi
}

gforge_configure_telemetry() {
    if tui_yesno "Telemetry" "Mask Gentoo telemetry package (dev-libs/telemetry)?"; then
        state_set MASK_TELEMETRY "yes"
    fi
}

gforge_configure_video_cards() {
    local gpu
    gpu=$(get_gpu_vendor)
    if tui_yesno "VIDEO_CARDS" "Configure VIDEO_CARDS for detected GPU?"; then
        local driver=""
        case "${gpu}" in
            nvidia)
                if [[ "$(state_get NVIDIA_PROPRIETARY)" == "yes" ]]; then
                    driver="nvidia"
                else
                    driver="nouveau"
                fi
                ;;
            intel) driver="intel" ;;
            amd)   driver="amdgpu radeonsi" ;;
            *)     driver="vesa" ;;
        esac
        local custom
        custom=$(tui_input "VIDEO_CARDS" "Enter VIDEO_CARDS value:" "${driver}")
        state_set VIDEO_CARDS "${custom:-${driver}}"
    fi
}