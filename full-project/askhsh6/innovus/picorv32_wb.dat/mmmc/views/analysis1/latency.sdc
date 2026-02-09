set_clock_latency -source -early -max -rise  -0.045913 [get_ports {wb_clk_i}] -clock clk 
set_clock_latency -source -early -max -fall  -0.044698 [get_ports {wb_clk_i}] -clock clk 
set_clock_latency -source -late -max -rise  -0.045913 [get_ports {wb_clk_i}] -clock clk 
set_clock_latency -source -late -max -fall  -0.044698 [get_ports {wb_clk_i}] -clock clk 
