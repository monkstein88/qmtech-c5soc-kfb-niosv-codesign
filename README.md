# QMTECH C5SOC KFB - Nios V codesign

This project is a Quartus Prime Standard 25.1 starting point for the QMTECH
Cyclone V SoC board with an FPGA-side Nios V/g control processor.  It keeps the
reference HPS design (`qsys/soc_system.qsys`) and adds a small, independently
generated Nios V system with tightly coupled memory, JTAG UART, and PIO for the board
LED, DIP switches, and push buttons.

## Generate and compile

1. Open `quartus/qmtech_c5soc_kfb_dual_sdram_ghrd.qpf` in Quartus Prime
   Standard 25.1.
2. From the project root, in a Quartus Prime shell, run:

   ```sh
   ./scripts/generate_platform_designs.sh
   ```

3. Run Analysis & Synthesis, then compile the project.

All HDL, Qsys sources, IP sources, constraints, and generation scripts needed
by this project are stored under this directory. The `qsys/soc_system` and
`qsys/niosv_system` directories are generated locally by the script and are
intentionally not source-controlled build outputs.

The Nios V memory map is:

| Address | Peripheral |
| ---: | --- |
| `0x00000000` | 128 KiB instruction TCM |
| `0x20000000` | 32 KiB data TCM |
| `0x00008000` | JTAG UART |
| `0x00008100` | LED PIO |
| `0x00008120` | DIP-switch PIO |
| `0x00008140` | push-button PIO |

The generated Nios V system deliberately does not depend on HPS DDR3.  This
allows FPGA-only firmware bring-up first; the TCM sizes can later be reduced
when external memory is added for larger applications.
