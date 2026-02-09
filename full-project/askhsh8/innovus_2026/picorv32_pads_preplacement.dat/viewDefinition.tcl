if {![namespace exists ::IMEX]} { namespace eval ::IMEX {} }
set ::IMEX::dataVar [file dirname [file normalize [info script]]]
set ::IMEX::libVar ${::IMEX::dataVar}/libs

create_library_set -name timing1\
   -timing\
    [list ${::IMEX::libVar}/mmmc/fast_vdd1v2_basicCells.lib\
    ${::IMEX::libVar}/mmmc/pads_SS_s1vg.lib]
create_op_cond -name op1 -library_file ${::IMEX::libVar}/mmmc/fast_vdd1v2_basicCells.lib -P 1 -V 1.32 -T 0
create_rc_corner -name rc1\
   -preRoute_res 1\
   -postRoute_res 1\
   -preRoute_cap 1\
   -postRoute_cap 1\
   -postRoute_xcap 1\
   -preRoute_clkres 0\
   -preRoute_clkcap 0\
   -postRoute_clkcap 1\
   -postRoute_clkres 1\
   -T 0\
   -qx_tech_file ${::IMEX::libVar}/mmmc/rc1/gpdk045.tch
create_delay_corner -name delay1\
   -library_set timing1\
   -rc_corner rc1
create_constraint_mode -name constraint1\
   -sdc_files\
    [list /dev/null]
create_analysis_view -name analysis1 -constraint_mode constraint1 -delay_corner delay1
set_analysis_view -setup [list analysis1] -hold [list analysis1]
