#!/usr/bin/env bash
set -Eeuo pipefail

gforge_configure_cflags() {
    tui_msg_quick "Hardware Detection" "$(gforge_hardware_summary)"

    local cpu_march optimal_jobs suggested_cflags suggested_makeopts
    cpu_march=$(gforge_detect_march)
    optimal_jobs=$(gforge_detect_optimal_jobs)
    suggested_cflags="${cpu_march} -O2 -pipe"
    suggested_makeopts="-j${optimal_jobs}"

    local cflags makeopts
    cflags=$(tui_input "CFLAGS" "Compiler flags for your CPU.\n\nDetected: $(detect_cpu)\nRAM: $(gforge_detect_ram_gb) GB\nSuggested: ${suggested_cflags}" "${suggested_cflags}")
    state_set GENTOO_CFLAGS "${cflags:-${suggested_cflags}}"

    makeopts=$(tui_input "MAKEOPTS" "Parallel compilation jobs.\n\nDetected threads: $(nproc)\nRAM: $(gforge_detect_ram_gb) GB (recommend 2GB per job)\nSuggested: ${suggested_makeopts}" "${suggested_makeopts}")
    state_set GENTOO_MAKEOPTS "${makeopts:-${suggested_makeopts}}"

    mkdir -p /mnt/etc/portage
    if [[ -f /mnt/etc/portage/make.conf ]]; then
        if grep -q "^CFLAGS=" /mnt/etc/portage/make.conf 2>/dev/null; then
            sed -i "s/^CFLAGS=.*/CFLAGS=\"${cflags:-${suggested_cflags}}\"/" /mnt/etc/portage/make.conf
        else
            echo "CFLAGS=\"${cflags:-${suggested_cflags}}\"" >> /mnt/etc/portage/make.conf
        fi
        if grep -q "^CXXFLAGS=" /mnt/etc/portage/make.conf 2>/dev/null; then
            sed -i "s/^CXXFLAGS=.*/CXXFLAGS=\"${cflags:-${suggested_cflags}}\"/" /mnt/etc/portage/make.conf
        else
            echo "CXXFLAGS=\"${cflags:-${suggested_cflags}}\"" >> /mnt/etc/portage/make.conf
        fi
        if grep -q "^MAKEOPTS=" /mnt/etc/portage/make.conf 2>/dev/null; then
            sed -i "s/^MAKEOPTS=.*/MAKEOPTS=\"${makeopts:-${suggested_makeopts}}\"/" /mnt/etc/portage/make.conf
        else
            echo "MAKEOPTS=\"${makeopts:-${suggested_makeopts}}\"" >> /mnt/etc/portage/make.conf
        fi
    else
        cat > /mnt/etc/portage/make.conf <<MAKECONF
CFLAGS="${cflags:-${suggested_cflags}}"
CXXFLAGS="${cflags:-${suggested_cflags}}"
MAKEOPTS="${makeopts:-${suggested_makeopts}}"
MAKECONF
    fi

    if tui_yesno "CPU_FLAGS_X86" "Auto-detect CPU instruction sets using cpuid2cpuflags?"; then
        if pkg_install app-portage/cpuid2cpuflags 2>/dev/null; then
            local cpu_flags
            cpu_flags=$(pkg_chroot cpuid2cpuflags 2>/dev/null || true)
            if [[ -n "${cpu_flags}" ]]; then
                mkdir -p /mnt/etc/portage/package.use
                echo "*/* $(cpuid2cpuflags)" > /mnt/etc/portage/package.use/00cpu-flags
                tui_msg_quick "CPU Flags" "Written to /etc/portage/package.use/00cpu-flags"
            fi
        fi
    fi
}

gforge_configure_rustflags() {
    if tui_yesno "RUSTFLAGS" "Configure Rust compiler flags?\n\nSets -C target-cpu=native for CPU optimization."; then
        local suggested_rustflags="-C target-cpu=native"
        state_set GENTOO_RUSTFLAGS "${suggested_rustflags}"
        mkdir -p /mnt/etc/portage
        if [[ -f /mnt/etc/portage/make.conf ]]; then
            if grep -q "^RUSTFLAGS=" /mnt/etc/portage/make.conf 2>/dev/null; then
                sed -i "s/^RUSTFLAGS=.*/RUSTFLAGS=\"${suggested_rustflags}\"/" /mnt/etc/portage/make.conf
            else
                echo "RUSTFLAGS=\"${suggested_rustflags}\"" >> /mnt/etc/portage/make.conf
            fi
        else
            echo "RUSTFLAGS=\"${suggested_rustflags}\"" >> /mnt/etc/portage/make.conf
        fi
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