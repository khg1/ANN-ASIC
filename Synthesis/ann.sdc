#----user defined variables---
set lib_cell_name "BUFX2"

#-----MAIN CHIP CLOCK--------------
set EXTCLK_PERIOD 2.5
set CLK_UNCERT [expr {0.01 * $EXTCLK_PERIOD}]
set CLK_LATENCY [expr {0.15 * $EXTCLK_PERIOD}]

#-----AXI CLOCK---------------
set ACLK_PERIOD 10
set ACLK_UNCERT [expr {0.01 * $ACLK_PERIOD}]
set ACLK_LATENCY [expr {0.15 * $ACLK_PERIOD}] 



set IN_DELAY_MAX [expr {0.30 * $ACLK_PERIOD}]
set IN_DELAY_MIN [expr {0.10 * $ACLK_PERIOD}]
set OUT_DELAY_MAX [expr {0.30 * $ACLK_PERIOD}]
set OUT_DELAY_MIN [expr {0.10 * $ACLK_PERIOD}]

set OUT_CAP [get_db [get_lib_pins BUFX2/A] .capacitance]


#-------clock--------
create_clock -name "clk125" -period $EXTCLK_PERIOD [get_ports clk]
create_clock -name "aclk"   -period $ACLK_PERIOD [get_ports S_AXI_ACLK]

set_clock_groups -asynchronous -group [get_clocks clk125] \
			       -group [get_clocks aclk]

set_clock_uncertainty -setup $CLK_UNCERT [get_clocks clk125]
set_clock_latency $CLK_LATENCY  [get_clocks clk125]

set_clock_uncertainty -setup $ACLK_UNCERT [get_clocks aclk]
set_clock_latency $ACLK_LATENCY  [get_clocks aclk]


#------input constraints-------
set all_data_inputs [remove_from_collection [all_inputs] [get_ports {S_AXI_ACLK clk}]]
set_input_delay -max $IN_DELAY_MAX -clock aclk $all_data_inputs

#------output constraints------
set_output_delay -max $OUT_DELAY_MAX -clock aclk [all_outputs]

#------DRC--------
set_max_transition [expr {0.15 * $ACLK_PERIOD}] [current_design]
set_load $OUT_CAP [all_outputs]
set_driving_cell -lib_cell $lib_cell_name $all_data_inputs

#-------EXCEPTIONS------
set_false_path -from [get_clocks clk125] -to [get_clocks aclk]
