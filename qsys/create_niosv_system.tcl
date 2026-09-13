# Platform Designer generator for the FPGA-side Nios V control system.
#
# Run from qsys/ with:
#   qsys-script --script=create_niosv_system.tcl
#   qsys-generate niosv_system.qsys -- Quartus
#
# The system intentionally uses on-chip memory for first bring-up.  A later
# application can replace the memory with an Avalon-MM SDRAM bridge without
# changing the exported board-level PIO interfaces.

package require -exact qsys 25.1

create_system niosv_system
set_project_property DEVICE_FAMILY "Cyclone V"
set_project_property DEVICE 5CSEMA6U23I7

add_instance clk altera_avalon_clock_source 25.1

add_instance rst altera_reset_controller 25.1
set_instance_parameter_value rst {NUM_RESET_INPUTS} {1}
set_instance_parameter_value rst {SYNC_DEPTH} {2}

add_instance cpu intel_niosv_g 4.0.0
set_instance_parameter_value cpu {itcm1Size} {131072}
set_instance_parameter_value cpu {itcm1Base} {0x00000000}
set_instance_parameter_value cpu {dtcm1Size} {32768}
set_instance_parameter_value cpu {dtcm1Base} {0x20000000}

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

add_connection clk.clk rst.clk
add_connection clk.clk cpu.clk
add_connection clk.clk jtag_uart.clk
add_connection clk.clk pio_led.clk
add_connection clk.clk pio_dipsw.clk
add_connection clk.clk pio_button.clk
add_interface reset_reset_n reset end
set_interface_property reset_reset_n EXPORT_OF rst.reset_in0
add_connection rst.reset_out cpu.reset
add_connection rst.reset_out jtag_uart.reset
add_connection rst.reset_out pio_led.reset
add_connection rst.reset_out pio_dipsw.reset
add_connection rst.reset_out pio_button.reset
add_interface pio_led_export conduit end
set_interface_property pio_led_export EXPORT_OF pio_led.external_connection
add_interface pio_dipsw_export conduit end
set_interface_property pio_dipsw_export EXPORT_OF pio_dipsw.external_connection
add_interface pio_button_export conduit end
set_interface_property pio_button_export EXPORT_OF pio_button.external_connection
add_interface clk_clk clock end
set_interface_property clk_clk EXPORT_OF clk.clk

save_system niosv_system.qsys
