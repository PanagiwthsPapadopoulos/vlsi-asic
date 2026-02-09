# Cadence Genus(TM) Synthesis Solution, Version 21.15-s080_1, built Sep 23 2022 12:57:55

# Date: Sun Nov 30 18:46:01 2025
# Host: cn88.it.auth.gr (x86_64 w/Linux 5.14.0-570.52.1.el9_6.x86_64) (12cores*12cpus*1physical cpu*Intel(R) Xeon(R) Gold 6230 CPU @ 2.10GHz 28160KB)
# OS:   Rocky Linux release 9.6 (Blue Onyx)

set_db library /mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/timing/fast_vdd1v2_basicCells.lib
set_db lef_library {/mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/lef/gsclib045_tech.lef /mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/lef/gsclib045_macro.lef }
read_qrc /mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/qrc/qx/gpdk045.tch
set_db dft_scan_style muxed_scan
set_db dft_prefix DFT_
read_hdl /home/p/ppapadoe/Desktop/vlsi-asic/picorv32.v
elaborate picorv32_wb
current_design picorv32_wb
read_sdc constraints.sdc
define_cost_group -name I2R -design picorv32_wb
define_cost_group -name R2R -design picorv32_wb
define_cost_group -name R2O -design picorv32_wb
define_cost_group -name I2O -design picorv32_wb
define_shift_enable -name se -active high -create_port se
define_test_mode -name test_mode -active high -create_port test_mode
define_scan_chain -name top_chain -sdi scan_in -sdo scan_out -shift_enable se -create_ports
check_dft_rules
syn_generic
syn_map
connect_scan_chains -auto_create_chains -preview
connect_scan_chains -auto_create_chains
syn_opt
exec mkdir -p reports
report_scan_chains > reports/scan_chains.rpt
report_scan_setup > reports/scan_setup.rpt
report_timing > reports/timing_summary.rpt
report_area -summary > reports/area.rpt
report_power > reports/power.rpt
report_gates > reports/gates.rpt
write_scandef > picorv32.scandef
write_design -innovus picorv32_wb
exit
