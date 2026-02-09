# Cadence Genus(TM) Synthesis Solution, Version 21.15-s080_1, built Sep 23 2022 12:57:55

# Date: Wed Dec 03 19:16:16 2025
# Host: cn92.it.auth.gr (x86_64 w/Linux 5.14.0-570.52.1.el9_6.x86_64) (12cores*12cpus*1physical cpu*AMD EPYC 7352 24-Core Processor 512KB)
# OS:   Rocky Linux release 9.6 (Blue Onyx)

set_db library /mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/timing/fast_vdd1v2_basicCells.lib
set_db lef_library {/mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/lef/gsclib045_tech.lef /mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/lef/gsclib045_macro.lef }
read_qrc /mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/qrc/qx/gpdk045.tch
set_db / .use_scan_seqs_for_non_dft false
puts ">> Reading Design..."
read_hdl /home/p/ppapadoe/Desktop/vlsi-asic/picorv32.v
elaborate picorv32_wb
current_design picorv32_wb
puts ">> Saving Elaboration Snapshot..."
write_netlist > picorv32_elab.v
write_do_lec -top picorv32_wb -golden_design rtl -revised_design picorv32_elab.v -log_file rtl_vs_elab.lec.log > rtl_vs_elab.do
read_sdc constraints.sdc
puts ">> Running Syn Generic..."
syn_generic
puts ">> Saving Generic Snapshot..."
write_netlist > picorv32_generic.v
write_do_lec -top picorv32_wb -golden_design rtl -revised_design picorv32_generic.v -log_file rtl_vs_generic.lec.log > rtl_vs_generic.do
puts ">> Running Syn Map..."
syn_map
puts ">> Saving Mapped Snapshot..."
write_netlist > picorv32_mapped.v
write_do_lec -top picorv32_wb -golden_design rtl -revised_design picorv32_mapped.v -log_file rtl_vs_mapped.lec.log > rtl_vs_mapped.do
puts ">> Running Syn Opt..."
syn_opt
puts ">> Saving Final Snapshot..."
write_netlist -lec > picorv32_final.v
write_do_lec -top picorv32_wb -golden_design rtl -revised_design picorv32_final.v -log_file rtl_vs_final.lec.log > rtl_vs_final.do
puts "--------------------------------------------------------"
puts ">> Synthesis Complete. All snapshots and DO files generated."
puts ">> To run the comparisons required by Task 7:"
puts "   1. lec -XL -nogui -dofile rtl_vs_elab.do"
puts "   2. lec -XL -nogui -dofile rtl_vs_final.do"
puts "--------------------------------------------------------"
exit
