set_clock_latency -source -early -max -rise  -1.42765 [get_ports {wb_clk_i}] -clock clk 
set_clock_latency -source -early -max -fall  -1.59853 [get_ports {wb_clk_i}] -clock clk 
set_clock_latency -source -late -max -rise  -1.42765 [get_ports {wb_clk_i}] -clock clk 
set_clock_latency -source -late -max -fall  -1.59853 [get_ports {wb_clk_i}] -clock clk 
