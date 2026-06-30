#!/usr/bin/env bash
set -Eeuo pipefail

gforge_desktop_use_suggestions() {
    local wm_de="${WM_DE:-none}"
    local suggestions="${DESKTOP_USE_SUGGESTIONS[$wm_de]:-}"
    if [[ -n "${suggestions}" ]]; then
        tui_msg_quick "USE Suggestions" "Recommended USE flags for ${wm_de}: ${suggestions}"
        state_set DESKTOP_USE_FLAGS "${suggestions}"
        mkdir -p /mnt/etc/portage
        if [[ -f /mnt/etc/portage/make.conf ]] && grep -q "^USE=" /mnt/etc/portage/make.conf 2>/dev/null; then
            sed -i "s/^USE=\"/USE=\"${suggestions} /" /mnt/etc/portage/make.conf
        else
            echo "USE=\"${suggestions}\"" >> /mnt/etc/portage/make.conf
        fi
    fi
}

gforge_configure_desktop_extras() {
    local wm="${WM_DE:-none}"
    if [[ "${wm}" != "none" ]]; then
        if tui_yesno "Desktop Extras" "Configure additional desktop features?"; then
            local extras
            extras=$(tui_checklist "Desktop Extras" "Select:" \
                "Vulkan drivers" \
                "Printer support (cups)" \
                "Bluetooth" \
                "Power management (tlp)" \
                "SSD TRIM (fstrim)" \
                "NetworkManager applet" \
                "Fonts (noto/dejavu)" \
                "Input method (ibus/fcitx)") || true
            if [[ "${extras}" =~ "Vulkan" ]]; then state_set INSTALL_VULKAN "yes"; fi
            if [[ "${extras}" =~ "Printer" ]]; then state_set INSTALL_PRINTER "yes"; fi
            if [[ "${extras}" =~ "Bluetooth" ]]; then state_set INSTALL_BLUETOOTH "yes"; fi
            if [[ "${extras}" =~ "Power management" ]]; then state_set INSTALL_TLP "yes"; fi
            if [[ "${extras}" =~ "SSD TRIM" ]]; then state_set ENABLE_TRIM "yes"; fi
            if [[ "${extras}" =~ "NetworkManager applet" ]]; then state_set INSTALL_NM_APPLET "yes"; fi
            if [[ "${extras}" =~ "Fonts" ]]; then state_set INSTALL_FONTS "yes"; fi
            if [[ "${extras}" =~ "Input method" ]]; then
                local im
                im=$(tui_menu "Input Method" "Select:" "ibus" "fcitx") || im="ibus"
                state_set INPUT_METHOD "${im}"
            fi
        fi
    fi
}