# Synopsys Design Constraints (SDC) File for VLSI Project
# Clock Period Calculation: T = 1 / 400 MHz = 2.5 ns

################################################################
# 1, 2, 3, 4) Clock Definition (clk) and Characteristics
################################################################

# 1) Create clock 'clk' (400 MHz, 50% duty) πάνω στην πόρτα wb_clk_i
set clk_port [get_ports wb_clk_i]
create_clock -name clk -period 2.5 -waveform {0 1.25} $clk_port

# 2) Source latency 0.20 ns
set_clock_latency -source 0.20 [get_clocks clk]

# 3) Clock uncertainty 0.02 ns
set_clock_uncertainty 0.02 [get_clocks clk]

# 4) Clock transition 0.025 ns
set_clock_transition 0.025 [get_clocks clk]

################################################################
# Συλλογές I/O (αποφυγή επιβολής constraints στο ρολόι)
################################################################
set IN_PORTS  [remove_from_collection [all_inputs]  $clk_port]
set OUT_PORTS [all_outputs]

################################################################
# 9, 10, 11) Input Constraints: Delays and Driving Cell
################################################################

# 9) Input delay (Setup/Max) 0.50 ns
set_input_delay -max 0.50 -clock [get_clocks clk] $IN_PORTS

# 10) Input delay (Hold/Min) 0.25 ns
set_input_delay -min 0.25 -clock [get_clocks clk] $IN_PORTS

# 11) Driving cells για εισόδους
#    (προσαρμόστε τα ονόματα κελιών αν χρειαστεί, ανάλογα με τη βιβλιοθήκη σας)
set_driving_cell -lib_cell BUFX2           $IN_PORTS   ;# για Setup/Max
set_driving_cell -lib_cell BUFX8 -min      $IN_PORTS   ;# για Hold/Min

################################################################
# 5, 6, 7, 8) Output Constraints: Delays and Load
################################################################

# 5) Output delay (Setup/Max) 0.50 ns
set_output_delay -max 0.50 -clock [get_clocks clk] $OUT_PORTS

# 6) Output delay (Hold/Min) 0.25 ns
set_output_delay -min 0.25 -clock [get_clocks clk] $OUT_PORTS

# 7) Output load (Setup/Max) 0.3 pF
set_load 0.3 $OUT_PORTS

# 8) Output load (Hold/Min) 0.04 pF
set_load -min 0.04 $OUT_PORTS

