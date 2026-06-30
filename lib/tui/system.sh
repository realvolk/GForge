#!/usr/bin/env bash
set -Eeuo pipefail

gforge_select_timezone() {
    local items tz
    items=$(find /usr/share/zoneinfo -type f 2>/dev/null | sed 's|/usr/share/zoneinfo/||' | grep -v '^posix\|^right\|^Etc\|\.tab$' | sort)
    tz=$(printf '%s\n' "${items}" | tui_filter "Timezone" "Type to search (e.g. Europe)..." --placeholder "Europe/London") || tz="UTC"
    state_set TIMEZONE "${tz:-UTC}"
}

gforge_select_locale() {
    local items l
    items=$(grep -E '^#?[a-z]{2}_[A-Z]{2}.*UTF-8' /etc/locale.gen 2>/dev/null | sed 's/^#//' | awk '{print $1}' | sort -u)
    l=$(printf '%s\n' "${items}" | tui_filter "Locale" "Type to search (e.g. en_US)..." --placeholder "en_US.UTF-8") || l="en_US.UTF-8"
    state_set LOCALE "${l:-en_US.UTF-8}"
}

gforge_select_keymap() {
    local items k
    items=$(localectl list-keymaps 2>/dev/null || find /usr/share/kbd/keymaps -name '*.map.gz' 2>/dev/null | sed 's|.*/||; s|\.map\.gz||' | sort -u)
    k=$(printf '%s\n' "${items}" | tui_filter "Keyboard Layout" "Type to search (e.g. us)..." --placeholder "us") || k="us"
    state_set KEYMAP "${k:-us}"
}

gforge_configure_hostname_dhcp() {
    if tui_yesno "Hostname from DHCP" "Use DHCP hostname?"; then
        local dhcp_host
        dhcp_host=$(hostname 2>/dev/null || echo "gentoo")
        state_set HOSTNAME "${dhcp_host}"
    else
        local h
        h=$(tui_input "Hostname" "Enter system hostname:" "gentoo") || h="gentoo"
        state_set HOSTNAME "${h}"
    fi
}

gforge_configure_extra_groups() {
    if tui_yesno "User Groups" "Add user to extra groups?"; then
        local groups
        groups=$(tui_checklist "Groups" "Select:" "plugdev" "cdrom" "scanner" "libvirt" "docker" "usb") || true
        state_set EXTRA_GROUPS "${groups//$'\n'/,}"
    fi
}