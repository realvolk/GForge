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

gforge_configure_rustflags() {
    if tui_yesno "RUSTFLAGS" "Configure Rust compiler flags for CPU optimization?"; then
        local suggested_rustflags="-C target-cpu=native"
        local rustflags
        rustflags=$(tui_input "RUSTFLAGS" "Rust compiler flags.\n\nSuggested: ${suggested_rustflags}\n\nTo see supported CPUs: rustc -C target-cpu=help" "${suggested_rustflags}")
        state_set GENTOO_RUSTFLAGS "${rustflags:-${suggested_rustflags}}"
    fi
}

gforge_configure_per_package_cflags() {
    if tui_yesno "Per-Package CFLAGS" "Set custom compiler flags for specific packages?\n\nRecommended for GCC 16+ and specific CPU-optimized packages."; then
        tui_msg_quick "Per-Package CFLAGS" "You can set package-specific CFLAGS in /etc/portage/env/ and reference them via /etc/portage/package.env"
        if tui_yesno "Edit now" "Open the Chisel editor to configure?"; then
            mkdir -p /mnt/etc/portage/env
            tui_edit "Package env" "/mnt/etc/portage/env/custom-cflags"
        fi
    fi
}