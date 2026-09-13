# QMTECH C5SOC KFB - Nios V codesign

This project is a Quartus Prime Standard 25.1 starting point for the QMTECH
Cyclone V SoC board with an FPGA-side Nios V/g control processor.  It keeps the
reference HPS design (`qsys/soc_system.qsys`) and adds a small, independently
generated Nios V system with tightly coupled memory plus board-facing PIO and JTAG UART
instances.

## Generate and compile

1. Open `quartus/qmtech_c5soc_kfb_niosv_codesign.qpf` in Quartus Prime
   Standard 25.1.
2. From the project root, in a Quartus Prime shell, run:

   ```sh
   ./scripts/generate_platform_designs.sh
   ```

3. Run Analysis & Synthesis, then compile the project.

The Quartus project references the generated Platform Designer `.qip` files,
not the `.qsys` files directly. This is required by Quartus Prime Standard
25.1 for Nios V designs; adding the QSYS files directly can cause generated
Nios RTL parser errors during Analysis & Synthesis.

All HDL, Qsys sources, IP sources, constraints, and generation scripts needed
by this project are stored under this directory. The `qsys/soc_system` and
`qsys/niosv_system` directories are generated locally by the script and are
intentionally not source-controlled build outputs.

The Nios V tightly coupled memory map is:

| Address | Peripheral |
| ---: | --- |
| `0x00000000` | 128 KiB instruction TCM |
| `0x20000000` | 32 KiB data TCM |
The generated Nios V system deliberately does not depend on HPS DDR3.  This
allows FPGA-only firmware bring-up first; the TCM sizes can later be reduced
when external memory is added for larger applications.

The current Quartus 25.1 Nios V/g component exposes AXI instruction/data
masters, while the retained JTAG UART and PIO instances use Avalon-MM slave
interfaces. No AXI-to-Avalon bridge is included yet, so these peripherals are
not CPU-addressable; Quartus reports this as an unconnected-interface warning.
Their exported conduits are wired to the board wrapper so the interface shape
is stable for a future bridge integration.

## Quartus 25.1 build findings

### QSYS versus QIP

Quartus Prime Standard Edition 25.1 changed how Nios V generated RTL must be
added to a Quartus project. The `.qsys` file remains the editable Platform
Designer source, but the Quartus project must reference the generated `.qip`
file. Referencing the `.qsys` file directly can make Analysis & Synthesis parse
generated Nios files with the wrong compiler path and produce errors such as:

```text
Error (10835): no support for unions
Error (10355): encoded value for element "MXL32" has width 32
Error (12152): Can't elaborate user hierarchy
```

This project therefore keeps the `.qsys` files under version control, generates
their synthesis output locally, and uses these QIP assignments in the QSF:

```tcl
set_global_assignment -name QIP_FILE ../qsys/soc_system/synthesis/soc_system.qip
set_global_assignment -name QIP_FILE ../qsys/niosv_system/synthesis/niosv_system.qip
```

This is an Altera-documented Quartus 25.1 workaround, not a manual edit to the
generated or encrypted Nios RTL.

### Clock export correction

The Nios system originally used `altera_avalon_clock_source` and exported its
generated clock while the board wrapper also drove that same signal from
`FPGA_CLK1_50`. Quartus correctly reported a multiple-driver error. The
generator now uses `altera_clock_bridge`: the board clock is exported into the
Platform Designer system and the bridge output drives the internal Nios,
reset-controller, UART, and PIO clock sinks.

### Full compile result

Using `/opt/altera/25.1std`, the complete Quartus flow was run for
`qmtech_c5soc_kfb_niosv_codesign` after applying the QIP and clock corrections.
The following stages completed successfully:

| Stage | Result |
| --- | --- |
| Analysis & Synthesis | Successful |
| Fitter | Successful |
| Assembler | Successful |
| Timing Analyzer | Successful |
| EDA Netlist Writer | Successful |

The resulting programming image is:

```text
quartus/output_files/qmtech_c5soc_kfb_niosv_codesign.sof
```

The generated Quartus database, reports, handoff files, `.sof`, and other
build products are intentionally ignored by Git. The editable `.qsys` sources
remain preserved.

### Remaining Platform Designer warnings

The successful FPGA compile does not yet mean that Nios firmware can access
the UART and PIO peripherals. Nios V/g exposes AXI4 instruction/data manager
interfaces, while the retained `altera_avalon_jtag_uart` and
`altera_avalon_pio` components expose Avalon-MM slaves. The current system has
no compatible AXI-to-Avalon-MM interconnect, so Platform Designer reports:

- no peripheral regions configured for the CPU;
- JTAG UART, LED PIO, DIP-switch PIO, and push-button PIO not connected to an
  Avalon-MM master;
- the JTAG UART interrupt not connected;
- CPU timer/software-agent and debug-module Avalon interfaces unconnected.

The board-level conduits are still exported and wired in the top-level HDL.
This preserves the physical I/O interface while leaving the next software
integration step explicit. A future CPU-addressable design must either add a
supported AXI-to-Avalon path and configure the Nios peripheral regions, or use
a processor configuration that exposes compatible Avalon masters directly.

## References

The following Altera references document the Quartus 25.1 behavior and Nios V
integration model used here:

1. [Why does Nios V processor design fail to compile when the QSYS file is added instead of the QIP file?](https://community.altera.com/kb/knowledge-base/why-does-nios%C2%AE-v-processor-design-fail-to-compile-during-analysis--synthesis-whe/349129)
   - Altera Knowledge Base article 349129.
   - Specifically documents the `riscv.pkg.sv` union and enumeration errors
     and recommends removing the QSYS assignment and adding the QIP.
2. [Error building simple Nios V Compact project](https://community.altera.com/discussions/nios-system/error-building-simple-niosv-compact-project/337631)
   - Altera Community discussion 337631.
   - The accepted Altera response states that Quartus 25.1 Standard supports
     QIP-only project integration for Nios V generated output.
3. [Nios V Processor User Guide](https://docs.altera.com/r/docs/683632/25.1/nios-v-processor-user-guide)
   - Official processor architecture, memory, debug, and software guidance.
4. [Nios V Processor IP Core User Guide](https://docs.altera.com/r/docs/683632/25.1/nios-v-processor-ip-core-user-guide)
   - Official Platform Designer IP configuration and interface guidance.
5. [Nios V/g MAX 10 iPerf example](https://raw.githubusercontent.com/altera-fpga/max10-ed-nios/rel/25.1std/max10-10m50-evaluation-dev-kit/niosv_g/max10_iperf/docs/niosv_g_processor_iperf_design_on_max10_FPGA.md)
   - Official Altera example using Nios V/g with Quartus Prime Standard 25.1.
6. [Nios V/g MAX 10 Simple Socket Server example](https://raw.githubusercontent.com/altera-fpga/max10-ed-nios/rel/25.1std/max10-10m50-evaluation-dev-kit/niosv_g/max10_sss/docs/niosv_g_processor_sss_design_on_max10_FPGA.md)
   - Additional official Quartus 25.1 Standard Nios V/g reference design.

The examples above establish that Nios V/g is used with Quartus Standard in
some supported configurations, but they do not by themselves guarantee support
for every Cyclone V and Nios V/g configuration. This project therefore records
the exact local Quartus version, generated QIP workflow, and successful build
artifacts rather than relying on an unverified compatibility assumption.
