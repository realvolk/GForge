#!/usr/bin/env bash
set -Eeuo pipefail

gforge_download_handbook() {
    if tui_yesno "Handbook" "Download Gentoo Handbook for offline reference?"; then
        local lang
        lang=$(tui_input "Language" "Language code (e.g. en):" "en")
        local url="https://wiki.gentoo.org/wiki/Handbook:Main_Page/${lang}"
        local dest="/mnt/root/gentoo-handbook-${lang}.html"
        log_info "Downloading Gentoo Handbook (${lang})..."
        if curl -sL "${url}" -o "${dest}" 2>/dev/null; then
            tui_msg_quick "Done" "Handbook saved to ${dest}"
        else
            log_warn "Failed to download handbook."
        fi
    fi
}