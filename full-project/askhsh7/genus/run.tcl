#!/usr/bin/env tclsh
# TCL file for VLSI-ASIC project - Task 7 (LEC Generation - Robust Version)

# Run source /mnt/apps/prebuilt/eda/cadence-2022-23.bash before executing

################################################################################
## 1. SETUP & READ
################################################################################
puts ">> Setting up libraries..."
set_db library /mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/timing/fast_vdd1v2_basicCells.lib
set_db lef_library {/mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/lef/gsclib045_tech.lef /mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/lef/gsclib045_macro.lef }
read_qrc /mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/qrc/qx/gpdk045.tch

# Disable scan logic insertion for standard synthesis (matches Task 1)
set_db / .use_scan_seqs_for_non_dft false

puts ">> Reading Design..."
read_hdl /home/p/ppapadoe/Desktop/vlsi-asic/picorv32.v
elaborate picorv32_wb
current_design picorv32_wb

################################################################################
## 2. SNAPSHOT I: ELABORATION (RTL vs Elaborated)
################################################################################
puts ">> Saving Elaboration Snapshot..."

# 1. Save the actual netlist file (Crucial step missing before)
write_netlist > picorv32_elab.v

# 2. Generate the DO file pointing to that specific netlist
write_do_lec -top picorv32_wb -golden_design rtl -revised_design picorv32_elab.v -log_file rtl_vs_elab.lec.log > rtl_vs_elab.do


################################################################################
## 3. SNAPSHOT II: GENERIC SYNTHESIS
################################################################################
read_sdc constraints.sdc

puts ">> Running Syn Generic..."
syn_generic

puts ">> Saving Generic Snapshot..."
write_netlist > picorv32_generic.v
write_do_lec -top picorv32_wb -golden_design rtl -revised_design picorv32_generic.v -log_file rtl_vs_generic.lec.log > rtl_vs_generic.do


################################################################################
## 4. SNAPSHOT III: MAPPED SYNTHESIS
################################################################################
puts ">> Running Syn Map..."
syn_map

puts ">> Saving Mapped Snapshot..."
write_netlist > picorv32_mapped.v
write_do_lec -top picorv32_wb -golden_design rtl -revised_design picorv32_mapped.v -log_file rtl_vs_mapped.lec.log > rtl_vs_mapped.do


################################################################################
## 5. SNAPSHOT IV: FINAL OPTIMIZATION (RTL vs Final)
################################################################################
puts ">> Running Syn Opt..."
syn_opt

puts ">> Saving Final Snapshot..."
# Note: write_netlist -lec is often better for the final stage as it handles naming slightly better for verification
write_netlist -lec > picorv32_final.v 
write_do_lec -top picorv32_wb -golden_design rtl -revised_design picorv32_final.v -log_file rtl_vs_final.lec.log > rtl_vs_final.do

puts "--------------------------------------------------------"
puts ">> Synthesis Complete. All snapshots and DO files generated."
puts ">> To run the comparisons required by Task 7:"
puts "   1. lec -XL -nogui -dofile rtl_vs_elab.do"
puts "   2. lec -XL -nogui -dofile rtl_vs_final.do"
puts "--------------------------------------------------------"
exit
