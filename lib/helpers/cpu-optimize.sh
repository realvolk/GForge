#!/usr/bin/env bash
set -Eeuo pipefail

gforge_detect_march() {
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
        *) echo "-march=native" ;;
    esac
}