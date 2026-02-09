# ==============================================================================
# AUTOMATED PHYSICAL DESIGN FLOW: PICORV32
# Phases: Init -> Floorplan -> Power Grid -> Place -> Pre-CTS -> CTS -> Post-CTS
# ==============================================================================

puts ">> STARTING AUTOMATED FLOW..."

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
set init_lef_file {/mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/lef/gsclib045_tech.lef /mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/lef/gsclib045_macro.lef}
init_design

# ==============================================================================
# STEP 2: FLOORPLANNING
# ==============================================================================
puts ">> Step 2: Floorplanning"

# Die Size: 250x250, Margins: 20um (for rings)
floorPlan -site core -d 250 250 20 20 20 20

# ==============================================================================
# STEP 3: POWER DISTRIBUTION NETWORK (PDN)
# Strategy: Rings M10/M11, Stripes M10 (Vertical) -> Leaves M8/M9 free for Clock
# ==============================================================================
puts ">> Step 3: Creating Power Grid"

# 3.1 Global Connections
globalNetConnect VDD -type pgpin -pin VDD -inst *
globalNetConnect VSS -type pgpin -pin VSS -inst *
globalNetConnect VDD -type tiehi -instanceBasename *
globalNetConnect VSS -type tielo -instanceBasename *

# 3.2 Power Rings (M10/M11)
setAddRingMode -ring_target default -extend_over_row 0 -ignore_rows 0 -avoid_short 0 \
               -skip_crossing_trunks none -stacked_via_top_layer Metal11 -stacked_via_bottom_layer Metal1 \
               -via_using_exact_crossover_size 1 -orthogonal_only true \
               -skip_via_on_pin { standardcell } -skip_via_on_wire_shape { noshape }

addRing -nets {VDD VSS} -type core_rings -follow core \
        -layer {top Metal11 bottom Metal11 left Metal10 right Metal10} \
        -width {top 4 bottom 4 left 4 right 4} \
        -spacing {top 4 bottom 4 left 4 right 4} \
        -offset {top 1.8 bottom 1.8 left 1.8 right 1.8} \
        -center 1

# 3.3 Power Stripes (M10 Vertical Only)
setAddStripeMode -stacked_via_top_layer Metal11 -stacked_via_bottom_layer Metal1 \
                 -allow_jog { padcore_ring block_ring } -trim_antenna_back_to_shape none \
                 -spacing_type edge_to_edge -orthogonal_only true

addStripe -nets {VDD VSS} -layer Metal10 -direction vertical \
          -width 4 -spacing 4 -number_of_sets 3 -start_from left \
          -switch_layer_over_obs false -max_same_layer_jog_length 2 \
          -padcore_ring_top_layer_limit Metal11 -padcore_ring_bottom_layer_limit Metal1 \
          -block_ring_top_layer_limit Metal11 -block_ring_bottom_layer_limit Metal1 \
          -use_wire_group 0 -snap_wire_center_to_grid None

# 3.4 Power Pins & SRoute
createPGPin vss -net VSS -geom Metal10 4 110 8 114
createPGPin vdd -net VDD -geom Metal10 12 110 16 114

setSrouteMode -viaConnectToShape { stripe }
sroute -connect { corePin } -layerChangeRange { Metal1(1) Metal10(10) } \
       -blockPinTarget { nearestTarget } -corePinTarget { firstAfterRowEnd } \
       -allowJogging 1 -crossoverViaLayerRange { Metal1(1) Metal10(10) } \
       -nets { VDD VSS } -allowLayerChange 1 -targetViaLayerRange { Metal1(1) Metal10(10) }

# ==============================================================================
# STEP 4: PLACEMENT
# ==============================================================================
puts ">> Step 4: Placement"

setPlaceMode -congEffort auto -timingDriven 1 -clkGateAware 1 -powerDriven 0 \
             -ignoreScan 1 -reorderScan 1 -placeIOPins 1 -preserveRouting 1
place_opt_design

# ==============================================================================
# STEP 5: PRE-CTS REPORTING & ANALYSIS
# ==============================================================================
puts ">> Step 5: Pre-CTS Analysis"

# Path Groups
group_path -name R2R -from [all_registers -clock_pins] -to [all_registers -data_pins]
group_path -name I2R -from [all_inputs] -to [all_registers -data_pins]
group_path -name R2O -from [all_registers -clock_pins] -to [all_outputs]
group_path -name I2O -from [all_inputs] -to [all_outputs]

# Reports
report_area -detail > reports/preCTS/area.rpt
report_power > reports/preCTS/power.rpt
report_timing -path_group R2R -check_type setup -max_paths 50 > reports/preCTS/setup_reg2reg.rpt
timeDesign -preCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix picorv32_wb_preCTS -outDir reports/timingReports

puts ">> Run Rail Analysis..."
# Run Early Power Rail Analysis from UI

# Early Global Route
puts ">> Running Early Global Route Analysis..."
setRouteMode -earlyGlobalMinRouteLayer 1 -earlyGlobalMaxRouteLayer 11
earlyGlobalRoute
reportCongestion -hotspot > reports/early_route_all_metals.rpt

setRouteMode -earlyGlobalMinRouteLayer 5 -earlyGlobalMaxRouteLayer 10 -earlyGlobalHonorMsvRouteConstraint false -earlyGlobalRoutePartitionPinGuide true
earlyGlobalRoute
reportCongestion -hotspot > reports/early_route_middle_metals.rpt

