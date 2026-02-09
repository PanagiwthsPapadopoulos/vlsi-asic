# Cadence Genus(TM) Synthesis Solution, Version 21.15-s080_1, built Sep 23 2022 12:57:55

# Date: Sat Nov 29 12:35:00 2025
# Host: cn99.it.auth.gr (x86_64 w/Linux 5.14.0-570.52.1.el9_6.x86_64) (12cores*12cpus*1physical cpu*Intel(R) Xeon(R) Gold 6230 CPU @ 2.10GHz 28160KB)
# OS:   Rocky Linux release 9.6 (Blue Onyx)

set_db library /mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/timing/slow_vdd1v2_basicCells.lib
set_db lef_library {/mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/lef/gsclib045_tech.lef /mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/lef/gsclib045_macro.lef }
read_qrc /mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/qrc/qx/gpdk045.tch
read_hdl /home/p/ppapadoe/Desktop/vlsi-asic/picorv32.v
elaborate picorv32_wb
current_design picorv32_wb
read_sdc constraints.sdc
define_cost_group -name I2R -design picorv32_wb
define_cost_group -name R2R -design picorv32_wb
define_cost_group -name R2O -design picorv32_wb
define_cost_group -name I2O -design picorv32_wb
set_db / .use_scan_seqs_for_non_dft false
puts ">> Starting Synthesis..."
syn_generic
syn_map
syn_opt
puts ">> Synthesis Complete."
exec mkdir -p reports
path_group -name I2Rgroup -from [all_inputs] -to [all_registers] -group I2R
path_group -name R2Rgroup -from [all_registers] -to [all_registers] -group R2R
path_group -name R2Ogroup -from [all_registers] -to [all_outputs] -group R2O
path_group -name I2Ogroup -from [all_inputs] -to [all_outputs] -group I2O
puts ">> Generating Reports (saving to 'reports/' directory)..."
report_timing > reports/timing_summary.rpt
report_area -summary > reports/area.rpt
report_power > reports/power.rpt
report_gates > reports/gates.rpt
report_qor > reports/qor.rpt
puts ">> All reports generated successfully."
write_design -innovus picorv32_wb
exit
