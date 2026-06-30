#!/usr/bin/env bash
set -Eeuo pipefail

gforge_configure_cflags() {
    local cpu_march cpu_cores suggested_cflags suggested_makeopts
    cpu_march=$(gforge_detect_march)
    cpu_cores=$(nproc)
    suggested_cflags="${cpu_march} -O2 -pipe"
    suggested_makeopts="-j${cpu_cores}"
    local cflags makeopts
    cflags=$(tui_input "CFLAGS" "Compiler flags for your CPU.\n\nDetected: $(detect_cpu)\nSuggested: ${suggested_cflags}" "${suggested_cflags}")
    state_set GENTOO_CFLAGS "${cflags:-${suggested_cflags}}"
    makeopts=$(tui_input "MAKEOPTS" "Parallel compilation jobs.\n\nDetected cores: ${cpu_cores}\nSuggested: ${suggested_makeopts}" "${suggested_makeopts}")
    state_set GENTOO_MAKEOPTS "${makeopts:-${suggested_makeopts}}"
    if tui_yesno "CPU_FLAGS_X86" "Auto-detect CPU instruction sets using cpuid2cpuflags?"; then
        if pkg_install app-portage/cpuid2cpuflags 2>/dev/null; then
            local cpu_flags
            cpu_flags=$(pkg_chroot cpuid2cpuflags 2>/dev/null || true)
            if [[ -n "${cpu_flags}" ]]; then
                echo "*/* $(cpuid2cpuflags)" > /mnt/etc/portage/package.use/00cpu-flags
                tui_msg_quick "CPU Flags" "Written to /etc/portage/package.use/00cpu-flags"
            fi
        fi
    fi
}