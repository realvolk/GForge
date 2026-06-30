#!/usr/bin/env bash
set -Eeuo pipefail

gforge_manage_overlays() {
    if ! command -v eselect &>/dev/null; then
        log_warn "eselect not available."
        return 0
    fi

    local overlays_raw
    overlays_raw=$(eselect repository list 2>/dev/null | grep -v '^\s*$' || true)
    if [[ -z "${overlays_raw}" ]]; then
        return 0
    fi

    local -a overlay_names=()
    while IFS= read -r line; do
        local name
        name=$(echo "${line}" | awk '{print $2}' || true)
        [[ -n "${name}" ]] && overlay_names+=("${name}")
    done <<< "${overlays_raw}"

    if [[ ${#overlay_names[@]} -eq 0 ]]; then
        return 0
    fi

    local selected
    selected=$(tui_multiselect "Overlays" "Type to search, Space to toggle:" "Search overlays..." 0 0 "${overlay_names[@]}") || true
    state_set ENABLED_OVERLAYS "${selected//$'\n'/ }"

    if tui_yesno "Overlay priorities" "Edit overlay priorities file?"; then
        tui_edit "Overlay priorities" "/mnt/etc/portage/repos.conf"
    fi
}