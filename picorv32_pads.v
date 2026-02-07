// Αρχείο: picorv32_pads.v
// Περιγραφή: Top-level wrapper με Pads για την Άσκηση 8

module picorv32_pads (
    // --- ΕΞΩΤΕΡΙΚΑ PINS (PADS) ---
    // Αυτά βλέπει ο έξω κόσμος
    input clk, resetn, mem_ready,
    input pcpi_wr, pcpi_wait, pcpi_ready,
    input [31:0] mem_rdata, pcpi_rd, irq,

    output trap, mem_valid, mem_instr, 
    output mem_la_read, mem_la_write, 
    output pcpi_valid, trace_valid,
    
    output [31:0] mem_addr, mem_wdata, 
    output [31:0] mem_la_addr, mem_la_wdata, 
    output [31:0] pcpi_insn, pcpi_rs1, pcpi_rs2, eoi,
    
    output [3:0] mem_wstrb, mem_la_wstrb,
    output [35:0] trace_data,

    // Power & Ground Pins (για τα Pads)
    inout VDD, VSS
);

    // --- ΕΣΩΤΕΡΙΚΑ ΣΗΜΑΤΑ (WIRES) ---
    // Αυτά συνδέουν τα Pads με τον Core
    wire clk_w, resetn_w, mem_ready_w;
    wire pcpi_wr_w, pcpi_wait_w, pcpi_ready_w;
    wire [31:0] mem_rdata_w, pcpi_rd_w, irq_w;

    wire trap_w, mem_valid_w, mem_instr_w;
    wire mem_la_read_w, mem_la_write_w;
    wire pcpi_valid_w, trace_valid_w;
    
    wire [31:0] mem_addr_w, mem_wdata_w;
    wire [31:0] mem_la_addr_w, mem_la_wdata_w;
    wire [31:0] pcpi_insn_w, pcpi_rs1_w, pcpi_rs2_w, eoi_w;
    
    wire [3:0] mem_wstrb_w, mem_la_wstrb_w;
    wire [35:0] trace_data_w;

    // =========================================================================
    // 1. PAD INSTANCES (Από το Python Script)
    // =========================================================================
    
    // -- Inputs --
    PADDI pad_clk(.PAD(clk), .Y(clk_w), .VDD(VDD), .VSS(VSS));
    PADDI pad_resetn(.PAD(resetn), .Y(resetn_w), .VDD(VDD), .VSS(VSS));
    PADDI pad_mem_ready(.PAD(mem_ready), .Y(mem_ready_w), .VDD(VDD), .VSS(VSS));
    PADDI pad_pcpi_wr(.PAD(pcpi_wr), .Y(pcpi_wr_w), .VDD(VDD), .VSS(VSS));
    PADDI pad_pcpi_wait(.PAD(pcpi_wait), .Y(pcpi_wait_w), .VDD(VDD), .VSS(VSS));
    PADDI pad_pcpi_ready(.PAD(pcpi_ready), .Y(pcpi_ready_w), .VDD(VDD), .VSS(VSS));
    
    // -- Outputs --
    PADDO pad_trap(.PAD(trap), .A(trap_w), .VDD(VDD), .VSS(VSS));
    PADDO pad_mem_valid(.PAD(mem_valid), .A(mem_valid_w), .VDD(VDD), .VSS(VSS));
    PADDO pad_mem_instr(.PAD(mem_instr), .A(mem_instr_w), .VDD(VDD), .VSS(VSS));
    PADDO pad_mem_la_read(.PAD(mem_la_read), .A(mem_la_read_w), .VDD(VDD), .VSS(VSS));
    PADDO pad_mem_la_write(.PAD(mem_la_write), .A(mem_la_write_w), .VDD(VDD), .VSS(VSS));
    PADDO pad_pcpi_valid(.PAD(pcpi_valid), .A(pcpi_valid_w), .VDD(VDD), .VSS(VSS));
    PADDO pad_trace_valid(.PAD(trace_valid), .A(trace_valid_w), .VDD(VDD), .VSS(VSS));

    // -- Buses (Loops from Python expanded manually for correct Verilog syntax) --
    // Σημείωση: Εδώ βάζω genvars για συντομία στον κώδικα, 
    // αλλά το Innovus τα καταλαβαίνει κανονικά.

    genvar i;
    generate
        // mem_rdata (Input)
        for (i=0; i<32; i=i+1) begin : gen_mem_rdata
            PADDI p (.PAD(mem_rdata[i]), .Y(mem_rdata_w[i]), .VDD(VDD), .VSS(VSS));
        end
        // pcpi_rd (Input)
        for (i=0; i<32; i=i+1) begin : gen_pcpi_rd
            PADDI p (.PAD(pcpi_rd[i]), .Y(pcpi_rd_w[i]), .VDD(VDD), .VSS(VSS));
        end
        // irq (Input)
        for (i=0; i<32; i=i+1) begin : gen_irq
            PADDI p (.PAD(irq[i]), .Y(irq_w[i]), .VDD(VDD), .VSS(VSS));
        end

        // mem_addr (Output)
        for (i=0; i<32; i=i+1) begin : gen_mem_addr
            PADDO p (.PAD(mem_addr[i]), .A(mem_addr_w[i]), .VDD(VDD), .VSS(VSS));
        end
        // mem_wdata (Output)
        for (i=0; i<32; i=i+1) begin : gen_mem_wdata
            PADDO p (.PAD(mem_wdata[i]), .A(mem_wdata_w[i]), .VDD(VDD), .VSS(VSS));
        end
        // mem_la_addr (Output)
        for (i=0; i<32; i=i+1) begin : gen_mem_la_addr
            PADDO p (.PAD(mem_la_addr[i]), .A(mem_la_addr_w[i]), .VDD(VDD), .VSS(VSS));
        end
        // mem_la_wdata (Output)
        for (i=0; i<32; i=i+1) begin : gen_mem_la_wdata
            PADDO p (.PAD(mem_la_wdata[i]), .A(mem_la_wdata_w[i]), .VDD(VDD), .VSS(VSS));
        end
        // pcpi_insn (Output)
        for (i=0; i<32; i=i+1) begin : gen_pcpi_insn
            PADDO p (.PAD(pcpi_insn[i]), .A(pcpi_insn_w[i]), .VDD(VDD), .VSS(VSS));
        end
        // pcpi_rs1 (Output)
        for (i=0; i<32; i=i+1) begin : gen_pcpi_rs1
            PADDO p (.PAD(pcpi_rs1[i]), .A(pcpi_rs1_w[i]), .VDD(VDD), .VSS(VSS));
        end
        // pcpi_rs2 (Output)
        for (i=0; i<32; i=i+1) begin : gen_pcpi_rs2
            PADDO p (.PAD(pcpi_rs2[i]), .A(pcpi_rs2_w[i]), .VDD(VDD), .VSS(VSS));
        end
        // eoi (Output)
        for (i=0; i<32; i=i+1) begin : gen_eoi
            PADDO p (.PAD(eoi[i]), .A(eoi_w[i]), .VDD(VDD), .VSS(VSS));
        end

        // mem_wstrb (Output 4-bit)
        for (i=0; i<4; i=i+1) begin : gen_mem_wstrb
            PADDO p (.PAD(mem_wstrb[i]), .A(mem_wstrb_w[i]), .VDD(VDD), .VSS(VSS));
        end
        // mem_la_wstrb (Output 4-bit)
        for (i=0; i<4; i=i+1) begin : gen_mem_la_wstrb
            PADDO p (.PAD(mem_la_wstrb[i]), .A(mem_la_wstrb_w[i]), .VDD(VDD), .VSS(VSS));
        end
        
        // trace_data (Output 36-bit)
        for (i=0; i<36; i=i+1) begin : gen_trace_data
            PADDO p (.PAD(trace_data[i]), .A(trace_data_w[i]), .VDD(VDD), .VSS(VSS));
        end
    endgenerate

    // =========================================================================
    // 2. POWER & CORNER PADS (Manual Addition)
    // =========================================================================
    
    // Corners
    padIORINGCORNER corner_ll (.VDD(VDD), .VSS(VSS)); // Bottom-Left
    padIORINGCORNER corner_lr (.VDD(VDD), .VSS(VSS)); // Bottom-Right
    padIORINGCORNER corner_ul (.VDD(VDD), .VSS(VSS)); // Top-Left
    padIORINGCORNER corner_ur (.VDD(VDD), .VSS(VSS)); // Top-Right

    // Power Supplies (Μπορείς να προσθέσεις περισσότερα αν χρειαστεί)
    PADVDD pad_vdd_main (.VDD(VDD), .VSS(VSS));
    PADVSS pad_vss_main (.VDD(VDD), .VSS(VSS));


    // =========================================================================
    // 3. CORE INSTANTIATION (picorv32_wb)
    // =========================================================================
    
    picorv32_wb core (
        // WISHBONE INTERFACE MAPPING
        .wb_clk_i   (clk_w),
        .wb_rst_i   (resetn_w),
        
        .wbm_adr_o  (mem_addr_w),    // Address mapped to mem_addr
        .wbm_dat_o  (mem_wdata_w),   // Data Out mapped to mem_wdata
        .wbm_dat_i  (mem_rdata_w),   // Data In mapped to mem_rdata
        .wbm_sel_o  (mem_wstrb_w),   // Select mapped to mem_wstrb
        .wbm_cyc_o  (mem_valid_w),   // Cycle Valid mapped to mem_valid
        .wbm_ack_i  (mem_ready_w),   // Acknowledge mapped to mem_ready
        
        // Σήματα που δεν ταιριάζουν ακριβώς ή είναι PCPI/Trace
        .wbm_stb_o  (),              // Αν δεν έχει αντίστοιχο pad, το αφήνουμε (ή το συνδέουμε στο mem_instr αν ταιριάζει)
        .wbm_we_o   (),              // Write Enable (το mem_la_write είναι διαφορετικό)

        // Native/PCPI Interface
        .trap       (trap_w),
        .mem_instr  (mem_instr_w),
        
        .mem_la_read (mem_la_read_w),
        .mem_la_write(mem_la_write_w),
        .mem_la_addr (mem_la_addr_w),
        .mem_la_wdata(mem_la_wdata_w),
        .mem_la_wstrb(mem_la_wstrb_w),

        .pcpi_valid (pcpi_valid_w),
        .pcpi_insn  (pcpi_insn_w),
        .pcpi_rs1   (pcpi_rs1_w),
        .pcpi_rs2   (pcpi_rs2_w),
        .pcpi_wr    (pcpi_wr_w),
        .pcpi_rd    (pcpi_rd_w),
        .pcpi_wait  (pcpi_wait_w),
        .pcpi_ready (pcpi_ready_w),

        .irq        (irq_w),
        .eoi        (eoi_w),
        .trace_valid(trace_valid_w),
        .trace_data (trace_data_w)
    );

endmodule