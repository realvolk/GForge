#!/usr/bin/env bash
set -Eeuo pipefail

gforge_select_stage3() {
    local variant
    variant=$(tui_menu "Stage3 Variant" "Select stage3 tarball variant:" "${STAGE3_VARIANTS[@]}") || variant="${STAGE3_VARIANTS[0]}"
    variant="${variant%% *}"
    state_set STAGE3_VARIANT "${variant}"
    case "${variant}" in
        systemd) state_set INIT "systemd" ;;
        *)       state_set INIT "openrc" ;;
    esac
}