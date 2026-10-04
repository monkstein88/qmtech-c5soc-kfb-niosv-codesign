# QMTECH C5SOC KFB - Nios V codesign

This project is a Quartus Prime Standard 25.1 design for the QMTECH Cyclone V
SoC KFB with Dual SDRAM board, a close clone of the Terasic DE10-Nano.  It
combines an HPS system (`qsys/soc_system.qsys`) with an FPGA-side Nios V/g
control processor (`qsys/niosv_system.qsys`) that runs from tightly coupled
memory (TCM).  The Nios V firmware is built into the FPGA image, so the
processor starts as soon as the FPGA is configured, without the HPS, its boot
media or its DDR3 memory.

## Board

The details below were checked against the QMTECH schematic
(`QMTECH_Cyclone_V_SoC_KFB_Dual_SDRAM_Schematic_20240607_V01.pdf`) and the
QMTECH "How to Set Up" guide.

- **FPGA:** Cyclone V SoC 5CSEMA6U23 (the schematic footprint also accepts
  5CSEBA6U23 and 5CSXFC6C6U23).  The project targets `5CSEMA6U23I7`; QMTECH's
  reference photo shows a `5CSEMA6U23A7` part, so check the grade printed on
  your board.
- **HPS memory:** 2 x Micron MT41K256M16TW-107 DDR3L (1 GiB).
- **Configuration:** no configuration flash; the FPGA is configured over JTAG
  or by the HPS.  MSEL switch U18: ON drives the bit to 0.  QMTECH lists the
  board default as MSEL[4:0] = 10101; see
  `constraints/pinning_qmtech_c5soc_kfb_board.tcl` for this project's setting.
  The HPS boots from the SD card (BOOTSEL = 101).

| HDL port | FPGA pin | Board net / part | Notes |
| --- | --- | --- | --- |
| `FPGA_CLK1_50` | V11 | SYS_CLK3_50M, oscillator Y4 | Clock used by the design |
| `FPGA_CLK2_50` | Y13 | SYS_CLK2_50M, oscillator Y4 | Same oscillator as `FPGA_CLK1_50` |
| `FPGA_CLK3_50` | E11 | SYS_CLK1_50M, oscillator Y3 | |
| `LED` | W15 | LED0, LED D0 | Active-high |
| `KEY[0]` / `KEY[1]` | AH17 / AH16 | KEY0 (SW3) / KEY1 (SW2) | Active-low, 4.7k pull-up |
| `DIPSW[3:0]` | W20, W21, W24, Y24 | SW3..SW0 | |
| `HPS_LED` / `HPS_KEY` | HPS GPIO53 / GPIO54 | LED D9 / KEY2 | HPS-controlled |

Nets LED1..LED7 only reach expansion header J12 and are not used.  KEY5 is the
HPS warm-reset button.

## Architecture

```text
                         FPGA_CLK1_50 (50 MHz)
                                   |
                  +----------------+----------------+
                  |                                 |
                  |                      clk_pll (50 -> 100 MHz)
                  |                                 |
  +---------------v--------------+  +---------------v--------------+
  | soc_system (HPS)  50 MHz     |  | niosv_system      100 MHz    |
  | reset: HPS h2f_rst_n         |  | reset: FPGA POR and PLL lock |
  |                              |  |                              |
  | lightweight HPS-to-FPGA      |  | Nios V/g                     |
  | bridge:                      |  |   128 KiB instruction TCM    |
  |   sysid, JTAG UART, ILC      |  |   32 KiB data TCM            |
  |   led_pio    -> STM events   |  |   JTAG UART                  |
  |   dipsw_pio  <- DIPSW        |  |   pio_led    -> LED          |
  |   button_pio <- KEY          |  |   pio_dipsw  <- DIPSW        |
  |                              |  |   pio_button <- KEY          |
  +------------------------------+  +------------------------------+

  DIPSW = DIPSW[3:0] after a two-stage synchronizer
  KEY   = KEY[1:0] after a two-stage synchronizer and 1 ms debouncer (active-low)
```

