#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Thu Jan  8 19:07:16 2026                
#                                                     
#######################################################

#@(#)CDS: Innovus v21.35-s114_1 (64bit) 10/13/2022 12:11 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: NanoRoute 21.35-s114_1 NR220912-2004/21_15-UB (database version 18.20.592_1) {superthreading v2.17}
#@(#)CDS: AAE 21.15-s039 (64bit) 10/13/2022 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: CTE 21.15-s038_1 () Sep 20 2022 11:42:13 ( )
#@(#)CDS: SYNTECH 21.15-s012_1 () Sep  5 2022 10:25:51 ( )
#@(#)CDS: CPE v21.15-s076
#@(#)CDS: IQuantus/TQuantus 21.1.1-s867 (64bit) Sun Jun 26 22:12:54 PDT 2022 (Linux 3.10.0-693.el7.x86_64)

set_global _enable_mmmc_by_default_flow      $CTE::mmmc_default
suppressMessage ENCEXT-2799
getVersion
getVersion
getVersion
win
encMessage warning 0
encMessage debug 0
is_common_ui_mode
restoreDesign /home/p/ppapadoe/Desktop/vlsi-asic/askhsh8/innovus_2026/picorv32_pads_preplacement.dat picorv32_pads
setDrawView fplan
encMessage warning 1
encMessage debug 0
globalNetConnect VSS -type pgpin -pin VSS -inst *
globalNetConnect VDD -type pgpin -pin VDD -inst *
globalNetConnect VDD -type tiehi -inst *
globalNetConnect VSS -type tielo -inst *
setAddRingMode -ring_target default -extend_over_row 0 -ignore_rows 0 -avoid_short 0 -skip_crossing_trunks none -stacked_via_top_layer Metal11 -stacked_via_bottom_layer Metal1 -via_using_exact_crossover_size 1 -orthogonal_only true -skip_via_on_pin { standardcell } -skip_via_on_wire_shape { noshape }
addRing -nets {VDD VSS} -type core_rings -follow core -layer {top Metal11 bottom Metal11 left Metal10 right Metal10} -width {top 4 bottom 4 left 4 right 4} -spacing {top 4 bottom 4 left 4 right 4} -offset {top 1.8 bottom 1.8 left 1.8 right 1.8} -center 1 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid None
setAddStripeMode -stacked_via_top_layer Metal11 -stacked_via_bottom_layer Metal1 -allow_jog { padcore_ring block_ring }
addStripe -nets {VDD VSS} -layer Metal9 -direction vertical -width 4 -spacing 4 -number_of_sets 3 -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit Metal11 -padcore_ring_bottom_layer_limit Metal1 -block_ring_top_layer_limit Metal11 -block_ring_bottom_layer_limit Metal1 -use_wire_group 0 -snap_wire_center_to_grid None
addStripe -nets {VDD VSS} -layer Metal8 -direction horizontal -width 4 -spacing 4 -number_of_sets 3 -start_from bottom -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit Metal11 -padcore_ring_bottom_layer_limit Metal1 -block_ring_top_layer_limit Metal11 -block_ring_bottom_layer_limit Metal1 -use_wire_group 0 -snap_wire_center_to_grid None
createPGPin VSS_p -net VSS -geom Metal10 4 119 8 123
createPGPin VDD_p -net VDD -geom Metal10 12 119 16 123
setSrouteMode -viaConnectToShape { noshape }
sroute -connect { corePin } -layerChangeRange { Metal1(1) Metal11(11) } -blockPinTarget { nearestTarget } -corePinTarget { firstAfterRowEnd } -allowJogging 1 -crossoverViaLayerRange { Metal1(1) Metal11(11) } -nets { VDD VSS } -allowLayerChange 1 -targetViaLayerRange { Metal1(1) Metal11(11) }
setPlaceMode -reset
setPlaceMode -congEffort high -timingDriven 1 -clkGateAware 1 -powerDriven 0 -ignoreScan 1 -reorderScan 1 -ignoreSpare 0 -placeIOPins 1 -moduleAwareSpare 0 -preserveRouting 1 -rmAffectedRouting 0 -checkRoute 0 -swapEEQ 0
setRouteMode -earlyGlobalHonorMsvRouteConstraint false -earlyGlobalRoutePartitionPinGuide true
setEndCapMode -reset
setEndCapMode -boundary_tap false
setUsefulSkewMode -noBoundary false -maxAllowedDelay 1
place_opt_design
checkDesign -all
zoomBox -2298.33700 -1651.54650 9584.46800 8986.10050
add_ndr -width {Metal1 0.12 Metal2 0.14 Metal3 0.14 Metal4 0.14 Metal5 0.14 Metal6 0.14 Metal7 0.14 Metal8 0.14 Metal9 0.14 Metal10 0.4 Metal11 0.4 } -name 2W1S
create_route_type -non_default_rule 2W1S -top_preferred_layer 7 -bottom_preferred_layer 6 -shield_side both_side -shield_net VSS -name route_type_trunk
create_route_type -top_preferred_layer 7 -bottom_preferred_layer 6 -shield_side both_side -shield_net VSS -name route_type_leaf
set_ccopt_property -route_type route_type_trunk -net_type trunk
set_ccopt_property -route_type route_type_leaf -net_type leaf
set_ccopt_property target_skew 1
set_ccopt_property target_max_trans 0.04
ccopt_design
setNanoRouteMode -quiet -drouteFixAntenna true
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -quiet -routeWithSiDriven true
setNanoRouteMode -quiet -drouteEndIteration 5
setNanoRouteMode -quiet -routeTopRoutingLayer 11
setNanoRouteMode -quiet -routeBottomRoutingLayer 1
routeDesign -globalDetail -viaOpt
report_area -detail > reports/postRouting/area.rpt
report_power > reports/postRouting/power.rpt
group_path -name reg2reg -from [all_registers] -to [all_registers]
group_path -name in2reg  -from [all_inputs]    -to [all_registers]
group_path -name reg2out -from [all_registers] -to [all_outputs]
group_path -name in2out  -from [all_inputs]    -to [all_outputs]
setAnalysisMode -checkType setup
report_timing -path_group reg2reg -check_type setup -max_paths 50 > reports/postRouting/setup_reg2reg.rpt
report_timing -path_group in2reg  -check_type setup -max_paths 50 > reports/postRouting/setup_in2reg.rpt
report_timing -path_group reg2out -check_type setup -max_paths 50 > reports/postRouting/setup_reg2out.rpt
report_timing -path_group in2out  -check_type setup -max_paths 50 > reports/postRouting/setup_in2out.rpt
setAnalysisMode -checkType hold
report_timing -path_group reg2reg -check_type hold -max_paths 50 > reports/postRouting/reg2reg_hold.rpt
report_timing -path_group reg2out -check_type hold -max_paths 50 > reports/postRouting/reg2out_hold.rpt
report_timing -path_group in2reg -check_type hold -max_paths 50 > reports/postRouting/in2reg_hold.rpt
report_timing -path_group in2out -check_type hold -max_paths 50 > reports/postRouting/in2out_hold.rpt
saveDesign picorv32_pads_postrouting
