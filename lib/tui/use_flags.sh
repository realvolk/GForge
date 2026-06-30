#!/usr/bin/env bash
set -Eeuo pipefail

gforge_configure_use_flags() {
    local use_desc="/usr/portage/profiles/use.desc"
    [[ -f "${use_desc}" ]] || { log_warn "USE flag descriptions not found."; return 0; }
    local -a use_labels=()
    while IFS= read -r line; do
        [[ "${line}" =~ ^[a-z] ]] || continue
        use_labels+=("${line%% -*} - ${line#*- }")
    done < "${use_desc}"
    if [[ ${#use_labels[@]} -eq 0 ]]; then
        log_warn "No USE flags found."
        return 0
    fi
    tui_msg_quick "USE Flags" "Select global USE flags. Space=toggle, Enter=confirm."
    local selected
    selected=$(tui_checklist "USE Flags" "Toggle flags:" "${use_labels[@]}") || true
    local use_list=""
    for item in ${selected}; do
        item="${item%% -*}"
        use_list+="${item} "
    done
    state_set GLOBAL_USE "${use_list% }"
    if tui_yesno "Edit make.conf manually?" "Use the text editor to adjust make.conf?"; then
        tui_edit "Edit make.conf" "/mnt/etc/portage/make.conf"
    fi
}