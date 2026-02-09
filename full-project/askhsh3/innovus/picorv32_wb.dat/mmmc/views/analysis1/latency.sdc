set_clock_latency -source -early -max -rise  -0.0628968 [get_ports {wb_clk_i}] -clock clk 
set_clock_latency -source -early -max -fall  -0.0593049 [get_ports {wb_clk_i}] -clock clk 
set_clock_latency -source -late -max -rise  -0.0628968 [get_ports {wb_clk_i}] -clock clk 
set_clock_latency -source -late -max -fall  -0.0593049 [get_ports {wb_clk_i}] -clock clk 
