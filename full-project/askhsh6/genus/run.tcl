#!/usr/bin/env tclsh
# TCL file for VLSI-ASIC project - Task 6 (DFT / Scan Chain)

# Run source /mnt/apps/prebuilt/eda/cadence-2022-23.bash before executing

################################################################################
## 1. SETUP LIBRARIES (Task 1 Baseline - FAST Library)
################################################################################
set_db library /mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/timing/fast_vdd1v2_basicCells.lib
set_db lef_library {/mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/lef/gsclib045_tech.lef /mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/lef/gsclib045_macro.lef }
read_qrc /mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/qrc/qx/gpdk045.tch

################################################################################
## 2. DFT SETUP (BEFORE ELABORATION)
################################################################################

# === TASK 6 CHANGE: DFT CONFIGURATION ===
# Define Scan Style (Muxed Scan is standard) [cite: 703]
set_db dft_scan_style muxed_scan
set_db dft_prefix DFT_

read_hdl /home/p/ppapadoe/Desktop/vlsi-asic/picorv32.v
elaborate picorv32_wb
current_design picorv32_wb

################################################################################
## 3. CONSTRAINTS & DFT SIGNALS
################################################################################

# Read Task 1 Constraints (4.0ns)
read_sdc constraints.sdc

# --- Define Optimization Cost Groups ---
define_cost_group -name I2R -design picorv32_wb
define_cost_group -name R2R -design picorv32_wb
define_cost_group -name R2O -design picorv32_wb
define_cost_group -name I2O -design picorv32_wb

# === TASK 6 CHANGE: DEFINE DFT SIGNALS ===
# We REMOVED the "use_scan_seqs_for_non_dft false" line to allow scan mapping.

# Define Shift Enable (Controls shift vs capture mode) [cite: 737]
define_shift_enable -name se -active high -create_port se

# Define Test Mode (Static signal to enable test logic) [cite: 742]
define_test_mode -name test_mode -active high -create_port test_mode

# Define the Scan Chain (Inputs/Outputs) [cite: 747]
# Using auto_create_chains later, but defining ports here
define_scan_chain -name top_chain -sdi scan_in -sdo scan_out -shift_enable se -create_ports

# Check if DFT rules are met so far [cite: 751]
check_dft_rules

################################################################################
## 4. SYNTHESIZE WITH DFT
################################################################################

puts ">> Starting Synthesis..."
syn_generic
syn_map

# === TASK 6 CHANGE: CONNECT SCAN CHAINS ===
# This stitches the Flip-Flops together into a chain [cite: 755]
connect_scan_chains -auto_create_chains -preview
connect_scan_chains -auto_create_chains

syn_opt
puts ">> Synthesis Complete."

################################################################################
## 5. REPORTS (Task 6 Specifics)
################################################################################
exec mkdir -p reports

# === TASK 6 CHANGE: DFT REPORTS ===
report_scan_chains > reports/scan_chains.rpt
report_scan_setup > reports/scan_setup.rpt

# Standard Reports
report_timing > reports/timing_summary.rpt
report_area -summary > reports/area.rpt
report_power > reports/power.rpt
report_gates > reports/gates.rpt

puts ">> All reports generated."

################################################################################
## 6. OUTPUT FILES (CRITICAL FOR INNOVUS)
################################################################################

# === TASK 6 CHANGE: EXPORT SCAN DEF ===
# Innovus needs this file to know the order of the scan chain for reordering
write_scandef > picorv32.scandef

# Output design
write_design -innovus picorv32_wb

puts "run.tcl done"
