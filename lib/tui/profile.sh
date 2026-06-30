#!/usr/bin/env bash
set -Eeuo pipefail

gforge_select_profile() {
    local profiles_raw selected
    if [[ -f /mnt/usr/bin/eselect ]]; then
        profiles_raw=$(chroot /mnt eselect profile list 2>/dev/null || true)
    else
        profiles_raw=$(eselect profile list 2>/dev/null || true)
    fi
    if [[ -z "${profiles_raw}" ]]; then
        log_warn "No Portage profiles found. Skipping."
        return 0
    fi
    local -a menu_items=()
    local -a profile_paths=()
    while IFS= read -r line; do
        local index path stability
        index=$(echo "${line}" | grep -oP '^\s*\[\K[0-9]+' || true)
        path=$(echo "${line}" | grep -oP '\]\s+\K\S+' || true)
        stability="stable"
        [[ "${path}" == *"/exp/"* ]] && stability="exp"
        [[ "${path}" == *"/dev/"* ]] && stability="dev"
        if [[ -n "${index}" && -n "${path}" ]]; then
            profile_paths+=("${path}")
            menu_items+=("${path}|${stability}")
        fi
    done <<< "${profiles_raw}"
    if [[ ${#profile_paths[@]} -eq 0 ]]; then
        log_warn "Could not parse profile list."
        return 0
    fi
    local menu_json
    menu_json=$(for i in "${!menu_items[@]}"; do
        local label="${menu_items[$i]%%|*}"
        local stab="${menu_items[$i]##*|}"
        printf '{"label":"%s","stability":"%s"}\n' "${label}" "${stab}"
    done | jq -s .)
    local stability_colors='{"stable":"green","dev":"yellow","exp":"red"}'
    selected=$(_forge_result '{"widget":"menu","title":"Portage Profile","message":"Select system profile:","choices":'"${menu_json}"',"stability_colors":'"${stability_colors}"'}')
    selected="${selected:-${profile_paths[0]}}"
    state_set PORTAGE_PROFILE "${selected}"
    log_info "Profile selected: ${selected}"

    if tui_yesno "Profile Inheritance" "View the profile inheritance chain?"; then
        gforge_show_profile_inheritance "${selected}"
    fi

    if tui_yesno "Profile Variant" "Select a variant within this profile (e.g. desktop, systemd)?"; then
        local variant_list
        variant_list=$(eselect profile list 2>/dev/null | grep "${selected}" | grep -v '^\s*\[' | awk '{print $2}' | sort -u || true)
        if [[ -n "${variant_list}" ]]; then
            local variant_choice
            variant_choice=$(printf '%s\n' "${variant_list}" | tui_menu "Profile Variant" "Choose variant:") || true
            if [[ -n "${variant_choice}" ]]; then
                selected="${variant_choice}"
                state_set PORTAGE_PROFILE "${selected}"
            fi
        fi
    fi
}

gforge_show_profile_inheritance() {
    local profile_path="${1}"
    local current="${profile_path}"
    local chain=""
    local dir

    while [[ -n "${current}" ]]; do
        chain+="${current}\n"
        local parent_file=""
        for dir in "/var/db/repos/gentoo/profiles/${current}" "/mnt/var/db/repos/gentoo/profiles/${current}"; do
            if [[ -f "${dir}/parent" ]]; then
                parent_file="${dir}/parent"
                break
            fi
        done
        if [[ -n "${parent_file}" ]]; then
            current=$(head -n1 "${parent_file}" 2>/dev/null || true)
        else
            current=""
        fi
    done
    if [[ -n "${chain}" ]]; then
        tui_show_file "Profile Inheritance" <(echo -e "${chain}")
    else
        tui_msg "Profile Inheritance" "Could not determine inheritance chain for ${profile_path}"
    fi
}