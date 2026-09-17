# Locate the Quartus Prime installation and put its Platform Designer, Nios V
# and RiscFree tools on PATH.  Sourced by the other scripts in this directory.
#
# QUARTUS_ROOTDIR is used when it is set (as it is in a Quartus Prime or Nios V
# command shell).  Otherwise it is derived from the quartus_sh or qsys-script
# executable found on PATH, so every tool comes from the same installation.

if [[ -z "${QUARTUS_ROOTDIR:-}" ]]; then
    if tool_path="$(command -v quartus_sh)"; then
        # <root>/quartus/bin/quartus_sh
        QUARTUS_ROOTDIR="$(dirname "$(dirname "$(readlink -f "$tool_path")")")"
    elif tool_path="$(command -v qsys-script)"; then
        # <root>/quartus/sopc_builder/bin/qsys-script
        QUARTUS_ROOTDIR="$(dirname "$(dirname "$(dirname "$(readlink -f "$tool_path")")")")"
    fi
fi

if [[ -z "${QUARTUS_ROOTDIR:-}" || ! -d "$QUARTUS_ROOTDIR" ]]; then
    echo "error: Quartus Prime not found; run from a Quartus Prime shell or set QUARTUS_ROOTDIR" >&2
    exit 1
fi

QUARTUS_ROOTDIR="$(cd "$QUARTUS_ROOTDIR" && pwd)"
export QUARTUS_ROOTDIR

altera_root="$(dirname "$QUARTUS_ROOTDIR")"
for tool_dir in \
    riscfree/toolchain/riscv32-unknown-elf/bin \
    riscfree/build_tools/cmake/bin \
    niosv/bin \
    quartus/sopc_builder/bin \
    quartus/bin; do
    if [[ -d "$altera_root/$tool_dir" ]]; then
        PATH="$altera_root/$tool_dir:$PATH"
    fi
done
export PATH

require_tools() {
    local tool
    for tool in "$@"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            echo "error: $tool is not available in $altera_root" >&2
            exit 1
        fi
    done
}
