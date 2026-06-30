#!/usr/bin/env bash
set -Eeuo pipefail

gforge_desktop_use_suggestions() {
    local wm_de="${WM_DE:-none}"
    local suggestions="${DESKTOP_USE_SUGGESTIONS[$wm_de]:-}"
    if [[ -n "${suggestions}" ]]; then
        tui_msg_quick "USE Suggestions" "Recommended USE flags for ${wm_de}: ${suggestions}"
        state_set DESKTOP_USE_FLAGS "${suggestions}"
        mkdir -p /mnt/etc/portage
        if [[ -f /mnt/etc/portage/make.conf ]] && grep -q "^USE=" /mnt/etc/portage/make.conf 2>/dev/null; then
            sed -i "s/^USE=\"/USE=\"${suggestions} /" /mnt/etc/portage/make.conf
        else
            echo "USE=\"${suggestions}\"" >> /mnt/etc/portage/make.conf
        fi
    fi
}