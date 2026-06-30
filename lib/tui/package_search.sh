#!/usr/bin/env bash
set -Eeuo pipefail

gforge_search_packages() {
    local query results
    query=$(tui_input "Package Search" "Enter package name or description:")
    [[ -n "${query}" ]] || return 0
    if [[ -d /mnt/usr ]]; then
        results=$(chroot /mnt emerge --searchdesc "${query}" 2>/dev/null | head -60 || true)
    else
        results=$(emerge --searchdesc "${query}" 2>/dev/null | head -60 || true)
    fi
    if [[ -n "${results}" ]]; then
        tui_show_file "Search Results: ${query}" <(echo "${results}")
    else
        tui_msg "No Results" "No packages found for '${query}'."
    fi
}