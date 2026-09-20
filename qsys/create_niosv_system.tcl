# Platform Designer generator for the FPGA-side Nios V control system.
#
# This script is the source of truth for qsys/niosv_system.qsys.  The .qsys
# file is regenerated from it by scripts/generate_platform_designs.sh, so make
# system changes here rather than in the Platform Designer GUI.
#
# Run from qsys/ with:
#   qsys-script --script=create_niosv_system.tcl
#   qsys-generate niosv_system.qsys --synthesis=VERILOG --output-directory=niosv_system
#
# Nios V/g address map (identical from the instruction and data managers where
# both are connected):
#
#   0x0000_0000  128 KiB  instruction TCM1 (reset vector)
#   0x0002_0000   64 KiB  debug module (dm_agent)
#   0x0003_8000           machine timer / software interrupt (timer_sw_agent)
#   0x0003_8040           DIP-switch PIO (4 bits, input)
#   0x0003_8050           button PIO     (2 bits, input, active-low, debounced)
#   0x0003_8060           LED PIO        (1 bit, output)
#   0x0003_8070           JTAG UART (IRQ 0)
#   0x2000_0000   32 KiB  data TCM1
#
# The TCMs are accessed by the core directly.  Their AXI4-Lite subordinate
# ports (instruction_tcs1/data_tcs1) are looped back onto the managers at the
# same base address as the TCM itself, which is the Nios V/g arrangement that
# lets the debugger download software into the TCMs and gives the BSP its
# memory regions.  Keep those base addresses equal to itcm1Base/dtcm1Base.
#
# Platform Designer inserts the AXI4 to Avalon-MM translation for the
# Avalon-MM agents (debug module, timer, JTAG UART, PIOs) automatically.
#
# The processor caches are disabled: every memory is tightly coupled, so a
# cache would only consume M10K blocks.  If cached external memory is added
# later, re-enable the caches and place all peripherals inside a Nios V
# peripheral region (peripheralRegionABase/Size), which must stay uncached.
#
# Clocking and reset:
#
#   clk_i ---> clk (bridge) ---> clk_pll.refclk ---> outclk0 ---> cpu, jtag_uart,
#                                                                pio_*, rst.clk
#   pll_rst_i --------------> clk_pll.reset    (board reset only)
#   rst_n_i ----------------> rst.reset_in0    (board reset AND clk_pll locked)
#   rst.reset_out ----------> cpu, jtag_uart, pio_* resets
#
# The reset controller runs on the PLL output so that reset de-assertion is
# synchronized to the domain it resets.  The PLL reset therefore must NOT come
# from rst.reset_out: that would stop the clock the reset controller needs to
# release its own reset.  For the same reason the exported locked conduit is
# combined with the board reset in the board top level and fed back in through
# rst_n_i, never into pll_rst_i.

package require -exact qsys 25.1

# Firmware image used to initialize the TCMs.  The paths are relative to the
# Quartus project directory (quartus/), where Analysis & Synthesis resolves
# them.  They are produced by scripts/build_firmware.sh.
set itcm_init_file ../software/build/firmware/niosvitcm1.hex
set dtcm_init_file ../software/build/firmware/niosvdtcm1.hex

set itcm_base 0x00000000
set dtcm_base 0x20000000

# Board clock and Nios V system clock, in MHz.  100 MHz is close to what the
# Nios V/g core closes at on this device: across fits the critical path (the
# debug module CSR memory feeding the core's branch prediction) has landed
# anywhere between about 93 and 105 MHz.  The Quartus project therefore asks
# the fitter for extra effort; see the physical synthesis settings in
# quartus/qmtech_c5soc_kfb_niosv_codesign.qsf.
set refclk_mhz 50.0
set sysclk_mhz 100.0

create_system niosv_system
set_project_property DEVICE_FAMILY "Cyclone V"
set_project_property DEVICE 5CSEMA6U23I7

# ---------------------------------------------------------------------------
# Instances
# ---------------------------------------------------------------------------
add_instance clk altera_clock_bridge 25.1
set_instance_parameter_value clk {EXPLICIT_CLOCK_RATE} [expr {int($refclk_mhz * 1000000)}]

add_instance clk_pll altera_pll 25.1
set_instance_parameter_value clk_pll {gui_pll_mode} {Integer-N PLL}
set_instance_parameter_value clk_pll {gui_reference_clock_frequency} $refclk_mhz
set_instance_parameter_value clk_pll {gui_operation_mode} {direct}
set_instance_parameter_value clk_pll {gui_number_of_clocks} {1}
set_instance_parameter_value clk_pll {gui_output_clock_frequency0} $sysclk_mhz
set_instance_parameter_value clk_pll {gui_use_locked} {true}

# The reset controller input is active high.  The bridge in front of it makes
# the exported rst_n_i genuinely active low, matching its name, so the board
# top level can drive it with an active-low reset.
add_instance rst_in altera_reset_bridge 25.1
set_instance_parameter_value rst_in {ACTIVE_LOW_RESET} {1}
set_instance_parameter_value rst_in {SYNCHRONOUS_EDGES} {none}

