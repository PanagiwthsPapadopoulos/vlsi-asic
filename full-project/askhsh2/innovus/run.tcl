# Run source /mnt/apps/prebuilt/eda/cadence-2022-23.bash before executing the file

# Initialize Design (Assuming MMMC is already created/imported via GUI or script)

# 1. FLOORPLAN
# ---------------------------------------------------------
# Set floorplan of design with total die at 250x250 μm
# with 20 μm space from I/O for power rings
floorPlan -site CoreSite -d 250.0 250.0 20.0 20.0 20.0 20.0

# 2. POWER RINGS & STRIPES
# ---------------------------------------------------------
# (Cleaned up repetitive set commands for readability)
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0

# Create Power Rings (Metal 10/11)
setAddRingMode -ring_target default -extend_over_row 0 -ignore_rows 0 -avoid_short 0 -skip_crossing_trunks none -stacked_via_top_layer Metal11 -stacked_via_bottom_layer Metal1 -via_using_exact_crossover_size 1 -orthogonal_only true -skip_via_on_pin { standardcell } -skip_via_on_wire_shape { noshape }
addRing -nets {VDD VSS} -type core_rings -follow core -layer {top Metal11 bottom Metal11 left Metal10 right Metal10} -width {top 4 bottom 4 left 4 right 4} -spacing {top 4 bottom 4 left 4 right 4} -offset {top 1.8 bottom 1.8 left 1.8 right 1.8} -center 1 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid None

# Create Vertical Power Stripes (Metal 9)
setAddStripeMode -ignore_block_check false -break_at none -route_over_rows_only false -rows_without_stripes_only false -extend_to_closest_target none -stop_at_last_wire_for_area false -partial_set_thru_domain false -ignore_nondefault_domains false -trim_antenna_back_to_shape none -spacing_type edge_to_edge -spacing_from_block 0 -stripe_min_length stripe_width -stacked_via_top_layer Metal11 -stacked_via_bottom_layer Metal3 -via_using_exact_crossover_size false -split_vias false -orthogonal_only true -allow_jog { padcore_ring block_ring } -skip_via_on_pin { standardcell } -skip_via_on_wire_shape { noshape }
addStripe -nets {VDD VSS} -layer Metal9 -direction vertical -width 4 -spacing 4 -number_of_sets 3 -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit Metal11 -padcore_ring_bottom_layer_limit Metal1 -block_ring_top_layer_limit Metal11 -block_ring_bottom_layer_limit Metal1 -use_wire_group 0 -snap_wire_center_to_grid None

# Create Horizontal Power Stripes (Metal 8)
setAddStripeMode -ignore_block_check false -break_at none -route_over_rows_only false -rows_without_stripes_only false -extend_to_closest_target none -stop_at_last_wire_for_area false -partial_set_thru_domain false -ignore_nondefault_domains false -trim_antenna_back_to_shape none -spacing_type edge_to_edge -spacing_from_block 0 -stripe_min_length stripe_width -stacked_via_top_layer Metal11 -stacked_via_bottom_layer Metal1 -via_using_exact_crossover_size false -split_vias false -orthogonal_only true -allow_jog { padcore_ring block_ring } -skip_via_on_pin { standardcell } -skip_via_on_wire_shape { noshape }
addStripe -nets {VDD VSS} -layer Metal8 -direction horizontal -width 4 -spacing 4 -number_of_sets 3 -start_from bottom -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit Metal11 -padcore_ring_bottom_layer_limit Metal1 -block_ring_top_layer_limit Metal11 -block_ring_bottom_layer_limit Metal1 -use_wire_group 0 -snap_wire_center_to_grid None

# Connect Pins and SRoute
globalNetConnect VSS -type pgpin -pin VSS -inst *
globalNetConnect VDD -type pgpin -pin VDD -inst *

createPGPin VSS_p -net VSS -geom Metal10 4 119 8 123
createPGPin VDD_p -net VDD -geom Metal10 12 119 16 123

setSrouteMode -viaConnectToShape { noshape }
sroute -connect { corePin } -layerChangeRange { Metal1(1) Metal11(11) } -blockPinTarget { nearestTarget } -corePinTarget { firstAfterRowEnd } -allowJogging 1 -crossoverViaLayerRange { Metal1(1) Metal11(11) } -nets { VDD VSS } -allowLayerChange 1 -targetViaLayerRange { Metal1(1) Metal11(11) }


# 3. PLACEMENT (POWER DRIVEN)
# ---------------------------------------------------------
setPlaceMode -reset

# ### TASK 2 CHANGE: ENABLE POWER DRIVEN PLACEMENT ###
# Changed -powerDriven from 0 to 1
setPlaceMode -congEffort high -timingDriven 1 -clkGateAware 1 -powerDriven 1 -ignoreScan 1 -reorderScan 1 -ignoreSpare 0 -placeIOPins 1 -moduleAwareSpare 0 -preserveRouting 1 -rmAffectedRouting 0 -checkRoute 0 -swapEEQ 0

setRouteMode -earlyGlobalHonorMsvRouteConstraint false -earlyGlobalRoutePartitionPinGuide true
setEndCapMode -reset
setEndCapMode -boundary_tap false
setUsefulSkewMode -noBoundary false -maxAllowedDelay 1

#===============================================================================
# TASK 2
# ==============================================================================
# 1. Set Power Effort to High (matches Genus 'design_power_effort high')
# 2. Set Ratio to 0.0 to target DYNAMIC power (matches Genus 'opt_leakage_to_dynamic_ratio 0.0')
setOptMode -powerEffort high -leakageToDynamicRatio 0.0
# ==============================================================================

