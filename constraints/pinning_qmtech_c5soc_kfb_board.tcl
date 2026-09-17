# Board pin and I/O assignments for the QMTECH Cyclone V SoC KFB with Dual
# SDRAM board, a close clone of the Terasic DE10-Nano.  Pin numbers follow the
# QMTECH schematic QMTECH_Cyclone_V_SoC_KFB_Dual_SDRAM_Schematic_20240607_V01.
# Note: The QMTECH Board does not feature/have any configuration device (no EPCS, EPCQ, or anything like that)
#
# The Quartus project (quartus/qmtech_c5soc_kfb_niosv_codesign.qsf) stores
# these assignments; this script is the board reference they come from.  After
# changing an assignment here, re-apply it to the project from the repository
# root with:
#
#   quartus_sh -t constraints/pinning_qmtech_c5soc_kfb_board.tcl
#
# The HPS DDR3 I/O standard, termination and drive-strength assignments are not
# part of this file.  They belong to the HPS SDRAM IP and are applied by
# qsys/soc_system/synthesis/submodules/hps_sdram_p0_pin_assignments.tcl.

package require ::quartus::project

set project_name qmtech_c5soc_kfb_niosv_codesign
set project_dir  [file normalize [file join [file dirname [info script]] .. quartus]]

set opened_project 0
if {![is_project_open]} {
    cd $project_dir
    project_open -revision $project_name $project_name
    set opened_project 1
}

set_global_assignment -name FAMILY "Cyclone V"
set_global_assignment -name DEVICE 5CSEMA6U23I7
set_global_assignment -name TOP_LEVEL_ENTITY qmtech_c5soc_kfb_niosv_codesign
set_global_assignment -name DEVICE_FILTER_PACKAGE UFBGA
set_global_assignment -name DEVICE_FILTER_PIN_COUNT 672
set_global_assignment -name DEVICE_FILTER_SPEED_GRADE 7
set_global_assignment -name USE_CONFIGURATION_DEVICE OFF
# Instruct the Assembler to produce a uncompressed bitstream and ensures the target FPGA is configured to not decompress the data on-the-fly during configuration. Note: set MSEL DIP SW [0:4] = '00000' (All set to 'ON')
# (MSEL switch U18: ON drives the MSEL bit to 0.  The QMTECH "How to Set Up" guide lists the board default as MSEL[4:0] = 10101.)
set_global_assignment -name ON_CHIP_BITSTREAM_DECOMPRESSION OFF
# Set configuration scheme to Passive Parallel x16 (FPP x16) - this setting refers to multiple Intel FPGA families (including Stratix V, Arria V, and Cyclone V)
set_global_assignment -name STRATIXV_CONFIGURATION_SCHEME "PASSIVE PARALLEL X16"
set_global_assignment -name GENERATE_RBF_FILE OFF
set_global_assignment -name OCP_HW_EVAL DISABLE


#============================================================
# CLOCK
#============================================================
# The schematic labels these board oscillators SYS_CLK3_50M (V11),
# SYS_CLK2_50M (Y13), and SYS_CLK1_50M (E11), respectively.  The
# FPGA_CLK* names match the board-level HDL ports.  SYS_CLK3_50M and
# SYS_CLK2_50M are both driven by oscillator Y4, SYS_CLK1_50M by Y3.
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to FPGA_CLK1_50
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to FPGA_CLK2_50
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to FPGA_CLK3_50
set_location_assignment PIN_V11 -to FPGA_CLK1_50
set_location_assignment PIN_Y13 -to FPGA_CLK2_50
set_location_assignment PIN_E11 -to FPGA_CLK3_50


#============================================================
# HPS (dedicated HPS I/O; the pin locations are fixed by the HPS)
#============================================================
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_SD_CLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_SD_CMD
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_SD_DATA[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_SD_DATA[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_SD_DATA[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_SD_DATA[3]

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_UART_RX
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_UART_TX

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_USB_CLKOUT
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_USB_DATA[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_USB_DATA[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_USB_DATA[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_USB_DATA[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_USB_DATA[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_USB_DATA[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_USB_DATA[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_USB_DATA[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_USB_DIR
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_USB_NXT
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_USB_STP

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_GTX_CLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_INT_N
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_MDC
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_MDIO
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_RX_CLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_RX_DATA[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_RX_DATA[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_RX_DATA[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_RX_DATA[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_RX_DV
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_TX_DATA[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_TX_DATA[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_TX_DATA[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_TX_DATA[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_ENET_TX_EN

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_KEY
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_LED

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_I2C0_SCLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_I2C0_SDAT
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_I2C1_SCLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_I2C1_SDAT

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_SPIM_CLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_SPIM_MISO
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_SPIM_MOSI
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HPS_SPIM_SS


#============================================================
# KEY
#============================================================
# Push-buttons SW3 (KEY0) and SW2 (KEY1): 4.7k pull-up, pressed = low
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to KEY[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to KEY[1]
set_location_assignment PIN_AH17 -to KEY[0]
set_location_assignment PIN_AH16 -to KEY[1]


#============================================================
# LEDs
#============================================================
# On-board user LED D0 (net LED0): active-high.  Nets LED1..LED7 only go to
# expansion header J12 and are not used by this design.
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED
set_location_assignment PIN_W15 -to LED


#============================================================
# SW
#============================================================
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DIPSW[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DIPSW[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DIPSW[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DIPSW[3]
set_location_assignment PIN_Y24 -to DIPSW[0]
set_location_assignment PIN_W24 -to DIPSW[1]
set_location_assignment PIN_W21 -to DIPSW[2]
set_location_assignment PIN_W20 -to DIPSW[3]


# Set the rest of the unused pins to inputs (in tri-state)
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"


if {$opened_project} {
    export_assignments
    project_close
}
