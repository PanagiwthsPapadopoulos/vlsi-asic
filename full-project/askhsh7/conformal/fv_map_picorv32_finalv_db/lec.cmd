REAd IMplementation Information fv/picorv32_wb -golden fv_map -revised picorv32_finalv
SET PARAllel Option -threads 1,4 -norelease_license
SET COmpare Options -threads 1,4
SET MUltiplier Implementation boothrca -both
SET UNDEfined Cell black_box -noascend -both
ADD SEarch Path . /mnt/apps/prebuilt/EDA/cadence/2022-23/RHELx86/GENUS/tools.lnx86/lib/tech -library\
   -both
REAd LIbrary -liberty -both /mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/timing/fast_vdd1v2_basicCells.lib
REAd DEsign -verilog95 -golden -lastmod -noelab fv/picorv32_wb/fv_map.v.gz
ELAborate DEsign -golden -root picorv32_wb
REAd DEsign -verilog95 -revised -lastmod -noelab picorv32_final.v
ELAborate DEsign -revised -root picorv32_wb
REPort DEsign Data
REPort BLack Box
SET FLatten Model -seq_constant
SET FLatten Model -seq_constant_x_to 0
SET FLatten Model -nodff_to_dlat_zero
SET FLatten Model -nodff_to_dlat_feedback
SET FLatten Model -hier_seq_merge
CHEck VErification Information
SET ANalyze Option -auto -report_map
SET SYstem Mode lec
REPort UNmapped Points -summary
REPort UNmapped Points -notmapped
ADD COmpared Points -all
COMpare
REPort COmpare Data -class nonequivalent -class abort -class notcompared
REPort VErification -verbose
REPort STatistics
WRIte COmpared Points noneq.compared_points.picorv32_wb.fv_map.picorv32_finalv.tcl -class noneq -tclmode -replace
ANAlyze NOnequivalent -source_diagnosis
REPort NOnequivalent Analysis
REPort TEst Vector -noneq
REPort VErification
WRIte VErification Information
REPort VErification Information
REPort IMplementation Information
RESET
SET MApping Method -sensitive
SET VErification Information rtl_fv_map_db
REAd IMplementation Information fv/picorv32_wb -revised fv_map
SET PARAllel Option -threads 1,4 -norelease_license
SET COmpare Options -threads 1,4
SET MUltiplier Implementation boothrca -both
SET UNDEfined Cell black_box -noascend -both
ADD SEarch Path . /mnt/apps/prebuilt/EDA/cadence/2022-23/RHELx86/GENUS/tools.lnx86/lib/tech -library\
   -both
REAd LIbrary -liberty -both /mnt/apps/prebuilt/eda/designkits/GPDK/gsclib045/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/timing/fast_vdd1v2_basicCells.lib
SET UNDRiven Signal 0 -golden
SET NAming Style genus -golden
SET NAming Rule %s[%d] -instance_array -golden
SET NAming Rule %s_reg -register -golden
SET NAming Rule %L.%s %L[%d].%s %s -instance -golden
SET NAming Rule %L.%s %L[%d].%s %s -variable -golden
SET NAming Rule -ungroup_separator _ -golden
SET HDl Options -const_port_extend
SET HDl Options -unsigned_conversion_overflow on
SET HDl Options -v_to_vd on
SET HDl Options -VERILOG_INCLUDE_DIR sep:src
ADD SEarch Path . -design -golden
REAd DEsign -define SYNTHESIS -merge bbox -golden -lastmod -noelab -verilog2k /home/p/ppapadoe/Desktop/vlsi-asic/picorv32.v
ELAborate DEsign -golden -root picorv32_wb -rootonly -rootonly
REAd DEsign -verilog95 -revised -lastmod -noelab fv/picorv32_wb/fv_map.v.gz
ELAborate DEsign -revised -root picorv32_wb
UNIQuify -all -nolib -golden
REPort DEsign Data
REPort BLack Box
SET FLatten Model -seq_constant
SET FLatten Model -seq_constant_x_to 0
SET FLatten Model -nodff_to_dlat_zero
SET FLatten Model -nodff_to_dlat_feedback
SET FLatten Model -hier_seq_merge
SET FLatten Model -balanced_modeling
CHEck VErification Information
SET ANalyze Option -auto -report_map
WRIte HIer_compare Dofile hier_tmp5.lec.do -verbose -noexact_pin_match -constraint -usage -replace -balanced_extraction\
   -input_output_pin_equivalence -prepend_string "report_design_data; report_unmapped_points -summary; report_unmapped_points -notmapped; analyze_datapath -module -verbose; eval analyze_datapath -flowgraph -verbose"
RUN HIer_compare hier_tmp5.lec.do -dynamic_hierarchy
REPort HIer_compare Result -dynamicflattened
REPort VErification -hier -verbose
SET SYstem Mode lec
WRIte COmpared Points noneq.compared_points.picorv32_wb.rtl.fv_map.tcl -class noneq -tclmode -replace
ANAlyze NOnequivalent -source_diagnosis
REPort NOnequivalent Analysis
REPort TEst Vector -noneq
SET SYstem Mode setup
WRIte VErification Information
REPort VErification Information
REPort IMplementation Information
SET SYstem Mode lec
ANAlyze RESults -logfiles rtl_vs_final.lec.log
EXIt -f
