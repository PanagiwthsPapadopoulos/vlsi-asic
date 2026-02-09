# Cadence Genus(TM) Synthesis Solution, Version 21.15-s080_1, built Sep 23 2022 12:57:55

# Date: Sun Dec 07 17:26:50 2025
# Host: cn90.it.auth.gr (x86_64 w/Linux 5.14.0-570.52.1.el9_6.x86_64) (12cores*12cpus*1physical cpu*AMD EPYC 7352 24-Core Processor 512KB)
# OS:   Rocky Linux release 9.6 (Blue Onyx)

set_db library /mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/timing/fast_vdd1v2_basicCells.lib
set_db lef_library {/mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/lef/gsclib045_tech.lef /mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/lef/gsclib045_macro.lef }
read_qrc /mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/qrc/qx/gpdk045.tch
read_hdl /home/p/ppapadoe/Desktop/vlsi-asic/picorv32.v
elaborate picorv32_wb
current_design picorv32_wb
read_sdc constraints.sdc
set_db / .use_scan_seqs_for_non_dft false
syn_generic
syn_map
syn_opt
write_design -innovus picorv32_wb
exit
