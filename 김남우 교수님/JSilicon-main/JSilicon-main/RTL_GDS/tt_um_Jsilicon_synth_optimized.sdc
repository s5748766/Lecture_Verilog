###############################################################################
# Timing Constraints - Optimized for 150MHz
# File: tt_um_Jsilicon_synth_optimized.sdc
###############################################################################

# Units
set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA

###############################################################################
# Clock Definition - 150MHz (6.67ns period)
###############################################################################

# Main clock: 150 MHz
create_clock -name clk -period 6.67 [get_ports clk]

# Clock uncertainty (jitter + skew)
set_clock_uncertainty 0.5 [get_clocks clk]

# Clock transition
set_clock_transition 0.1 [get_clocks clk]

# Clock latency (ideal for now, will be updated after CTS)
# set_clock_latency -source 0.0 [get_clocks clk]
# set_clock_latency 0.0 [get_clocks clk]

###############################################################################
# Input/Output Delays - Reduced for timing closure
###############################################################################

# Input delay: 1.0ns (reduced from 1.5ns)
set_input_delay -clock clk -max 1.0 [remove_from_collection [all_inputs] [get_ports clk]]
set_input_delay -clock clk -min 0.2 [remove_from_collection [all_inputs] [get_ports clk]]

# Output delay: 1.0ns
set_output_delay -clock clk -max 1.0 [all_outputs]
set_output_delay -clock clk -min 0.2 [all_outputs]

###############################################################################
# Input/Output Transition
###############################################################################

# Input transition
set_input_transition 0.1 [remove_from_collection [all_inputs] [get_ports clk]]

# Drive strength (moderate driver)
set_driving_cell -lib_cell BUFX2 -library gscl45nm [remove_from_collection [all_inputs] [get_ports clk]]

# Output load (moderate load)
set_load 0.05 [all_outputs]

###############################################################################
# Operating Conditions
###############################################################################

# Typical corner
set_operating_conditions -max typical -max_library gscl45nm
set_operating_conditions -min typical -min_library gscl45nm

###############################################################################
# Design Rules
###############################################################################

# Max transition time
set_max_transition 0.5 [current_design]

# Max capacitance
set_max_capacitance 0.2 [current_design]

# Max fanout
set_max_fanout 20 [current_design]

###############################################################################
# False Paths (if any)
###############################################################################

# Example: Asynchronous reset
# set_false_path -from [get_ports rst_n]

###############################################################################
# Multicycle Paths (if needed)
###############################################################################

# Example: 2-cycle path for complex ALU operations
# set_multicycle_path -setup 2 -from [get_pins alu_inst/*] -to [get_pins result_reg/*]
# set_multicycle_path -hold 1 -from [get_pins alu_inst/*] -to [get_pins result_reg/*]

###############################################################################
# Case Analysis (for mux controls)
###############################################################################

# Example: Set static control signals
# set_case_analysis 0 [get_ports test_mode]

###############################################################################
# End of SDC
###############################################################################
