# QMTECH Cyclone V SoC KFB Board Timing Constraints File (.sdc)
#**************************************************************
# Time Information
#**************************************************************
set_time_format -unit ns -decimal_places 3

#**************************************************************
# Create Clock
#**************************************************************
create_clock -period "50.0 MHz" [get_ports FPGA_CLK1_50]
create_clock -period "50.0 MHz" [get_ports FPGA_CLK2_50]
create_clock -period "50.0 MHz" [get_ports FPGA_CLK3_50]

# for enhancing USB BlasterII to be reliable, 25MHz
create_clock -name {altera_reserved_tck} -period 40 {altera_reserved_tck}
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tdi]
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tms]
set_output_delay -clock altera_reserved_tck 3 [get_ports altera_reserved_tdo]

#**************************************************************
# Create Generated Clock
#**************************************************************
derive_pll_clocks 

# create unused clock constraint for HPS I2C's, SPI's and USB's clocks, to avoid misleading unconstraint clock reporting in TimeQuest
create_clock -period "1 MHz"  [get_ports HPS_I2C0_SCLK]
create_clock -period "1 MHz"  [get_ports HPS_I2C1_SCLK]
create_clock -period "48 MHz" [get_ports HPS_USB_CLKOUT]
create_clock -period "25 MHz" [get_ports HPS_SPIM_CLK]

#**************************************************************
# Set Clock Latency
#**************************************************************


#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty

#**************************************************************
# Set Input Delay
#**************************************************************


#**************************************************************
# Set Output Delay
#**************************************************************


#**************************************************************
# Set Clock Groups
#**************************************************************
# Board oscillators (QMTECH schematic, sheet 5):
#   Y4 drives SYS_CLK3_50M -> FPGA_CLK1_50 (V11) and SYS_CLK2_50M -> FPGA_CLK2_50 (Y13)
#   Y3 drives SYS_CLK1_50M -> FPGA_CLK3_50 (E11)
# Clocks from different oscillators are asynchronous.  FPGA_CLK1_50 and
# FPGA_CLK2_50 share an oscillator but have no defined board skew, so do not
# rely on synchronous transfers between them either.
#
# The Nios V system PLL is driven by FPGA_CLK1_50, so its generated clocks
# belong in the same group: transfers between FPGA_CLK1_50 and the Nios V
# domain (the synchronized DIP switches and debounced buttons feeding the
# PIOs) must stay analyzed rather than cut.
set_clock_groups -asynchronous \
    -group [get_clocks {FPGA_CLK1_50 FPGA_CLK2_50 *clk_pll*}] \
    -group [get_clocks {FPGA_CLK3_50}]


#**************************************************************
# Set False Path
#**************************************************************
# Push-buttons and DIP switches are asynchronous; they are re-timed by the
# two-stage input synchronizers in the top level
set_false_path -from [get_ports {KEY[*] DIPSW[*]}]
# The user LED has no timing relationship to the board
set_false_path -to [get_ports {LED}]


#**************************************************************
# Set Multicycle Path
#**************************************************************


#**************************************************************
# Set Maximum Delay
#**************************************************************


#**************************************************************
# Set Minimum Delay
#**************************************************************


#**************************************************************
# Set Input Transition
#**************************************************************

