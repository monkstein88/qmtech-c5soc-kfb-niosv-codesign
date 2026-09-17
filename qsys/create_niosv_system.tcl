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
#   0x1000_0000           debug module (dm_agent)
#   0x1001_0000           machine timer / software interrupt (timer_sw_agent)
#   0x1002_0000           JTAG UART (IRQ 0)
#   0x1003_0000           LED PIO        (1 bit, output)
#   0x1003_0010           DIP-switch PIO (4 bits, input)
#   0x1003_0020           button PIO     (2 bits, input, active-low, debounced)
#   0x2000_0000   32 KiB  data TCM1
#
# The TCMs are accessed by the core directly.  Their AXI4-Lite subordinate
# ports (instruction_tcs1/data_tcs1) are looped back onto the managers at the
# same base address, which is the Nios V/g arrangement that lets the debugger
# download software into the TCMs and gives the BSP its memory regions.
#
# Platform Designer inserts the AXI4 to Avalon-MM translation for the
# Avalon-MM agents (debug module, timer, JTAG UART, PIOs) automatically.
#
# The processor caches are disabled: every memory is tightly coupled, so a
# cache would only consume M10K blocks.  If cached external memory is added
# later, re-enable the caches and place all peripherals inside a Nios V
# peripheral region (peripheralRegionABase/Size), which must stay uncached.

package require -exact qsys 25.1

# Firmware image used to initialize the TCMs.  The paths are relative to the
# Quartus project directory (quartus/), where Analysis & Synthesis resolves
# them.  They are produced by scripts/build_firmware.sh.
set itcm_init_file ../software/build/firmware/niosvitcm1.hex
set dtcm_init_file ../software/build/firmware/niosvdtcm1.hex

set itcm_base 0x00000000
set dtcm_base 0x20000000

create_system niosv_system
set_project_property DEVICE_FAMILY "Cyclone V"
set_project_property DEVICE 5CSEMA6U23I7

# ---------------------------------------------------------------------------
# Instances
# ---------------------------------------------------------------------------
add_instance clk altera_clock_bridge 25.1
set_instance_parameter_value clk {EXPLICIT_CLOCK_RATE} {50000000}

add_instance rst altera_reset_controller 25.1
set_instance_parameter_value rst {NUM_RESET_INPUTS} {1}
set_instance_parameter_value rst {SYNC_DEPTH} {2}

add_instance cpu intel_niosv_g 4.0.0
set_instance_parameter_value cpu {instCacheSize} {0}
set_instance_parameter_value cpu {dataCacheSize} {0}
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
foreach sink {rst cpu jtag_uart pio_led pio_dipsw pio_button} {
    add_connection clk.out_clk $sink.clk
}
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

connect_mm cpu.instruction_manager cpu.dm_agent                0x10000000
connect_mm cpu.data_manager        cpu.dm_agent                0x10000000
connect_mm cpu.data_manager        cpu.timer_sw_agent          0x10010000
connect_mm cpu.data_manager        jtag_uart.avalon_jtag_slave 0x10020000
connect_mm cpu.data_manager        pio_led.s1                  0x10030000
connect_mm cpu.data_manager        pio_dipsw.s1                0x10030010
connect_mm cpu.data_manager        pio_button.s1               0x10030020

# ---------------------------------------------------------------------------
# Interrupts
# ---------------------------------------------------------------------------
add_connection cpu.platform_irq_rx jtag_uart.irq
set_connection_parameter_value cpu.platform_irq_rx/jtag_uart.irq irqNumber {0}

# ---------------------------------------------------------------------------
# Exported interfaces (names are relied on by the board top level)
# ---------------------------------------------------------------------------
add_interface clk_clk clock end
set_interface_property clk_clk EXPORT_OF clk.in_clk
add_interface reset_reset_n reset end
set_interface_property reset_reset_n EXPORT_OF rst.reset_in0
add_interface pio_led_export conduit end
set_interface_property pio_led_export EXPORT_OF pio_led.external_connection
add_interface pio_dipsw_export conduit end
set_interface_property pio_dipsw_export EXPORT_OF pio_dipsw.external_connection
add_interface pio_button_export conduit end
set_interface_property pio_button_export EXPORT_OF pio_button.external_connection

save_system niosv_system.qsys