place_opt_design


# 4. PRE-CTS REPORTS
# ---------------------------------------------------------
# ### TASK 2 CHANGE: Fixed directory structure ###
exec mkdir -p reports
exec mkdir -p reports/preCTS
exec mkdir -p reports/postCTS
exec mkdir -p reports/postRouting

report_area -detail > reports/preCTS/area.rpt
report_power > reports/preCTS/power.rpt

group_path -name reg2reg -from [all_registers -clock_pins] -to [all_registers -data_pins]
group_path -name in2reg  -from [all_inputs]                 -to [all_registers -data_pins]
group_path -name reg2out -from [all_registers -clock_pins]  -to [all_outputs]
group_path -name in2out  -from [all_inputs]                 -to [all_outputs]

report_timing -path_group reg2reg -check_type setup -max_paths 50 > reports/preCTS/setup_reg2reg.rpt
report_timing -path_group in2reg  -check_type setup -max_paths 50 > reports/preCTS/setup_in2reg.rpt
report_timing -path_group reg2out -check_type setup -max_paths 50 > reports/preCTS/setup_reg2out.rpt
report_timing -path_group in2out  -check_type setup -max_paths 50 > reports/preCTS/setup_in2out.rpt


# 5. CLOCK TREE SYNTHESIS (CTS)
# ---------------------------------------------------------

# Creation of 2W1S non default rule (NDR) - Double Width, Default Spacing
add_ndr -width {Metal1 0.12 Metal2 0.14 Metal3 0.14 Metal4 0.14 Metal5 0.14 Metal6 0.14 Metal7 0.14 Metal8 0.14 Metal9 0.14 Metal10 0.4 Metal11 0.4 } -name 2W1S

# ### TASK 2 CHANGE: ADJUST CTS LAYERS ###
# Manual Step 14: "Max metal level immediately lower than the min level of power grid".
# Your Power Grid uses Metal8 (Stripes) to Metal11 (Rings). Min Power Layer = 8.
# Therefore, Clock Top Layer must be 7.
# Manual Step 14: "Range contains two metal layers". So M6 and M7.
# Changed top_preferred_layer from 9 to 7. Changed bottom to 6.

create_route_type -non_default_rule 2W1S -top_preferred_layer 7 -bottom_preferred_layer 6 -shield_side both_side -shield_net VSS -name route_type_trunk
create_route_type -top_preferred_layer 7 -bottom_preferred_layer 6 -shield_side both_side -shield_net VSS -name route_type_leaf

set_ccopt_property -route_type route_type_trunk -net_type trunk
set_ccopt_property -route_type route_type_leaf -net_type leaf

# Set target skew and target max trans
set_ccopt_property target_skew 1

# ### TASK 2 CHANGE: MAX TRANSITION ###
# Manual Step 14: "Max transition 1% of clock period".
# Freq = 250 MHz -> Period = 4 ns. 1% of 4 ns = 0.04 ns.
# Changed from 0.045 to 0.04.
set_ccopt_property target_max_trans 0.04

# Create clock
ccopt_design


# 6. POST-CTS REPORTS
# ---------------------------------------------------------
report_area -detail > reports/postCTS/area.rpt
report_power > reports/postCTS/power.rpt

report_timing -path_group reg2reg -check_type setup -max_paths 50 > reports/postCTS/setup_reg2reg.rpt
report_timing -path_group in2reg  -check_type setup -max_paths 50 > reports/postCTS/setup_in2reg.rpt
report_timing -path_group reg2out -check_type setup -max_paths 50 > reports/postCTS/setup_reg2out.rpt
report_timing -path_group in2out  -check_type setup -max_paths 50 > reports/postCTS/setup_in2out.rpt

setAnalysisMode -checkType hold

report_timing -path_group reg2reg -check_type hold -max_paths 50 > reports/postCTS/reg2reg_hold.rpt
report_timing -path_group reg2out -check_type hold -max_paths 50 > reports/postCTS/reg2out_hold.rpt
report_timing -path_group in2reg -check_type hold -max_paths 50 > reports/postCTS/in2reg_hold.rpt
report_timing -path_group in2out -check_type hold -max_paths 50 > reports/postCTS/in2out_hold.rpt


# 7. ROUTING
# ---------------------------------------------------------
setRouteMode -earlyGlobalHonorMsvRouteConstraint false -earlyGlobalRoutePartitionPinGuide true
setEndCapMode -reset
setEndCapMode -boundary_tap false
setNanoRouteMode -quiet -drouteFixAntenna true
setUsefulSkewMode -noBoundary false -maxAllowedDelay 1
setNanoRouteMode -quiet -routeTopRoutingLayer 11
setNanoRouteMode -quiet -routeBottomRoutingLayer 1
setNanoRouteMode -quiet -drouteEndIteration 1
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -quiet -routeWithSiDriven true

# ### TASK 2 CHANGE: OPTIMIZATION MODE ###
# Add power optimization effort for post-route
setOptMode -powerEffort high -leakageToDynamicRatio 0.0

routeDesign -globalDetail -viaOpt

# 8. POST-ROUTING REPORTS
# ---------------------------------------------------------
report_area -detail > reports/postRouting/area.rpt
report_power > reports/postRouting/power.rpt

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

# Final step: DRC Check (Manual Step 16)
verify_drc