# ==============================================================================
# STEP 6: CLOCK TREE SYNTHESIS (CTS)
# Strategy: Trunk on M8/M9 (Shielded), Leaf on M1-M9
# ==============================================================================
puts ">> Step 6: Clock Tree Synthesis"

# Non-Default Rule (NDR)
add_ndr -width {Metal1 0.12 Metal2 0.16 Metal3 0.16 Metal4 0.16 Metal5 0.16 Metal6 0.16 \
                Metal7 0.16 Metal8 0.16 Metal9 0.16 Metal10 0.44 Metal11 0.44 } -name 01_NDR

# Route Types
create_route_type -top_preferred_layer Metal9 -bottom_preferred_layer Metal8 \
                  -non_default_rule 01_NDR -name clk_tree_trunk -shield_net VSS -shield_side both

create_route_type -top_preferred_layer Metal9 -bottom_preferred_layer Metal1 \
                  -name clk_tree_leaf -shield_net VSS -shield_side both

# Properties
set_ccopt_property route_type clk_tree_trunk -net_type trunk
set_ccopt_property route_type clk_tree_trunk -net_type top
set_ccopt_property route_type clk_tree_leaf -net_type leaf
set_ccopt_property target_skew 1
set_ccopt_property target_max_trans 0.04

# Run CTS
create_ccopt_clock_tree_spec -file ccopt.spec
ccopt_design

# ==============================================================================
# STEP 7: POST-CTS OPTIMIZATION
# ==============================================================================
puts ">> Step 7: Post-CTS Optimization"

# Run Optimization
optDesign -postCTS

# Final Reports
puts ">> Generating Final Reports..."
report_area -detail > reports/postCTS/area.rpt
report_power > reports/postCTS/power.rpt
report_timing -path_group R2R -check_type setup -max_paths 50 > reports/postCTS/setup_R2R.rpt
report_timing -path_group I2R -check_type setup -max_paths 50 > reports/postCTS/setup_I2R.rpt
report_timing -path_group R2O -check_type setup -max_paths 50 > reports/postCTS/setup_R2O.rpt
report_timing -path_group I2O  -check_type setup -max_paths 50 > reports/postCTS/setup_I2O.rpt
setAnalysisMode -checkType hold
report_timing -path_group R2R -check_type hold -max_paths 50 > reports/postCTS/hold_R2R.rpt
report_timing -path_group I2R -check_type hold -max_paths 50 > reports/postCTS/hold_I2R.rpt
report_timing -path_group R2O -check_type hold -max_paths 50 > reports/postCTS/hold_R2O.rpt
report_timing -path_group I2O -check_type hold -max_paths 50 > reports/postCTS/hold_I2O.rpt
report_ccopt_clock_trees > reports/postCTS/trees.rpt
report_ccopt_skew_groups > reports/postCTS/skew.rpt


# ==============================================================================
# STEP 15: ROUTING
# ==============================================================================
puts ">> STEP 8: Routing 

# Copied commands the UI runs
setNanoRouteMode -quiet -droutePostRouteSpreadWire 1
setNanoRouteMode -quiet -droutePostRouteWidenWireRule LEFSpecialRouteSpec
setNanoRouteMode -quiet -drouteUseMultiCutViaEffort medium
setNanoRouteMode -quiet -timingEngine {}
setUsefulSkewMode -noBoundary false -maxAllowedDelay 1
setNanoRouteMode -quiet -routeWithTimingDriven 1
setNanoRouteMode -quiet -routeWithSiDriven 1
setNanoRouteMode -quiet -routeSelectedNetOnly 0
setNanoRouteMode -quiet -routeTopRoutingLayer 11
setNanoRouteMode -quiet -routeBottomRoutingLayer 1
setNanoRouteMode -quiet -drouteEndIteration default
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -quiet -routeWithSiDriven true
routeDesign -globalDetail

exec mkdir -p reports/postRoute
setAnalysisMode -checkType setup
report_timing -path_group R2R -check_type setup -max_paths 50 > reports/postRoute/setup_R2R.rpt
report_timing -path_group I2R -check_type setup -max_paths 50 > reports/postRoute/setup_I2R.rpt
report_timing -path_group R2O -check_type setup -max_paths 50 > reports/postRoute/setup_R2O.rpt
report_timing -path_group I2O -check_type setup -max_paths 50 > reports/postRoute/setup_I2O.rpt

setAnalysisMode -checkType hold
report_timing -path_group R2R -check_type hold -max_paths 50 > reports/postRoute/hold_R2R.rpt
report_timing -path_group I2R -check_type hold -max_paths 50 > reports/postRoute/hold_I2R.rpt
report_timing -path_group R2O -check_type hold -max_paths 50 > reports/postRoute/hold_R2O.rpt
report_timing -path_group I2O -check_type hold -max_paths 50 > reports/postRoute/hold_I2O.rpt

report_area -detail > reports/postRoute/area.rpt
report_power > reports/postRoute/power.rpt

 ------------------------------------------------------------------------------
# STEP 16: VERIFICATION & SIGNOFF
# ------------------------------------------------------------------------------
puts ">> STEP 16: Verification & Metal Fill..."

# 1. DRC Check
verify_drc -report reports/picorv32.drc.rpt

# 2. Connectivity Check
verifyConnectivity -type all -error 1000 -warning 50

# 3. Add Metal Fill (Density > 10%)
setMetalFill -layer { Metal1 Metal2 Metal3 Metal4 Metal5 Metal6 Metal7 Metal8 Metal9 Metal10 Metal11 } -minDensity 10
addMetalFill
