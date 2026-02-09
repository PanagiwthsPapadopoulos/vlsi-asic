# ==============================================================================
# INNOVUS IMPLEMENTATION SCRIPT: ROBUST POWER STRATEGY
# Power Grid: M8 & M9 (Mesh) | Clock Tree: M6 & M7 (Compliance)
# ==============================================================================

puts ">> STARTING ROBUST FLOW..."

# ==============================================================================
# STEP 1: INITIALIZATION & SETUP
# ==============================================================================
puts ">> Step 1: Initialization"

set init_mmmc_version 2
set init_gnd_net {VSS}
set init_pwr_net {VDD}
set init_top_cell {picorv32_wb}
set init_verilog {genus_invs_des/genus.v}
set init_mmmc_file {genus_invs_des/genus.mmmc.tcl}
# Ensure these paths are correct for your environment
set init_lef_file {/mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/lef/gsclib045_tech.lef /mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/lef/gsclib045_macro.lef}

init_design

# ==============================================================================
# STEP 2: FLOORPLANNING
# ==============================================================================
puts ">> Step 2: Floorplanning"

# Die Size: 250x250, Margins: 20um (for rings)
floorPlan -site CoreSite -d 250.0 250.0 20.0 20.0 20.0 20.0

# ==============================================================================
# STEP 3: POWER DISTRIBUTION NETWORK (YOUR ROBUST MESH)
# ==============================================================================
puts ">> Step 3: Creating Power Grid (M8/M9 Mesh)..."

# Global Connections
globalNetConnect VSS -type pgpin -pin VSS -inst *
globalNetConnect VDD -type pgpin -pin VDD -inst *
globalNetConnect VDD -type tiehi -instanceBasename *
globalNetConnect VSS -type tielo -instanceBasename *

# --- Power Rings (Metal 10 & 11) ---
setAddRingMode -ring_target default -extend_over_row 0 -ignore_rows 0 -avoid_short 0 -skip_crossing_trunks none -stacked_via_top_layer Metal11 -stacked_via_bottom_layer Metal1 -via_using_exact_crossover_size 1 -orthogonal_only true -skip_via_on_pin { standardcell } -skip_via_on_wire_shape { noshape }

addRing -nets {VDD VSS} -type core_rings -follow core -layer {top Metal11 bottom Metal11 left Metal10 right Metal10} -width {top 4 bottom 4 left 4 right 4} -spacing {top 4 bottom 4 left 4 right 4} -offset {top 1.8 bottom 1.8 left 1.8 right 1.8} -center 1 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid None

# --- Power Stripes (M9 Vertical, M8 Horizontal) ---
# Note: Using M8/M9 here forces CTS to use M6/M7 later.

# Vertical Stripes (Metal 9)
setAddStripeMode -stacked_via_top_layer Metal11 -stacked_via_bottom_layer Metal1 -allow_jog { padcore_ring block_ring }
addStripe -nets {VDD VSS} -layer Metal9 -direction vertical -width 4 -spacing 4 -number_of_sets 3 -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit Metal11 -padcore_ring_bottom_layer_limit Metal1 -block_ring_top_layer_limit Metal11 -block_ring_bottom_layer_limit Metal1 -use_wire_group 0 -snap_wire_center_to_grid None

# Horizontal Stripes (Metal 8)
addStripe -nets {VDD VSS} -layer Metal8 -direction horizontal -width 4 -spacing 4 -number_of_sets 3 -start_from bottom -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit Metal11 -padcore_ring_bottom_layer_limit Metal1 -block_ring_top_layer_limit Metal11 -block_ring_bottom_layer_limit Metal1 -use_wire_group 0 -snap_wire_center_to_grid None

# --- Power Pins ---
createPGPin VSS_p -net VSS -geom Metal10 4 119 8 123
createPGPin VDD_p -net VDD -geom Metal10 12 119 16 123

# --- Special Route (Sroute) ---
setSrouteMode -viaConnectToShape { noshape }
sroute -connect { corePin } -layerChangeRange { Metal1(1) Metal11(11) } -blockPinTarget { nearestTarget } -corePinTarget { firstAfterRowEnd } -allowJogging 1 -crossoverViaLayerRange { Metal1(1) Metal11(11) } -nets { VDD VSS } -allowLayerChange 1 -targetViaLayerRange { Metal1(1) Metal11(11) }

# ==============================================================================
# STEP 11: PLACEMENT
# ==============================================================================
puts ">> STEP 11: Placement..."

setPlaceMode -reset
setPlaceMode -congEffort auto -timingDriven 1 -clkGateAware 1 -powerDriven 0 -ignoreScan 1 -reorderScan 1 -ignoreSpare 0 -placeIOPins 1 -moduleAwareSpare 0 -preserveRouting 1 -rmAffectedRouting 0 -checkRoute 0 -swapEEQ 0

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

