# 
# Digital VLSI Lab 2022
# Marios Pakas
# Εdited by: Aristotelis Tsekouras
# This python script is used to generate all pads suitable for picorv32, apart from VSS and VDD pads
# 

input_pad_names = ['clk', 'resetn', 'mem_ready', 'pcpi_wr', 'pcpi_wait', 'pcpi_ready']
output_pad_names = ['trap', 'mem_valid', 'mem_instr', 'mem_la_read', 'mem_la_write', 'pcpi_valid', 'trace_valid']


for i in range(len(input_pad_names)):
    print("PADDI pad_" + str(input_pad_names[i]) + "(.PAD(" + str(input_pad_names[i]) + "), .Y(" + str(input_pad_names[i]) + "_w" + "), .VDD(VDD), .VSS(VSS));")

for i in range(len(output_pad_names)):
    print("PADDO pad_" + str(output_pad_names[i]) + "(.PAD(" + str(output_pad_names[i]) + "), .A(" + str(output_pad_names[i]) + "_w" + "), .VDD(VDD), .VSS(VSS));")

input_pad_names_32 = ['mem_rdata', 'pcpi_rd', 'irq']
output_pad_names_32 = ['mem_addr', 'mem_wdata', 'mem_la_addr', 'mem_la_wdata', 'pcpi_insn', 'pcpi_rs1', 'pcpi_rs2', 'eoi']

for i in range(len(input_pad_names_32)):
    for j in range(32):
        print("PADDI pad_" + str(input_pad_names_32[i]) + str(j) + "(.PAD(" + str(input_pad_names_32[i]) + "[" + str(j) + "]), .Y(" + str(input_pad_names_32[i]) + "_w" + "[" + str(j) + "]), .VDD(VDD), .VSS(VSS));")

for i in range(len(output_pad_names_32)):
    for j in range(32):
        print("PADDO pad_" + str(output_pad_names_32[i]) + str(j) + "(.PAD(" + str(output_pad_names_32[i]) + "[" + str(j) + "]), .A(" + str(output_pad_names_32[i]) + "_w" + "[" + str(j) + "]), .VDD(VDD), .VSS(VSS));")

pad_names_4 = ['mem_wstrb', 'mem_la_wstrb']

for i in range(len(pad_names_4)):
    for j in range(4):
        print("PADDO pad_" + str(pad_names_4[i]) + str(j) + "(.PAD(" + str(pad_names_4[i]) + "[" + str(j) + "]), .A(" + str(pad_names_4[i]) + "_w" + "[" + str(j) + "]), .VDD(VDD), .VSS(VSS));")

pad_names_36 = ['trace_data']

for i in range(len(pad_names_36)):
    for j in range(36):
        print("PADDO pad_" + str(pad_names_36[i]) + str(j) + "(.PAD(" + str(pad_names_36[i]) + "[" + str(j) + "]), .A(" + str(pad_names_36[i]) + "_w" + "[" + str(j) + "]), .VDD(VDD), .VSS(VSS));")