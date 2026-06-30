#!/usr/bin/env bash
set -Eeuo pipefail

gforge_quick_profile_menu() {
    local choice
    choice=$(tui_menu "Quick Profile" "Choose a pre-configured system:" \
        "Desktop" "Server" "Minimal" "Custom") || choice="Custom"
    case "${choice}" in
        Desktop) source "${GFORGE_DIR}/profiles/quick/desktop.sh"; state_set QUICK_PROFILE "desktop" ;;
        Server)   source "${GFORGE_DIR}/profiles/quick/server.sh"; state_set QUICK_PROFILE "server" ;;
        Minimal)  source "${GFORGE_DIR}/profiles/quick/minimal.sh"; state_set QUICK_PROFILE "minimal" ;;
        *)        state_set QUICK_PROFILE "custom" ;;
    esac
}