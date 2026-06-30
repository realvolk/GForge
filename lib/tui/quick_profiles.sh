#!/usr/bin/env bash
set -Eeuo pipefail

gforge_quick_profile_menu() {
    local choice
    choice=$(tui_menu "Quick Profile" "Start with a pre-configured setup or configure everything manually:" \
        "Desktop"  "GNOME, PipeWire, NetworkManager, Firefox, Neovim, Flatpak" \
        "Server"   "Headless, OpenRC, SSH, cronie, firewalld" \
        "Minimal"  "Stage3 + essentials only" \
        "Custom"   "Full manual configuration – every option, your choices") || choice="Custom"

    case "${choice}" in
        Desktop)
            source "${GFORGE_DIR}/profiles/quick/desktop.sh"
            state_set QUICK_PROFILE "desktop"
            log_info "Loaded Desktop quick profile"
            ;;
        Server)
            source "${GFORGE_DIR}/profiles/quick/server.sh"
            state_set QUICK_PROFILE "server"
            log_info "Loaded Server quick profile"
            ;;
        Minimal)
            source "${GFORGE_DIR}/profiles/quick/minimal.sh"
            state_set QUICK_PROFILE "minimal"
            log_info "Loaded Minimal quick profile"
            ;;
        *)
            state_set QUICK_PROFILE "custom"
            ;;
    esac
}