add_instance rst altera_reset_controller 25.1
set_instance_parameter_value rst {NUM_RESET_INPUTS} {1}
set_instance_parameter_value rst {SYNC_DEPTH} {2}

add_instance cpu intel_niosv_g 4.0.0
set_instance_parameter_value cpu {instCacheSize} {0}
set_instance_parameter_value cpu {dataCacheSize} {0}
set_instance_parameter_value cpu {enableFPU} {false}
set_instance_parameter_value cpu {itcm1Size} {131072}
set_instance_parameter_value cpu {itcm1Base} $itcm_base
set_instance_parameter_value cpu {itcm1InitFile} $itcm_init_file
set_instance_parameter_value cpu {dtcm1Size} {32768}
set_instance_parameter_value cpu {dtcm1Base} $dtcm_base
set_instance_parameter_value cpu {dtcm1InitFile} $dtcm_init_file
set_instance_parameter_value cpu {resetSlave} {Absolute}
set_instance_parameter_value cpu {resetOffset} $itcm_base

add_instance jtag_uart altera_avalon_jtag_uart 25.1
set_instance_parameter_value jtag_uart {readBufferDepth} {1024}
set_instance_parameter_value jtag_uart {writeBufferDepth} {1024}

add_instance pio_led altera_avalon_pio 25.1
set_instance_parameter_value pio_led {direction} {Output}
set_instance_parameter_value pio_led {width} {1}
set_instance_parameter_value pio_led {resetValue} {0}

add_instance pio_dipsw altera_avalon_pio 25.1
set_instance_parameter_value pio_dipsw {direction} {Input}
set_instance_parameter_value pio_dipsw {width} {4}

add_instance pio_button altera_avalon_pio 25.1
set_instance_parameter_value pio_button {direction} {Input}
set_instance_parameter_value pio_button {width} {2}

# ---------------------------------------------------------------------------
# Clock and reset
# ---------------------------------------------------------------------------
add_connection clk.out_clk clk_pll.refclk

# Everything, including the reset controller, runs on the PLL output.
foreach sink {rst cpu jtag_uart pio_led pio_dipsw pio_button} {
    add_connection clk_pll.outclk0 $sink.clk
}

# rst_in is asynchronous (SYNCHRONOUS_EDGES none) and therefore has no clock
# interface; the reset controller behind it does the synchronization.
add_connection rst_in.out_reset rst.reset_in0
foreach sink {cpu jtag_uart pio_led pio_dipsw pio_button} {
    add_connection rst.reset_out $sink.reset
}

# ---------------------------------------------------------------------------
# Memory-mapped connections
# ---------------------------------------------------------------------------
proc connect_mm {manager agent base} {
    add_connection $manager $agent
    set_connection_parameter_value $manager/$agent baseAddress $base
}

connect_mm cpu.instruction_manager cpu.instruction_tcs1        $itcm_base
connect_mm cpu.data_manager        cpu.instruction_tcs1        $itcm_base
connect_mm cpu.data_manager        cpu.data_tcs1               $dtcm_base

connect_mm cpu.instruction_manager cpu.dm_agent                0x00020000
connect_mm cpu.data_manager        cpu.dm_agent                0x00020000
connect_mm cpu.data_manager        cpu.timer_sw_agent          0x00038000
connect_mm cpu.data_manager        pio_dipsw.s1                0x00038040
connect_mm cpu.data_manager        pio_button.s1               0x00038050
connect_mm cpu.data_manager        pio_led.s1                  0x00038060
connect_mm cpu.data_manager        jtag_uart.avalon_jtag_slave 0x00038070

# ---------------------------------------------------------------------------
# Interrupts
# ---------------------------------------------------------------------------
add_connection cpu.platform_irq_rx jtag_uart.irq
set_connection_parameter_value cpu.platform_irq_rx/jtag_uart.irq irqNumber {0}

# ---------------------------------------------------------------------------
# Exported interfaces (names are relied on by the board top level)
# ---------------------------------------------------------------------------
add_interface clk_i clock end
set_interface_property clk_i EXPORT_OF clk.in_clk
add_interface pll_rst_i reset end
set_interface_property pll_rst_i EXPORT_OF clk_pll.reset
add_interface locked_o conduit end
set_interface_property locked_o EXPORT_OF clk_pll.locked
add_interface rst_n_i reset end
set_interface_property rst_n_i EXPORT_OF rst_in.in_reset
add_interface led_o conduit end
set_interface_property led_o EXPORT_OF pio_led.external_connection
add_interface dipsw_o conduit end
set_interface_property dipsw_o EXPORT_OF pio_dipsw.external_connection
add_interface button_o conduit end
set_interface_property button_o EXPORT_OF pio_button.external_connection

save_system niosv_system.qsys
