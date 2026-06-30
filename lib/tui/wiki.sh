#!/usr/bin/env bash
set -Eeuo pipefail

gforge_wiki_search() {
    if ! command -v links &>/dev/null; then
        tui_msg "Wiki Unavailable" "Text browser 'links' not installed. Run: emerge www-client/links"
        return 1
    fi
    local query
    query=$(tui_input "Wiki Search" "Search the Gentoo Wiki:")
    [[ -n "${query}" ]] || return 0
    local results
    results=$(curl -s "https://wiki.gentoo.org/api.php?action=query&list=search&srsearch=${query// /%20}&format=json" 2>/dev/null || true)
    if [[ -z "${results}" ]]; then
        tui_msg "Network Error" "Could not reach the Gentoo Wiki."
        return 1
    fi
    local titles
    titles=$(echo "${results}" | jq -r '.query.search[] | .title' 2>/dev/null || true)
    if [[ -z "${titles}" ]]; then
        tui_msg "No Results" "No pages found."
        return 0
    fi
    local -a menu_items=()
    while IFS= read -r title; do
        [[ -n "${title}" ]] && menu_items+=("${title}")
    done <<< "${titles}"
    local chosen
    chosen=$(tui_menu "Wiki Results" "Select a page:" "${menu_items[@]}") || return 0
    local extract
    extract=$(curl -s "https://wiki.gentoo.org/api.php?action=query&prop=extracts&exintro&explaintext&titles=${chosen// /%20}&format=json" 2>/dev/null \
        | jq -r '.query.pages | to_entries[] | .value.extract // "No preview."' 2>/dev/null || echo "Failed to fetch.")
    tui_show_file "Wiki Preview: ${chosen}" <(echo "${extract}")
    if tui_yesno "Open in Browser" "Open full page in links?"; then
        links "https://wiki.gentoo.org/wiki/${chosen// /_}"
    fi
}