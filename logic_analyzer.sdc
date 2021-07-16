#**************************************************************
# This .sdc file is created by Terasic Tool.
# Users are recommended to modify this file to match users logic.
#**************************************************************

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
remove_clock [get_clocks *cascadeout]
remove_clock [get_clocks *vcoph*]

create_clock -add -period "500.0 MHz" {u0|pll_capture|altera_pll_i|cyclonev_pll|counter[3].output_counter|divclk}
create_clock -add -period "62.5 MHz" [get_nets frontend|clk_gen[3]]
create_clock -add -period "40.0 MHz" {u0|pll_adc|altera_pll_i|cyclonev_pll|counter[3].output_counter|divclk}
create_clock -add -period "100.0 MHz" {u0|pll_mem|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}


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
set_clock_groups -asynchronous -group {FPGA_CLK1_50} -group [get_clocks *pll_capture|*|divclk] [get_clocks *frontend|clk_gen[3]*] -group [get_clocks *pll_mem|*|divclk] -group [get_clocks *pll_adc|*|divclk]



#**************************************************************
# Set False Path
#**************************************************************



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



#**************************************************************
# Set Load
#**************************************************************



