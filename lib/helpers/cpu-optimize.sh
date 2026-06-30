#!/usr/bin/env bash
set -Eeuo pipefail

gforge_detect_march() {
    if command -v resolve-march-native &>/dev/null; then
        local march
        march=$(resolve-march-native 2>/dev/null | head -n1 || true)
        if [[ -n "${march}" ]]; then
            echo "${march}"
            return 0
        fi
    fi

    local cpu_vendor
    cpu_vendor=$(detect_cpu)
    case "${cpu_vendor}" in
        INTEL)
            if grep -q 'avx512' /proc/cpuinfo 2>/dev/null; then
                echo "-march=x86-64-v4"
            elif grep -q 'avx2' /proc/cpuinfo 2>/dev/null; then
                echo "-march=x86-64-v3"
            elif grep -q 'sse4_2' /proc/cpuinfo 2>/dev/null; then
                echo "-march=x86-64-v2"
            else
                echo "-march=native"
            fi
            ;;
        AMD)
            if grep -q 'avx512' /proc/cpuinfo 2>/dev/null; then
                echo "-march=znver4"
            elif grep -q 'avx2' /proc/cpuinfo 2>/dev/null; then
                echo "-march=znver3"
            elif grep -q 'sse4a' /proc/cpuinfo 2>/dev/null; then
                echo "-march=znver2"
            else
                echo "-march=native"
            fi
            ;;
        *)
            echo "-march=native"
            ;;
    esac
}

gforge_detect_optimal_jobs() {
    local cpu_threads ram_gb ram_jobs
    cpu_threads=$(nproc)
    ram_gb=$(awk '/MemTotal/ {printf "%d", $2 / 1024 / 1024}' /proc/meminfo)
    ram_jobs=$(( ram_gb / 2 ))
    [[ ${ram_jobs} -lt 1 ]] && ram_jobs=1
    if [[ ${ram_jobs} -lt ${cpu_threads} ]]; then
        echo "${ram_jobs}"
    else
        echo "${cpu_threads}"
    fi
}

gforge_detect_ram_gb() {
    awk '/MemTotal/ {printf "%.1f", $2 / 1024 / 1024}' /proc/meminfo
}

gforge_hardware_summary() {
    local cpu ram gpu
    cpu=$(detect_cpu)
    ram=$(gforge_detect_ram_gb)
    gpu=$(get_gpu_vendor)
    printf "CPU: %s | Threads: %s | RAM: %s GB | GPU: %s" "${cpu}" "$(nproc)" "${ram}" "${gpu}"
}