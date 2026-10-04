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


    axi4_lite_fault_injection #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) fault_injection (

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


    
    // TEST VARIABLE
   

        // ---- extra test bookkeeping ----
    integer ext_pass = 0;
    integer ext_fail = 0;
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
        master.read (32'h0000_0000, read_data);
        `CHK(32'h11BB_33DD, read_data, "INVALID WRITE 10000000")

        master.write(32'h0000_0040, 32'hDEAD_BEEF, 4'b1111);
        master.read (32'h0000_0000, read_data);
        `CHK(32'h11BB_33DD, read_data, "INVALID WRITE 00000040")

        master.read (32'h1000_0000, read_data);
        `CHK(32'h0000_0000, read_data, "INVALID READ data zero")

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

endmodule