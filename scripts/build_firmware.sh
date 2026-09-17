#!/usr/bin/env bash
# Build the Nios V firmware and the TCM initialization files.
#
# Usage: scripts/build_firmware.sh
#
# Requires qsys/niosv_system.sopcinfo, created by
# scripts/generate_platform_designs.sh.  Everything is built under
# software/build/ (not source-controlled):
#
#   software/build/bsp/                        HAL board support package
#   software/build/app/                        generated CMake project
#   software/build/firmware/niosv_app.elf      firmware for niosv-download
#   software/build/firmware/niosvitcm1.hex     instruction TCM1 contents
#   software/build/firmware/niosvdtcm1.hex     data TCM1 contents
#
# The .hex paths are referenced by qsys/create_niosv_system.tcl, so Quartus
# Analysis & Synthesis builds the firmware into the FPGA image.
set -euo pipefail

usage() {
    sed -n '2,17s/^# \{0,1\}//p' "${BASH_SOURCE[0]}"
}

case "${1:-}" in
    "") ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown argument: $1" >&2; usage >&2; exit 1 ;;
esac

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(dirname "$script_dir")"
sopcinfo="$project_root/qsys/niosv_system.sopcinfo"
build_dir="$project_root/software/build"

source "$script_dir/quartus_env.sh"
require_tools niosv-bsp niosv-app cmake make riscv32-unknown-elf-gcc

if [[ ! -f "$sopcinfo" ]]; then
    echo "error: $sopcinfo not found; run scripts/generate_platform_designs.sh first" >&2
    exit 1
fi

# The BSP carries no local customizations, so re-create it from the current
# .sopcinfo every time; it can then never be stale against the hardware.
rm -rf "$build_dir/bsp" "$build_dir/app" "$build_dir/firmware"
mkdir -p "$build_dir"
cd "$build_dir"

niosv-bsp --create --sopcinfo="$sopcinfo" --type=hal bsp/settings.bsp
niosv-app --app-dir=app --bsp-dir=bsp --srcs=../app/main.c --elf-name=niosv_app.elf
cmake -S app -B firmware -G "Unix Makefiles"
make -C firmware -j"$(nproc)"

echo
echo "Firmware: $build_dir/firmware/niosv_app.elf"
echo "Next: compile quartus/qmtech_c5soc_kfb_niosv_codesign.qpf (or update the"
echo "memory contents of an existing compile, see README.md)"
