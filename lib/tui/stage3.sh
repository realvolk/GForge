#!/usr/bin/env bash
set -Eeuo pipefail

gforge_select_stage3() {
    local -a variants=()
    local i
    for ((i=0; i<${#STAGE3_VARIANTS[@]}; i+=2)); do
        variants+=("${STAGE3_VARIANTS[$i]}")
    done
    local variant
    variant=$(tui_menu "Stage3 Variant" "Select stage3 tarball variant:" "${variants[@]}") || variant="${variants[0]}"
    state_set STAGE3_VARIANT "${variant}"
    case "${variant}" in
        systemd|desktop-systemd) state_set INIT "systemd" ;;
        *)                       state_set INIT "openrc" ;;
    esac
}