################################################################################
# INNOVUS IMPLEMENTATION SCRIPT - TASK 5 (STANDARD FLOW)
# Based on Lab Manual Steps 1-16
################################################################################
# Run source /mnt/apps/prebuilt/eda/cadence-2022-23.bash before executing the file

# ------------------------------------------------------------------------------
# SETUP / INITIALIZATION (Step 8)
# ------------------------------------------------------------------------------
# Assuming init_design has been run or MMMC loaded via GUI.
# If not, uncomment and edit the following:
# source innovus_setup.tcl
# init_design


# ------------------------------------------------------------------------------
# STEP 9: FLOORPLANNING
# ------------------------------------------------------------------------------
puts ">> STEP 9: Floorplanning..."

# Die size 250x250um, 20um margins for rings
floorPlan -site CoreSite -d 250.0 250.0 20.0 20.0 20.0 20.0

# ------------------------------------------------------------------------------
# STEP 10: POWER DISTRIBUTION NETWORK (PDN)
# ------------------------------------------------------------------------------
puts ">> STEP 10: Creating Power Grid..."

# Connect Logic High/Low to VDD/VSS
globalNetConnect VSS -type pgpin -pin VSS -inst *
globalNetConnect VDD -type pgpin -pin VDD -inst *

# --- Power Rings (Metal 10 & 11) ---
setAddRingMode -ring_target default -extend_over_row 0 -ignore_rows 0 -avoid_short 0 -skip_crossing_trunks none -stacked_via_top_layer Metal11 -stacked_via_bottom_layer Metal1 -via_using_exact_crossover_size 1 -orthogonal_only true -skip_via_on_pin { standardcell } -skip_via_on_wire_shape { noshape }

addRing -nets {VDD VSS} -type core_rings -follow core -layer {top Metal11 bottom Metal11 left Metal10 right Metal10} -width {top 4 bottom 4 left 4 right 4} -spacing {top 4 bottom 4 left 4 right 4} -offset {top 1.8 bottom 1.8 left 1.8 right 1.8} -center 1 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid None

# --- Power Stripes (M9 Vertical, M8 Horizontal) ---
# Note: Using M8/M9 here forces our CTS to use M6/M7 later.

# Vertical Stripes (Metal 9)
setAddStripeMode -stacked_via_top_layer Metal11 -stacked_via_bottom_layer Metal1 -allow_jog { padcore_ring block_ring }
addStripe -nets {VDD VSS} -layer Metal9 -direction vertical -width 4 -spacing 4 -number_of_sets 3 -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit Metal11 -padcore_ring_bottom_layer_limit Metal1 -block_ring_top_layer_limit Metal11 -block_ring_bottom_layer_limit Metal1 -use_wire_group 0 -snap_wire_center_to_grid None

# Horizontal Stripes (Metal 8)
addStripe -nets {VDD VSS} -layer Metal8 -direction horizontal -width 4 -spacing 4 -number_of_sets 3 -start_from bottom -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit Metal11 -padcore_ring_bottom_layer_limit Metal1 -block_ring_top_layer_limit Metal11 -block_ring_bottom_layer_limit Metal1 -use_wire_group 0 -snap_wire_center_to_grid None

# --- Power Pins (Physical Pins for Rail Analysis) ---
createPGPin VSS_p -net VSS -geom Metal10 4 119 8 123
createPGPin VDD_p -net VDD -geom Metal10 12 119 16 123

# --- Special Route (Sroute) ---
setSrouteMode -viaConnectToShape { noshape }
sroute -connect { corePin } -layerChangeRange { Metal1(1) Metal11(11) } -blockPinTarget { nearestTarget } -corePinTarget { firstAfterRowEnd } -allowJogging 1 -crossoverViaLayerRange { Metal1(1) Metal11(11) } -nets { VDD VSS } -allowLayerChange 1 -targetViaLayerRange { Metal1(1) Metal11(11) }

# ------------------------------------------------------------------------------
# STEP 11: PLACEMENT
# ------------------------------------------------------------------------------
puts ">> STEP 11: Placement..."

# Setup Optimization Mode (High Timing, No Power)
setPlaceMode -reset
setPlaceMode -congEffort high -timingDriven 1 -clkGateAware 1 -powerDriven 0 -ignoreScan 1 -reorderScan 1 -ignoreSpare 0 -placeIOPins 1 -moduleAwareSpare 0 -preserveRouting 1 -rmAffectedRouting 0 -checkRoute 0 -swapEEQ 0

setRouteMode -earlyGlobalHonorMsvRouteConstraint false -earlyGlobalRoutePartitionPinGuide true
setEndCapMode -reset
setEndCapMode -boundary_tap false
setUsefulSkewMode -noBoundary false -maxAllowedDelay 1

# Run Placement
place_opt_design

# Reports (Step 11)
exec mkdir -p reports/preCTS

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


# ------------------------------------------------------------------------------
# STEP 14: CLOCK TREE SYNTHESIS (CTS)
# ------------------------------------------------------------------------------
puts ">> STEP 14: Clock Tree Synthesis..."

# Define NDR (Double Width, Default Spacing)
add_ndr -width {Metal1 0.12 Metal2 0.14 Metal3 0.14 Metal4 0.14 Metal5 0.14 Metal6 0.14 Metal7 0.14 Metal8 0.14 Metal9 0.14 Metal10 0.4 Metal11 0.4 } -name 2W1S


# Power Grid Min Layer = Metal 8 (Horizontal Stripes).
# Rule: CTS Max Layer = Power Min - 1 = Metal 7.
# Range = 2 Layers -> CTS Min = Metal 6.
# -------------------------
create_route_type -non_default_rule 2W1S -top_preferred_layer 7 -bottom_preferred_layer 6 -shield_side both_side -shield_net VSS -name route_type_trunk
create_route_type -top_preferred_layer 7 -bottom_preferred_layer 6 -shield_side both_side -shield_net VSS -name route_type_leaf

# Apply Route Types
set_ccopt_property -route_type route_type_trunk -net_type trunk
set_ccopt_property -route_type route_type_leaf -net_type leaf

# Constraints: 1ns Skew, 1% Transition (0.04ns)
set_ccopt_property target_skew 1
set_ccopt_property target_max_trans 0.04

# Run CTS
ccopt_design

# Reports (Step 14)
exec mkdir -p reports/postCTS
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


# ------------------------------------------------------------------------------
# STEP 15: ROUTING
# ------------------------------------------------------------------------------
puts ">> STEP 15: NanoRoute..."

# Routing Setup
setNanoRouteMode -quiet -drouteFixAntenna true
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -quiet -routeWithSiDriven true
setNanoRouteMode -quiet -drouteEndIteration 5
setNanoRouteMode -quiet -routeTopRoutingLayer 11
setNanoRouteMode -quiet -routeBottomRoutingLayer 1

routeDesign -globalDetail -viaOpt

# Reports (Step 15)
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
 ------------------------------------------------------------------------------
# STEP 16: VERIFICATION 
# ------------------------------------------------------------------------------

# 1. DRC Check
verify_drc -report reports/picorv32.drc.rpt

# 2. Connectivity Check
verifyConnectivity -type all -error 1000 -warning 50

puts ">> FLOW COMPLETE."
