#!/usr/bin/env tclsh
# TCL file for VLSI-ASIC project - Task 5 (Clock Gating)

# Run source /mnt/apps/prebuilt/eda/cadence-2022-23.bash before executing

################################################################################
## 1. SETUP LIBRARIES
################################################################################

# Use the FAST library (Task 1 Baseline) [cite: 81]
set_db library /mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/timing/fast_vdd1v2_basicCells.lib

set_db lef_library {/mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/lef/gsclib045_tech.lef /mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/lef/gsclib045_macro.lef }

read_qrc /mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/qrc/qx/gpdk045.tch

################################################################################
## 2. ENABLE CLOCK GATING & READ DESIGN
################################################################################

# =======================================================
#  TASK 5 CHANGE: ENABLE CLOCK GATING
# =======================================================
# This must be set BEFORE elaboration according to the Lab Manual.
set_db lp_insert_clock_gating true

# Read RTL
read_hdl /home/p/ppapadoe/Desktop/vlsi-asic/picorv32.v

# Elaborate
elaborate picorv32_wb
current_design picorv32_wb

# Optional check
# check_design picorv32_wb

################################################################################
## 3. APPLY CONSTRAINTS
################################################################################

# Read the SDC file (Use the Task 1 SDC: 4.0ns / 250 MHz)
read_sdc constraints.sdc

# --- Define Optimization Cost Groups ---
define_cost_group -name I2R -design picorv32_wb
define_cost_group -name R2R -design picorv32_wb
define_cost_group -name R2O -design picorv32_wb
define_cost_group -name I2O -design picorv32_wb

# Prevent Genus from swapping normal DFFs with SDFFs (since no scan chain is defined yet)
set_db / .use_scan_seqs_for_non_dft false

################################################################################
## 4. SYNTHESIZE THE DESIGN
################################################################################

puts ">> Starting Synthesis (with Clock Gating enabled)..."
syn_generic
syn_map
syn_opt
puts ">> Synthesis Complete."

################################################################################
## 5. SETUP AND RUN POST-SYNTHESIS REPORTS
################################################################################

exec mkdir -p reports_task5

# Define Reporting Path Groups
path_group -name I2Rgroup -from [all_inputs] -to [all_registers] -group I2R
path_group -name R2Rgroup -from [all_registers] -to [all_registers] -group R2R
path_group -name R2Ogroup -from [all_registers] -to [all_outputs] -group R2O
path_group -name I2Ogroup -from [all_inputs] -to [all_outputs] -group I2O

puts ">> Generating Reports..."

# Standard Reports
report_timing > reports/timing_summary.rpt
report_area -summary > reports/area.rpt
report_power > reports/power.rpt
report_gates > reports/gates.rpt
report_qor > reports/qor.rpt

# Specific Path Reports
report_timing -from [all_registers] -to [all_registers] > reports/r2r.rpt
report_timing -from [all_inputs]    -to [all_registers] > reports/i2r.rpt
report_timing -from [all_registers] -to [all_outputs]   > reports/r2o.rpt
report_timing -from [all_inputs]    -to [all_outputs]   > reports/i20.rpt

# =======================================================
#  TASK 5 CHANGE: CLOCK GATING REPORT
# =======================================================
# Required to extract statistics for the assignment 
report_clock_gating > reports/clock_gating.rpt

puts ">> All reports generated successfully."

################################################################################
## 6. OUTPUT FILES
################################################################################

# Output design for Innovus (Folder: picorv32_wb)
write_design -innovus picorv32_wb

puts "run.tcl done"
