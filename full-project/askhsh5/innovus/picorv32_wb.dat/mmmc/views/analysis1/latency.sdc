set_clock_latency -source -early -max -rise  -0.0675579 [get_ports {wb_clk_i}] -clock clk 
set_clock_latency -source -early -max -fall  -0.0609525 [get_ports {wb_clk_i}] -clock clk 
set_clock_latency -source -late -max -rise  -0.0675579 [get_ports {wb_clk_i}] -clock clk 
set_clock_latency -source -late -max -fall  -0.0609525 [get_ports {wb_clk_i}] -clock clk 
