#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
qsys_dir="$project_root/qsys"

command -v qsys-script >/dev/null 2>&1 || {
    echo "error: qsys-script is not available; run this from a Quartus Prime shell" >&2
    exit 1
}
command -v qsys-generate >/dev/null 2>&1 || {
    echo "error: qsys-generate is not available; run this from a Quartus Prime shell" >&2
    exit 1
}

cd "$qsys_dir"
export QUARTUS_ROOTDIR=/opt/altera/25.1std/quartus
qsys-script --search-path="/opt/altera/25.1std/ip/altera/soft_processor/intel_niosv_g,/opt/altera/25.1std/ip/altera/merlin,$,/opt/altera/25.1std/ip/altera" \
    --script=create_niosv_system.tcl
qsys-generate soc_system.qsys --synthesis --output-directory=soc_system \
    --search-path="/opt/altera/25.1std/ip/altera/soft_processor/intel_niosv_g,/opt/altera/25.1std/ip/altera/merlin,$,/opt/altera/25.1std/ip/altera"
qsys-generate niosv_system.qsys --synthesis --output-directory=niosv_system \
    --search-path="/opt/altera/25.1std/ip/altera/soft_processor/intel_niosv_g,/opt/altera/25.1std/ip/altera/merlin,$,/opt/altera/25.1std/ip/altera"
