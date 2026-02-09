#!/usr/bin/env tclsh
# TCL file for VLSI-ASIC project

# Run source /mnt/apps/prebuilt/eda/cadence-2022-23.bash before executing the file

################################################################################
## 1. SETUP LIBRARIES
##
## Define the timing, physical (LEF), and parasitical (QRC)
## libraries for the 45nm GPDK.
################################################################################

# Set timing library (fast corner)
set_db library /mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/timing/fast_vdd1v2_basicCells.lib

# Set physical libraries (LEF macro and tech files)
set_db lef_library {/mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/lef/gsclib045_tech.lef /mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/lef/gsclib045_macro.lef }

# Set parasitical library (QRC tech file)
read_qrc /mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/qrc/qx/gpdk045.tch

################################################################################
## 2. READ AND ELABORATE DESIGN
##
## Load the RTL and create the initial unmapped design.
################################################################################

# Read the top-level Verilog file
read_hdl /home/p/ppapadoe/Desktop/vlsi-asic/picorv32.v

# Set current design
current_design picorv32_wb

# Elaborate the design (instantiate the module)
elaborate picorv32_wb

# Optional: Uncomment to run a design check
check_design picorv32

################################################################################
## 3. APPLY CONSTRAINTS AND OPTIMIZATION STRATEGY
##
## Load the SDC constraints and define any optimization groups
## *before* running synthesis.
################################################################################

# Read the Synopsys Design Constraints file
read_sdc constraints.sdc

# --- Define Optimization Cost Groups ---
# Tell Genus which path types to prioritize during synthesis.
# This (and set_cost_group_weight) changes the synthesis *effort*.
define_cost_group -name I2R -design picorv32_wb
define_cost_group -name R2R -design picorv32_wb
define_cost_group -name R2O -design picorv32_wb
define_cost_group -name I2O -design picorv32_wb

# Example: Make Genus try twice as hard on R2R paths
# set_cost_group_weight -group my_r2r_paths -weight 2.0

# Prevent Genus from swapping normal DFFs with SDFFs (Scan Flip Flops)
# without this, Innovus will complain about missing scan chains.
set_db / .use_scan_seqs_for_non_dft false

################################################################################
## 4. SYNTHESIZE THE DESIGN
##
## Run the main synthesis command to map the design to the
## standard cell library.
################################################################################

puts ">> Starting Synthesis..."
syn_generic
syn_map
syn_opt
puts ">> Synthesis Complete."

################################################################################
## 5. SETUP AND RUN POST-SYNTHESIS REPORTS
##
## Generate all necessary reports for area, timing, power,
## and Quality of Results (QoR) as required by the lab manual.
################################################################################

# --- Create a directory for the reports ---
# The 'exec' command runs a shell command
exec mkdir -p reports


# --- Define Reporting Path Groups ---
# This organizes the timing report into the required I2R, R2R,
# R2O, and I2O buckets.
path_group -name I2Rgroup -from [all_inputs] -to [all_registers] -group I2R
path_group -name R2Rgroup -from [all_registers] -to [all_registers] -group R2R
path_group -name R2Ogroup -from [all_registers] -to [all_outputs] -group R2O
path_group -name I2Ogroup -from [all_inputs] -to [all_outputs] -group I2O

# --- Generate Reports ---
puts ">> Generating Reports (saving to 'reports/' directory)..."

# 1. Timing Report (Slack for I2O, I2R, R2O, R2R)
# The -summary flag uses the 'group_path' definitions to
# create the exact summary you need.
report_timing > reports/timing_summary.rpt

# 2. Area Report (Total Area & Cell Types: Comb/Seq)
# This report provides the total area and the cell count
# broken down by type (combinational, sequential, etc.).
report_area -summary > reports/area.rpt

# 3. Power Report (Total & Leakage/Dynamic)
# This report provides the total power and its components
# (leakage, dynamic, etc.).
report_power > reports/power.rpt

# 4. Number of Cells by Type
report_gates > reports/gates.rpt

# 5. Quality of Results (QoR) Summary
# This provides a high-level summary of the synthesis results.
report_qor > reports/qor.rpt

# 6. Timings for all path types
report_timing -from [all_registers] -to [all_registers] > reports/r2r.rpt
report_timing -from [all_inputs]    -to [all_registers] > reports/i2r.rpt
report_timing -from [all_registers] -to [all_outputs]   > reports/r2o.rpt
report_timing -from [all_inputs] -to [all_outputs] > reports/i20.rpt
write_design -innovus picorv32_wb
puts ">> All reports generated successfully."


################################################################################
## 6. OUTPUT FILES
##
## Generate all output files for the final design, constraints 
## and different innovus files.
################################################################################

#exec mkdir -p outputs

# --- Gate-Level Netlist ---
#write_hdl > design.v

# --- Constraints ---
#write_sdc > constraints_sdc.out

# --- Innovus ---
#write_design -base_name ./outputs/picorv32_mapped -innovus 

# --- Create a folder named genus_invs_des that contains all the necessary files for Innovus
write_design -innovus picorv32_wb
################################################################################
## 6. SCRIPT FINISH
################################################################################

puts "run.tcl done"
#exit
