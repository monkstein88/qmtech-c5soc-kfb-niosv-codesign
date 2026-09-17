#!/usr/bin/env bash
# Generate the Platform Designer systems used by the Quartus project.
#
# Usage: scripts/generate_platform_designs.sh [--skip-niosv-script]
#
# qsys/niosv_system.qsys is re-created from qsys/create_niosv_system.tcl first,
# so the Tcl script stays the source of truth for the Nios V system.  Pass
# --skip-niosv-script to generate the existing niosv_system.qsys unchanged, e.g.
# while trying out an edit made in the Platform Designer GUI (port such edits
# back into the Tcl script, or they are lost on the next regular run).
set -euo pipefail

usage() {
    sed -n '2,10s/^# \{0,1\}//p' "${BASH_SOURCE[0]}"
}

run_niosv_script=1
for arg in "$@"; do
    case "$arg" in
        --skip-niosv-script) run_niosv_script=0 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "error: unknown argument: $arg" >&2; usage >&2; exit 1 ;;
    esac
done

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(dirname "$script_dir")"
qsys_dir="$project_root/qsys"

source "$script_dir/quartus_env.sh"
require_tools qsys-script qsys-generate

cd "$qsys_dir"

if (( run_niosv_script )); then
    echo "Creating niosv_system.qsys from create_niosv_system.tcl"
    qsys-script --script=create_niosv_system.tcl
fi

for system in soc_system niosv_system; do
    echo "Generating $system"
    qsys-generate "$system.qsys" --synthesis=VERILOG --output-directory="$system"
done

echo
echo "Next: scripts/build_firmware.sh, then compile quartus/qmtech_c5soc_kfb_niosv_codesign.qpf"