The two processors are independent: they share the board clock, the
synchronized DIP switches and the debounced push-buttons, but there is no
communication path between them yet.

### Nios V/g system

`qsys/niosv_system.qsys` is the source of truth for the Nios V system: make
system changes in Platform Designer and commit the `.qsys`.  Its synthesis
output, and the `.sopcinfo` file that the Nios V BSP is built from, are
generated from it (see [Build](#build)).

| Address | Size | Component | Notes |
| ---: | ---: | --- | --- |
| `0x0000_0000` | 128 KiB | Instruction TCM1 | Reset vector; initialized from the firmware |
| `0x0002_0000` | 64 KiB | Debug module | JTAG debug and software download |
| `0x0003_8000` | 64 B | Timer / software interrupt | HAL system timer |
| `0x0003_8040` | 16 B | `pio_dipsw` | 4-bit input, synchronized DIP switches |
| `0x0003_8050` | 16 B | `pio_button` | 2-bit input, debounced `KEY`, active-low |
| `0x0003_8060` | 16 B | `pio_led` | 1-bit output, drives the user LED |
| `0x0003_8070` | 8 B | JTAG UART | IRQ 0; `stdin`/`stdout`/`stderr` |
| `0x2000_0000` | 32 KiB | Data TCM1 | Initialized from the firmware |

- The instruction and data managers are AXI4 interfaces.  Platform Designer
  inserts the AXI4-to-Avalon-MM translation for the Avalon-MM agents (debug
  module, timer, JTAG UART and PIOs) automatically; no explicit bridge is
  needed.
- The TCM subordinate ports (`instruction_tcs1`, `data_tcs1`) are connected
  back to the managers at the TCM base addresses.  This is what lets the
  debugger download software into the TCMs and what gives the BSP its memory
  regions.
- The instruction and data caches are disabled because all memory is tightly
  coupled.  If cached external memory is added later, re-enable the caches and
  place all peripherals in a Nios V peripheral region (`peripheralRegionABase`
  and `peripheralRegionASize`), which must remain uncached.
- Interrupts use the CLINT in vectored mode (`mtvec.MODE` = 01), with one
  shadow register file for interrupt handlers (`basicInterruptMode` and
  `basicShadowRegisterFiles` in the `.qsys`; the BSP's `system.h` reports
  `ALT_CPU_INT_MODE 1` and `ALT_CPU_NUM_SRF_BANKS 2`).  The Altera HAL still
  saves and restores every register on interrupt entry and exit, so the shadow
  register file does not shorten interrupt latency under the HAL.

### HPS system

`qsys/soc_system.qsys` is the reference HPS system (golden hardware reference
design) kept from the original board project.  It configures DDR3, the SD
card, UART0, USB1, EMAC1 (RGMII), I2C0, I2C1, SPIM1 and HPS GPIO35/53/54, which
matches the HPS pin usage in the QMTECH schematic.  Its FPGA peripherals are
reached through the lightweight HPS-to-FPGA bridge at `0xFF20_0000`:

| Offset | Component |
| ---: | --- |
| `0x0000_1000` | System ID |
| `0x0000_2000` | JTAG UART |
| `0x0000_3000` | `led_pio` |
| `0x0000_4000` | `dipsw_pio` |
| `0x0000_5000` | `button_pio` |
| `0x0003_0000` | Interrupt latency counter |

The DIP-switch, button and JTAG UART interrupts are connected to the HPS
FPGA-to-HPS interrupt lines 0, 1 and 2.

### Board I/O, clocks and resets

| Signal | Used by |
| --- | --- |
| `LED` | Nios V `pio_led`.  The HPS `led_pio` output only feeds the HPS STM hardware events. |
| `DIPSW[3:0]` | Two-stage synchronizer, then the HPS `dipsw_pio`, the Nios V `pio_dipsw` and the HPS STM events. |
| `KEY[1:0]` | Two-stage synchronizer and 1 ms debouncer, then the HPS `button_pio`, the Nios V `pio_button` and the HPS STM events.  Active-low. |

- `FPGA_CLK1_50` clocks the HPS system, the input synchronizers and the button
  debouncer directly, and feeds `clk_pll` inside the Nios V system, whose
  100 MHz output clocks the processor, its peripherals and its reset
  controller.
- The HPS system is reset by the HPS `h2f_rst_n` output, as in the reference
  design.
- The Nios V system and the button debouncer use an FPGA power-on reset that
  is released a few clock cycles after configuration, so HPS cold, warm or
  debug resets do not reset the Nios V.
- The PLL is reset by that power-on reset alone (`pll_rst_i`), while the rest
  of the Nios V system is held in reset until the PLL locks
  (`rst_n_i = fpga_reset_n & locked_o`).  The PLL reset must not be gated with
  the lock status, and must not come from the reset controller it clocks:
  either arrangement would hold the PLL in reset with no way to recover.
- The In-System Sources and Probes instance `RST` can request HPS cold, warm
  and debug resets over JTAG.

## Prerequisites

Quartus Prime Standard Edition 25.1 for Linux with Cyclone V device support,
and the Nios V tools installed with it: the Nios V Command Shell
(`niosv-shell`), the RiscFree IDE and toolchain, and CMake.  The Platform
Designer and Quartus command-line tools (`qsys-generate`, `quartus_sh`) must
be on `PATH`.

## Build

The design is built by hand in three steps: generate the Platform Designer
systems, build the Nios V software, then compile the Quartus project.  The
firmware has to be built before the Quartus compile, because Analysis &
Synthesis reads it into the TCMs.

### 1. Generate the Platform Designer systems

From the project root, generate the synthesis output of both systems (or open
each `.qsys` in Platform Designer and use **Generate HDL**):

```sh
cd qsys
qsys-generate soc_system.qsys --synthesis=VERILOG --output-directory=soc_system
qsys-generate niosv_system.qsys --synthesis=VERILOG --output-directory=niosv_system
```

This creates the `.qip` files that the QSF references (see
[QSYS versus QIP](#qsys-versus-qip)) and `qsys/niosv_system.sopcinfo`, which
the Nios V BSP is built from.

### 2. Build the Nios V software

The software is two RiscFree/CMake projects under `software/`:

| Directory | Contents |
| --- | --- |
| `software/hal_bsp/` | HAL board support package generated from `niosv_system.sopcinfo`: `settings.bsp`, the exported `settings.tcl`, `system.h`, `linker.x`, HAL and driver sources |
| `software/hal_app/` | Application: `src/main.c`, `inc/main.h` and the generated `CMakeLists.txt`; builds `blinky.elf` |

Run the commands below from the Nios V Command Shell, in `software/`:

```sh
/opt/altera/25.1std/niosv/bin/niosv-shell
cd software
```

Both projects are already in the repository.  To recreate them from scratch:

```sh
niosv-bsp --create --type=hal --sopcinfo=../qsys/niosv_system.sopcinfo --bsp-dir=hal_bsp hal_bsp/settings.bsp
niosv-bsp --query --export-as-tcl=hal_bsp/settings.tcl hal_bsp/settings.bsp
niosv-app --app-dir=hal_app --bsp-dir=hal_bsp --srcs=hal_app/src --srcs=hal_app/inc --incs=hal_app/inc --elf-name=blinky.elf
```

`niosv-app` writes `hal_app/CMakeLists.txt`.  After a change to the Nios V
system, regenerate `niosv_system.sopcinfo` (step 1), then update the BSP; this
keeps its existing settings:

```sh
niosv-bsp --update hal_bsp/settings.bsp
```

Build the firmware either in the RiscFree IDE (start it with `RiscFree` from
the same shell and build the `hal_bsp` and `hal_app` projects), or from the
command line:

```sh
cmake -G "Unix Makefiles" -S hal_app -B hal_app/build/Default
make -C hal_app/build/Default
```

Both put the results in `software/hal_app/build/Default/`:

| File | Purpose |
| --- | --- |
| `blinky.elf` | Firmware, for `niosv-download` and the debugger |
| `niosvitcm1.hex` | Instruction TCM1 contents |
| `niosvdtcm1.hex` | Data TCM1 contents |

`niosv_system.qsys` names those two `.hex` files as the TCM initialization
files, which is how the firmware gets into the FPGA image.  The build type
defaults to Debug (`-g`, no optimization), as in RiscFree; add
`-DCMAKE_BUILD_TYPE=Release` to the `cmake` line for `-O2`.

### 3. Compile the Quartus project

From the project root:

```sh
cd quartus
quartus_sh --flow compile qmtech_c5soc_kfb_niosv_codesign
```

The programming image is `quartus/output_files/qmtech_c5soc_kfb_niosv_codesign.sof`.
The generated Platform Designer output, the software build folders
(`software/hal_app/build/` and `software/hal_bsp/build/`, including the `.elf`
and `.hex` files) and the Quartus build products are not source-controlled.

### Update the firmware in an existing FPGA image

After changing only the firmware, rebuild it (from the Nios V Command Shell,
or in RiscFree) and refresh the memory contents without a full recompile.
From the project root:

```sh
make -C software/hal_app/build/Default
cd quartus
quartus_cdb qmtech_c5soc_kfb_niosv_codesign --update_mif
quartus_asm qmtech_c5soc_kfb_niosv_codesign
```

## Run and debug

The Cyclone V SoC JTAG chain contains the HPS (`SOCVHPS`) and the FPGA
(`5CSEMA6`); list it with `jtagconfig`.  Program the FPGA:

```sh
quartus_pgm -c 1 -m jtag -o "p;quartus/output_files/qmtech_c5soc_kfb_niosv_codesign.sof@2"
```

Note that `quartus_pgm` counts devices from 1 (the FPGA is `@2`), while
`niosv-download` counts from 0 (`--device=1 --instance=0` for the same FPGA).

The bring-up firmware (`software/hal_app/src/main.c`) then runs immediately:

- the user LED blinks at 1 Hz with all DIP switches off, and faster as the
  switch value increases (half period = 500 ms / (DIPSW + 1));
- holding `KEY[0]` forces the LED on, holding `KEY[1]` forces it off;
- switch and button changes are printed on the Nios V JTAG UART.

The JTAG UART console and the debugger need a probe that the Nios V tools
support: USB-Blaster II, Opella-XD, Opella-LD, HS2 or Vitra-XS.  A
USB-Blaster I (or a clone of one) configures the FPGA correctly, but the
Ashling GDB server refuses it and `juart-terminal` drops with I/O errors.

With a supported probe: the design contains two JTAG UARTs (HPS system and
Nios V system), so list the JTAG nodes with `jtagconfig -n` and connect to the
Nios V one by its instance number:

```sh
juart-terminal -c 1 -d 2 -i <instance>
```

To download and run a new firmware build over JTAG without reprogramming the
FPGA:

```sh
niosv-download -c 1 -d 1 -i 0 -r -g software/hal_app/build/Default/blinky.elf
```

## Verification status

The full flow (Platform Designer generation, firmware build, Quartus compile)
was run on Quartus Prime Standard 25.1 with the device set to
`5CSEMA6U23I7`.  The results below were recorded with the earlier scripted
flow, before the switch to vectored interrupts with a shadow register file and
to the manual build described above; re-run the compile to refresh them.  All
stages passed with 0 errors:

| Stage | Result |
| --- | --- |
| Analysis & Synthesis | Successful |
| Fitter | Successful |
| Assembler | Successful |
| Timing Analyzer | Successful |
| EDA Netlist Writer | Successful |

Resources: 6,893 / 41,910 ALMs (16%), 8,942 registers, 170 / 553 RAM blocks
(31%), 4 / 112 DSP blocks, 1 / 6 PLLs, 127 / 314 pins.

Timing is met on every clock in all corners.  Worst case setup slack at
Slow 1100 mV 85 C:

| Clock | Slack | Fmax |
| --- | ---: | ---: |
| Nios V `clk_pll` output (100 MHz) | +0.265 ns | 102.7 MHz |
| HPS DDR3 `afi_clk` | +1.577 ns | |
| `FPGA_CLK1_50` (50 MHz) | +7.652 ns | 81.0 MHz |
| `altera_reserved_tck` | +9.566 ns | |

Hold, recovery, removal and minimum pulse width all pass, and the timing
analyzer reports no unconstrained or illegal clocks.  The unconstrained I/O
ports it lists are the HPS dedicated pins, whose timing belongs to the HPS
hard IP.

Also checked:

- The BSP and firmware build against the generated system and supply the
  `niosvitcm1.hex`/`niosvdtcm1.hex` TCM contents, so the processor starts
  from the FPGA image.  Their absence shows up as Critical Warning 127003
  and leaves both memories zero-filled.
- `constraints/pinning_qmtech_c5soc_kfb_board.tcl` re-applies to the project
  without changing any assignment.
- Pin numbers, I/O polarities and oscillators against the QMTECH schematic.

On the board:

- The `.sof` programs over a USB-Blaster, and the Nios V runs the firmware
  built into the image: the user LED blinks at the rate the bring-up firmware
  sets, without any download step.
- The Nios V debug module answers on JTAG (`dmstatus` reads back non-zero).

Not yet verified:

- Refreshing the firmware with `quartus_cdb --update_mif`.
- The JTAG UART console and `niosv-download`.  Both need a debug probe that
  Altera's Nios V tools support - USB-Blaster II, Opella-XD, Opella-LD, HS2 or
  Vitra-XS.  A USB-Blaster I (or clone) configures the FPGA fine, but the
  Ashling GDB server rejects it and `juart-terminal` drops with I/O errors.

## Quartus 25.1 notes

### QSYS versus QIP

Quartus Prime Standard Edition 25.1 changed how Nios V generated RTL must be
added to a Quartus project. The `.qsys` file remains the Platform Designer
system description, but the Quartus project must reference the generated
`.qip` file. Referencing the `.qsys` file directly can make Analysis &
Synthesis parse generated Nios files with the wrong compiler path and produce
errors such as:

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

### Clock export

The Nios V system uses `altera_clock_bridge` rather than
`altera_avalon_clock_source`: the board clock is exported into the Platform
Designer system, and the bridge output feeds the reference clock of
`clk_pll`, whose 100 MHz output clocks the processor, the reset controller,
the JTAG UART and the PIOs.  An exported clock-source output driven again from
`FPGA_CLK1_50` in the board wrapper causes a multiple-driver error.

### Constraints

- `constraints/timing_qmtech_c5soc_kfb_board.sdc` is the project SDC file.
- `constraints/pinning_qmtech_c5soc_kfb_board.tcl` is the board pin reference.
  The assignments are stored in the QSF; after editing the script, re-apply it
  with `quartus_sh -t constraints/pinning_qmtech_c5soc_kfb_board.tcl`.  The HPS
  DDR3 pin assignments belong to the HPS SDRAM IP and are applied by the
  generated `hps_sdram_p0_pin_assignments.tcl`.

## Future work

- A communication path between the HPS and the Nios V (for example a mailbox
  or shared on-chip memory on both the lightweight bridge and the Nios V data
  manager).
- External memory for larger Nios V applications, with the caches and a
  peripheral region enabled as described above.

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
