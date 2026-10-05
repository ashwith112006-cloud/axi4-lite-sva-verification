`timescale 1ns/1ps

module tb_top;

    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;

    //==================================================
    // CLOCK AND RESET
    //==================================================

    logic aclk;
    logic aresetn;


    //==================================================
    // AXI4-LITE SIGNALS
    //==================================================

    // Write Address
    wire [ADDR_WIDTH-1:0]   awaddr;
    wire                    awvalid;
    wire                    awready;

    // Write Data
    wire [DATA_WIDTH-1:0]   wdata;
    wire [DATA_WIDTH/8-1:0] wstrb;
    wire                    wvalid;
    wire                    wready;

    // Write Response
    wire [1:0]              bresp;
    wire                    bvalid;
    wire                    bready;

    // Read Address
    wire [ADDR_WIDTH-1:0]   araddr;
    wire                    arvalid;
    wire                    arready;

    // Read Data
    wire [DATA_WIDTH-1:0]   rdata;
    wire [1:0]              rresp;
    wire                    rvalid;
    wire                    rready;


    // CLOCK GENERATION
    // 100 MHz clock
    

    initial begin

        aclk = 1'b0;

        forever #5 aclk = ~aclk;

    end


    // RESET GENERATION
  

    initial begin

        aresetn = 1'b0;

        repeat (5)
            @(posedge aclk);

        aresetn = 1'b1;

        $display("");
        $display("==============================================");
        $display("RESET RELEASED");
        $display("==============================================");
        $display("");

    end


    // DUT
    

    axi4_lite_slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (

        .aclk          (aclk),
        .aresetn       (aresetn),

        .s_axi_awaddr  (awaddr),
        .s_axi_awvalid (awvalid),
        .s_axi_awready (awready),

        .s_axi_wdata   (wdata),
        .s_axi_wstrb   (wstrb),
        .s_axi_wvalid  (wvalid),
        .s_axi_wready  (wready),

        .s_axi_bresp   (bresp),
        .s_axi_bvalid  (bvalid),
        .s_axi_bready  (bready),

        .s_axi_araddr  (araddr),
        .s_axi_arvalid (arvalid),
        .s_axi_arready (arready),

        .s_axi_rdata   (rdata),
        .s_axi_rresp   (rresp),
        .s_axi_rvalid  (rvalid),
        .s_axi_rready  (rready)

    );


    
    // MASTER / BFM
    

    axi4_lite_master #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) master (

        .aclk       (aclk),
        .aresetn    (aresetn),

        .awaddr     (awaddr),
        .awvalid    (awvalid),
        .awready    (awready),

        .wdata      (wdata),
        .wstrb      (wstrb),
        .wvalid     (wvalid),
        .wready     (wready),

        .bresp      (bresp),
        .bvalid     (bvalid),
        .bready     (bready),

        .araddr     (araddr),
        .arvalid    (arvalid),
        .arready    (arready),

        .rdata      (rdata),
        .rresp      (rresp),
        .rvalid     (rvalid),
        .rready     (rready)

    );


    
    // MONITOR
   

    axi4_lite_monitor #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) monitor (

        .aclk       (aclk),
        .aresetn    (aresetn),

        .awaddr     (awaddr),
        .awvalid    (awvalid),
        .awready    (awready),

        .wdata      (wdata),
        .wstrb      (wstrb),
        .wvalid     (wvalid),
        .wready     (wready),

        .bresp      (bresp),
        .bvalid     (bvalid),
        .bready     (bready),

        .araddr     (araddr),
        .arvalid    (arvalid),
        .arready    (arready),

        .rdata      (rdata),
        .rresp      (rresp),
        .rvalid     (rvalid),
        .rready     (rready)

    );


    // SCOREBOARD
  
    axi4_lite_scoreboard #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) scoreboard (

        .aclk       (aclk),
        .aresetn    (aresetn),

        .awaddr     (awaddr),
        .awvalid    (awvalid),
        .awready    (awready),

        .wdata      (wdata),
        .wstrb      (wstrb),
        .wvalid     (wvalid),
        .wready     (wready),

        .bresp      (bresp),
        .bvalid     (bvalid),
        .bready     (bready),

        .araddr     (araddr),
        .arvalid    (arvalid),
        .arready    (arready),

        .rdata      (rdata),
        .rresp      (rresp),
        .rvalid     (rvalid),
        .rready     (rready)

    );


    // COVERAGE
 

    axi4_lite_coverage #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) coverage (

        .aclk       (aclk),
        .aresetn    (aresetn),

        .awaddr     (awaddr),
        .awvalid    (awvalid),
        .awready    (awready),

        .wdata      (wdata),
        .wstrb      (wstrb),
        .wvalid     (wvalid),
        .wready     (wready),

        .bresp      (bresp),
        .bvalid     (bvalid),
        .bready     (bready),

        .araddr     (araddr),
        .arvalid    (arvalid),
        .arready    (arready),

        .rdata      (rdata),
        .rresp      (rresp),
        .rvalid     (rvalid),
        .rready     (rready)

    );


   
    // FAULT INJECTION MODULE




    
    // TEST VARIABLE
   

        // ---- extra test bookkeeping ----
    integer ext_pass = 0;
    integer ext_fail = 0;
    integer fault_sel = 0;
    integer rseed = 1;
    integer rnd_cnt = 0;
    integer rnd_n = 0;
    integer rnd_sel = 0;
    logic [31:0] rnd_addr;
    logic [31:0] rnd_data;
    logic [3:0]  rnd_strb;
 // Simple xorshift32 random generator (same result in every simulator)
    reg [31:0] rng;
    function automatic [31:0] xorshift(input [31:0] s);
        reg [31:0] x;
        begin
            x = s;
            x = x ^ (x << 13);
            x = x ^ (x >> 17);
            x = x ^ (x << 5);
            xorshift = x;
        end
    endfunction
`define CHK(EXP, ACT, NAME) \
    if ((ACT) === (EXP)) begin \
        $display("[TEST] %s PASS", NAME); \
        ext_pass = ext_pass + 1; \
    end else begin \
        $display("[TEST] %s FAIL EXPECTED=%h ACTUAL=%h", NAME, (EXP), (ACT)); \
        ext_fail = ext_fail + 1; \
    end

    logic [DATA_WIDTH-1:0] read_data;


    // BASIC TEST


    initial begin

        wait(aresetn == 1'b1);

        @(posedge aclk);

        $display("");
        $display("==============================================");
        $display("      AXI4-LITE BASIC TEST START");
        $display("==============================================");
        $display("");


   
        // TEST 1 : REG0
        

        master.write(
            32'h0000_0000,
            32'h1234_5678,
            4'b1111
        );

        master.read(
            32'h0000_0000,
            read_data
        );

        if (read_data === 32'h1234_5678)

            $display("[TEST] REG0 PASS");

        else

            $error(
                "[TEST] REG0 FAIL EXPECTED=%h ACTUAL=%h",
                32'h1234_5678,
                read_data
            );


        // TEST 2 : REG1
    

        master.write(
            32'h0000_0004,
            32'hAABB_CCDD,
            4'b1111
        );

        master.read(
            32'h0000_0004,
            read_data
        );

        if (read_data === 32'hAABB_CCDD)

            $display("[TEST] REG1 PASS");

        else

            $error(
                "[TEST] REG1 FAIL EXPECTED=%h ACTUAL=%h",
                32'hAABB_CCDD,
                read_data
            );


        // TEST 3 : REG2
       

        master.write(
            32'h0000_0008,
            32'hDEAD_BEEF,
            4'b1111
        );

        master.read(
            32'h0000_0008,
            read_data
        );

        if (read_data === 32'hDEAD_BEEF)

            $display("[TEST] REG2 PASS");

        else

            $error(
                "[TEST] REG2 FAIL EXPECTED=%h ACTUAL=%h",
                32'hDEAD_BEEF,
                read_data
            );


       
        // TEST 4 : REG3
       

        master.write(
            32'h0000_000C,
            32'hCAFE_BABE,
            4'b1111
        );

        master.read(
            32'h0000_000C,
            read_data
        );

        if (read_data === 32'hCAFE_BABE)

            $display("[TEST] REG3 PASS");

        else

            $error(
                "[TEST] REG3 FAIL EXPECTED=%h ACTUAL=%h",
                32'hCAFE_BABE,
                read_data
            );


                // ==========================================
        // EXTRA TESTS: coverage closure plus checks
        // ==========================================
        master.write(32'h0000_0000, 32'hFFFF_FFFF, 4'b1111);
        master.write(32'h0000_0000, 32'h1122_3344, 4'b0001);
        `CHK(2'b00, master.last_bresp, "WRITE BRESP=OKAY")
        master.read (32'h0000_0000, read_data);
        `CHK(32'hFFFF_FF44, read_data, "WSTRB 0001")

        master.write(32'h0000_0000, 32'h1122_3344, 4'b0010);
        master.read (32'h0000_0000, read_data);
        `CHK(32'hFFFF_3344, read_data, "WSTRB 0010")

        master.write(32'h0000_0000, 32'h1122_3344, 4'b0100);
        master.read (32'h0000_0000, read_data);
        `CHK(32'hFF22_3344, read_data, "WSTRB 0100")

        master.write(32'h0000_0000, 32'h1122_3344, 4'b1000);
        master.read (32'h0000_0000, read_data);
        `CHK(32'h1122_3344, read_data, "WSTRB 1000")

        master.write(32'h0000_0000, 32'hAABB_CCDD, 4'b0101);
        master.read (32'h0000_0000, read_data);
        `CHK(32'h11BB_33DD, read_data, "WSTRB 0101 partial")

        master.write(32'h0000_0000, 32'h0000_0000, 4'b0000);
        master.read (32'h0000_0000, read_data);
        `CHK(32'h11BB_33DD, read_data, "WSTRB 0000 no change")

        master.write(32'h1000_0000, 32'hDEAD_BEEF, 4'b1111);
        `CHK(2'b10, master.last_bresp, "INVALID WRITE 10000000 BRESP=SLVERR")

        master.read (32'h0000_0000, read_data);
        `CHK(32'h11BB_33DD, read_data, "INVALID WRITE 10000000")

        master.write(32'h0000_0040, 32'hDEAD_BEEF, 4'b1111);
        `CHK(2'b10, master.last_bresp, "INVALID WRITE 00000040 BRESP=SLVERR")
        master.read (32'h0000_0000, read_data);
        `CHK(32'h11BB_33DD, read_data, "INVALID WRITE 00000040")
        master.read (32'h1000_0000, read_data);
        `CHK(2'b10, master.last_rresp, "INVALID READ RRESP=SLVERR")
        `CHK(32'h0000_0000, read_data, "INVALID READ data zero")

// --- backpressure: master delays BREADY and RREADY (creates stalls)
        master.b_delay = 3;
        master.r_delay = 3;
        master.write(32'h0000_0004, 32'hA5A5_5A5A, 4'b1111);
        `CHK(2'b00, master.last_bresp, "BACKPRESSURE WRITE BRESP=OKAY")
        master.read (32'h0000_0004, read_data);
        `CHK(32'hA5A5_5A5A, read_data, "BACKPRESSURE READ DATA")
        master.b_delay = 0;
        master.r_delay = 0;

        // --- AWREADY must stay low while B response is pending (kills m001)
        master.b_delay = 8;
        fork
            master.write(32'h0000_0004, 32'hA5A5_5A5A, 4'b1111);
            begin
                wait (dut.s_axi_bvalid === 1'b1);
                repeat (2) @(negedge aclk);
                `CHK(1'b0, dut.s_axi_awready, "AWREADY LOW WHILE B PENDING")
            end
        join
        master.b_delay = 0;

 // --- stall test: slave holds READY low for 4 cycles (exercises A01-A07)
        if (!$value$plusargs("FAULT=%d", fault_sel)) fault_sel = 0;
        dut.ready_delay = 4;
        master.write(32'h0000_0008, 32'h5555_AAAA, 4'b1111);
        `CHK(2'b00, master.last_bresp, "STALL WRITE BRESP=OKAY")
        master.read (32'h0000_0008, read_data);
        `CHK(32'h5555_AAAA, read_data, "STALL READ DATA")
        // --- optional injected fault (only when run with +FAULT=n)
        if (fault_sel != 0) begin
            master.fault_mode = fault_sel;
            if (fault_sel <= 5) master.write(32'h0000_000C, 32'h1234_ABCD, 4'b1111);
            else                master.read (32'h0000_000C, read_data);
            master.fault_mode = 0;
        end
        dut.ready_delay = 0;

 // --- unaligned addresses are invalid (SLVERR, no effect)
        master.write(32'h0000_0001, 32'hBAD0_BAD0, 4'b1111);
        `CHK(2'b10, master.last_bresp, "UNALIGNED WRITE 0x1 BRESP=SLVERR")
        master.read (32'h0000_0000, read_data);
        `CHK(32'h11BB_33DD, read_data, "UNALIGNED WRITE no effect")
        master.read (32'h0000_0002, read_data);
        `CHK(2'b10, master.last_rresp, "UNALIGNED READ 0x2 RRESP=SLVERR")
        `CHK(32'h0000_0000, read_data, "UNALIGNED READ data zero")


// --- constrained-random traffic (run with +SEED=n +RANDN=count)
        if (!$value$plusargs("SEED=%d", rseed)) rseed = 1;
        if (!$value$plusargs("RANDN=%d", rnd_cnt)) rnd_cnt = 0;
        rng = rseed ^ 32'hA5A5_1234;
        for (rnd_n = 0; rnd_n < 8; rnd_n = rnd_n + 1) rng = xorshift(rng);
        for (rnd_n = 0; rnd_n < rnd_cnt; rnd_n = rnd_n + 1) begin
            rng = xorshift(rng); dut.ready_delay = rng[17:16];
            rng = xorshift(rng); master.b_delay  = rng[17:16];
            rng = xorshift(rng); master.r_delay  = rng[17:16];
            rng = xorshift(rng); rnd_sel = rng[18:16];
            case (rnd_sel)
                0: rnd_addr = 32'h0000_0000;
                1: rnd_addr = 32'h0000_0004;
                2: rnd_addr = 32'h0000_0008;
                3: rnd_addr = 32'h0000_000C;
                4: rnd_addr = 32'h0000_0010;
                5: rnd_addr = 32'h0000_0001;
                6: rnd_addr = 32'h1000_0004;
                default: rnd_addr = 32'h0000_0040;
            endcase
            rng = xorshift(rng); rnd_data = rng;
            rng = xorshift(rng); rnd_strb = rng[19:16];
            rng = xorshift(rng);
            if (rng[16]) master.write(rnd_addr, rnd_data, rnd_strb);
            else         master.read (rnd_addr, read_data);
        end
        dut.ready_delay = 0; master.b_delay = 0; master.r_delay = 0;

        $display("[TEST] EXTRA TESTS: %0d passed, %0d failed", ext_pass, ext_fail);

        // END TEST
      

        $display("");
        $display("==============================================");
        $display("      AXI4-LITE BASIC TEST COMPLETE");
        $display("==============================================");
        $display("");

        #50;

        $finish;

    end


   
    // WAVEFORM
  

    initial begin

        $dumpfile("sim/waves/axi4_lite.vcd");

        $dumpvars(0, tb_top);

    end

`ifdef ASSERTIONS
    axi4_lite_sva #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) sva (
        .aclk(aclk), .aresetn(aresetn),
        .awaddr(awaddr), .awvalid(awvalid), .awready(awready),
        .wdata(wdata), .wstrb(wstrb), .wvalid(wvalid), .wready(wready),
        .bresp(bresp), .bvalid(bvalid), .bready(bready),
        .araddr(araddr), .arvalid(arvalid), .arready(arready),
        .rdata(rdata), .rresp(rresp), .rvalid(rvalid), .rready(rready)
    );
`endif
  // Watchdog: stop the simulation if a test hangs (e.g. a missing response)
    initial begin
        #500000;
        $display("[TB] WATCHDOG TIMEOUT: simulation did not finish");
        $finish;
    end
endmodule
