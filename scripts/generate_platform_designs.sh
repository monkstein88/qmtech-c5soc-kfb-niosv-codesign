#!/usr/bin/env bash
# Generate the Platform Designer systems used by the Quartus project.
#
# Usage: scripts/generate_platform_designs.sh [--rebuild-niosv-from-tcl]
#
# qsys/niosv_system.qsys is the source of truth and is edited in Platform
# Designer; this script only generates its synthesis output as-is.
# create_niosv_system.tcl is a hand-maintained mirror of that .qsys.  Pass
# --rebuild-niosv-from-tcl to instead re-create niosv_system.qsys FROM the Tcl
# (this overwrites the .qsys; use only to bootstrap or intentionally reset it).
set -euo pipefail

usage() {
    sed -n '2,10s/^# \{0,1\}//p' "${BASH_SOURCE[0]}"
}

run_niosv_script=0
for arg in "$@"; do
    case "$arg" in
        --rebuild-niosv-from-tcl) run_niosv_script=1 ;;
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
    echo "WARNING: rebuilding niosv_system.qsys FROM create_niosv_system.tcl (overwrites the source-of-truth .qsys)"
    qsys-script --script=create_niosv_system.tcl
fi

for system in soc_system niosv_system; do
    echo "Generating $system"
    qsys-generate "$system.qsys" --synthesis=VERILOG --output-directory="$system"
done

echo
echo "Next: scripts/build_firmware.sh, then compile quartus/qmtech_c5soc_kfb_niosv_codesign.qpf"