group_path -name R2R -from [all_registers -clock_pins] -to [all_registers -data_pins]
group_path -name I2R -from [all_inputs] -to [all_registers -data_pins]
group_path -name R2O -from [all_registers -clock_pins] -to [all_outputs]
group_path -name I2O -from [all_inputs] -to [all_outputs]

timeDesign -preCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix picorv32_wb_preCTS -outDir reports/timingReports

# ==============================================================================
# STEP 13: EARLY GLOBAL ROUTE
# ==============================================================================
puts ">> STEP 13: Early Global Route..."

reportCongestion -hotspot > reports/congestion_all_metals.rpt
reportNetStat > reports/net_stat_all_metals.rpt
report_route -summary > reports/egr_all_metals.rpt

# ==============================================================================
# STEP 14: CLOCK TREE SYNTHESIS (CTS)
# Strategy: Power on M8/M9 -> Clock on M6/M7 (Required by Manual)
# ==============================================================================
puts ">> STEP 14: Clock Tree Synthesis..."

# 1. Define NDR
add_ndr -width {Metal1 0.12 Metal2 0.14 Metal3 0.14 Metal4 0.14 Metal5 0.14 Metal6 0.14 Metal7 0.14 Metal8 0.14 Metal9 0.14 Metal10 0.4 Metal11 0.4 } -name 2W1S

# 2. Define Route Types 
# *** CRITICAL: Must use M6/M7 because your PDN is blocking M8/M9 ***
create_route_type -non_default_rule 2W1S -top_preferred_layer 7 -bottom_preferred_layer 6 -shield_side both_side -shield_net VSS -name route_type_trunk
create_route_type -top_preferred_layer 7 -bottom_preferred_layer 6 -shield_side both_side -shield_net VSS -name route_type_leaf

# 3. Apply Route Types
set_ccopt_property -route_type route_type_trunk -net_type trunk
set_ccopt_property -route_type route_type_leaf -net_type leaf

# 4. Constraints
set_ccopt_property target_skew 1
set_ccopt_property target_max_trans 0.04

# 5. EXECUTION (The Correct Flow)
# This generates the spec file (ignoring Ideal Network) to FIX the "Flat Tree" bug.
create_ccopt_clock_tree_spec -file ccopt.spec
ccopt_design

# Reports (Step 14)
exec mkdir -p reports/postCTS
report_area -detail > reports/postCTS/area.rpt
report_power > reports/postCTS/power.rpt
report_ccopt_clock_trees > reports/postCTS/trees.rpt
report_ccopt_skew_groups > reports/postCTS/skew.rpt

# Post-CTS Analysis
timeDesign -postCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix picorv32_wb_postCTS -outDir reports/timingReports

# ==============================================================================
# STEP 15: ROUTING
# ==============================================================================
puts ">> STEP 15: NanoRoute..."

setNanoRouteMode -quiet -drouteFixAntenna true
setNanoRouteMode -quiet -droutePostRouteSpreadWire 1
setNanoRouteMode -quiet -droutePostRouteWidenWireRule LEFSpecialRouteSpec
setNanoRouteMode -quiet -drouteUseMultiCutViaEffort medium
setNanoRouteMode -quiet -timingEngine {}
setUsefulSkewMode -noBoundary false -maxAllowedDelay 1
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -quiet -routeWithSiDriven true
setNanoRouteMode -quiet -drouteEndIteration 5
setNanoRouteMode -quiet -routeTopRoutingLayer 11
setNanoRouteMode -quiet -routeBottomRoutingLayer 1

routeDesign -globalDetail -viaOpt

# Reports (Step 15)
exec mkdir -p reports/postRoute
report_area -detail > reports/postRoute/area.rpt
report_power > reports/postRoute/power.rpt

# Post-Route Analysis
timeDesign -postRoute -pathReports -drvReports -slackReports -numPaths 50 -prefix picorv32_wb_postRoute -outDir reports/timingReports

# ==============================================================================
# STEP 16: VERIFICATION & SIGNOFF
# ==============================================================================
puts ">> STEP 16: Verification & Metal Fill..."

# 1. DRC Check
verify_drc -report reports/picorv32.drc.rpt

# 2. Connectivity Check
verifyConnectivity -type all -error 1000 -warning 50

# 3. Add Metal Fill (Density > 10%)
setMetalFill -layer { Metal1 Metal2 Metal3 Metal4 Metal5 Metal6 Metal7 Metal8 Metal9 Metal10 Metal11 } -minDensity 10
addMetalFill

# 4. Final DRC Check (Post-Fill)
verify_drc -report reports/picorv32_final.drc.rpt

puts ">> FLOW COMPLETE."
