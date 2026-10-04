module axi4_lite_scoreboard #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input logic                     aclk,
    input logic                     aresetn,

    // Write Address
    input logic [ADDR_WIDTH-1:0]    awaddr,
    input logic                     awvalid,
    input logic                     awready,

    // Write Data
    input logic [DATA_WIDTH-1:0]    wdata,
    input logic [DATA_WIDTH/8-1:0]  wstrb,
    input logic                     wvalid,
    input logic                     wready,

    // Write Response
    input logic [1:0]               bresp,
    input logic                     bvalid,
    input logic                     bready,

    // Read Address
    input logic [ADDR_WIDTH-1:0]    araddr,
    input logic                     arvalid,
    input logic                     arready,

    // Read Data
    input logic [DATA_WIDTH-1:0]    rdata,
    input logic [1:0]               rresp,
    input logic                     rvalid,
    input logic                     rready
);

    // REFERENCE REGISTER MODEL
   

    logic [DATA_WIDTH-1:0] expected_reg0;
    logic [DATA_WIDTH-1:0] expected_reg1;
    logic [DATA_WIDTH-1:0] expected_reg2;
    logic [DATA_WIDTH-1:0] expected_reg3;


    // CAPTURED WRITE INFORMATION
    // AXI AW and W can arrive independently
    

    logic [ADDR_WIDTH-1:0]   expected_awaddr;
    logic [DATA_WIDTH-1:0]   expected_wdata;
    logic [DATA_WIDTH/8-1:0] expected_wstrb;

    logic aw_received;
    logic w_received;


    
    // SCOREBOARD
  

    always @(posedge aclk) begin

        if (!aresetn) begin

            expected_reg0 = '0;
            expected_reg1 = '0;
            expected_reg2 = '0;
            expected_reg3 = '0;

            expected_awaddr = '0;
            expected_wdata  = '0;
            expected_wstrb  = '0;

            aw_received = 1'b0;
            w_received  = 1'b0;

        end

        else begin

            
            // Capture WRITE ADDRESS
          

            if (awvalid && awready) begin

                expected_awaddr = awaddr;
                aw_received = 1'b1;

                $display(
                    "[SCOREBOARD] AW CAPTURED: ADDR=%h",
                    awaddr
                );

            end


           
            // Capture WRITE DATA
         

            if (wvalid && wready) begin

                expected_wdata = wdata;
                expected_wstrb = wstrb;
                w_received = 1'b1;

                $display(
                    "[SCOREBOARD] W CAPTURED: DATA=%h WSTRB=%b",
                    wdata,
                    wstrb
                );

            end


          
            // UPDATE REFERENCE MODEL
            // When both AW and W have arrived
        

            if (aw_received && w_received) begin

                case (expected_awaddr[5:2])

                    4'd0: begin

                        if (expected_wstrb[0])
                            expected_reg0[7:0] =
                                expected_wdata[7:0];

                        if (expected_wstrb[1])
                            expected_reg0[15:8] =
                                expected_wdata[15:8];

                        if (expected_wstrb[2])
                            expected_reg0[23:16] =
                                expected_wdata[23:16];

                        if (expected_wstrb[3])
                            expected_reg0[31:24] =
                                expected_wdata[31:24];

                    end


                    4'd1: begin

                        if (expected_wstrb[0])
                            expected_reg1[7:0] =
                                expected_wdata[7:0];

                        if (expected_wstrb[1])
                            expected_reg1[15:8] =
                                expected_wdata[15:8];

                        if (expected_wstrb[2])
                            expected_reg1[23:16] =
                                expected_wdata[23:16];

                        if (expected_wstrb[3])
                            expected_reg1[31:24] =
                                expected_wdata[31:24];

                    end


                    4'd2: begin

                        if (expected_wstrb[0])
                            expected_reg2[7:0] =
                                expected_wdata[7:0];

                        if (expected_wstrb[1])
                            expected_reg2[15:8] =
                                expected_wdata[15:8];

                        if (expected_wstrb[2])
                            expected_reg2[23:16] =
                                expected_wdata[23:16];

                        if (expected_wstrb[3])
                            expected_reg2[31:24] =
                                expected_wdata[31:24];

                    end


                    4'd3: begin

                        if (expected_wstrb[0])
                            expected_reg3[7:0] =
                                expected_wdata[7:0];

                        if (expected_wstrb[1])
                            expected_reg3[15:8] =
                                expected_wdata[15:8];

                        if (expected_wstrb[2])
                            expected_reg3[23:16] =
                                expected_wdata[23:16];

                        if (expected_wstrb[3])
                            expected_reg3[31:24] =
                                expected_wdata[31:24];

                    end


                    default: begin

                        // Invalid address.
                        // Reference registers are unchanged.

                    end

                endcase


                // Clear captured write
                aw_received = 1'b0;
                w_received  = 1'b0;

            end


            // CHECK WRITE RESPONSE
            

            if (bvalid && bready) begin

                if (bresp == 2'b00) begin

                    $display(
                        "[SCOREBOARD] WRITE RESPONSE PASS: BRESP=OKAY"
                    );

                end

                else if (bresp == 2'b10) begin

                    $display(
                        "[SCOREBOARD] WRITE RESPONSE: SLVERR"
                    );

                end

                else begin

                    $error(
                        "[SCOREBOARD] INVALID BRESP=%b",
                        bresp
                    );

                end

            end


           
            // CHECK READ RESPONSE
          

            if (rvalid && rready) begin

                case (araddr[5:2])

                    4'd0: begin

                        if (rdata === expected_reg0)
                            $display(
                                "[SCOREBOARD] READ PASS: ADDR=%h DATA=%h",
                                araddr,
                                rdata
                            );
                        else
                            $error(
                                "[SCOREBOARD] READ FAIL: ADDR=%h EXPECTED=%h ACTUAL=%h",
                                araddr,
                                expected_reg0,
                                rdata
                            );

                    end


                    4'd1: begin

                        if (rdata === expected_reg1)
                            $display(
                                "[SCOREBOARD] READ PASS: ADDR=%h DATA=%h",
                                araddr,
                                rdata
                            );
                        else
                            $error(
                                "[SCOREBOARD] READ FAIL: ADDR=%h EXPECTED=%h ACTUAL=%h",
                                araddr,
                                expected_reg1,
                                rdata
                            );

                    end


                    4'd2: begin

                        if (rdata === expected_reg2)
                            $display(
                                "[SCOREBOARD] READ PASS: ADDR=%h DATA=%h",
                                araddr,
                                rdata
                            );
                        else
                            $error(
                                "[SCOREBOARD] READ FAIL: ADDR=%h EXPECTED=%h ACTUAL=%h",
                                araddr,
                                expected_reg2,
                                rdata
                            );

                    end


                    4'd3: begin

                        if (rdata === expected_reg3)
                            $display(
                                "[SCOREBOARD] READ PASS: ADDR=%h DATA=%h",
                                araddr,
                                rdata
                            );
                        else
                            $error(
                                "[SCOREBOARD] READ FAIL: ADDR=%h EXPECTED=%h ACTUAL=%h",
                                araddr,
                                expected_reg3,
                                rdata
                            );

                    end


                    default: begin

                        if (rdata === '0)
                            $display(
                                "[SCOREBOARD] INVALID READ PASS: DATA=0"
                            );
                        else
                            $error(
                                "[SCOREBOARD] INVALID READ FAIL: DATA=%h",
                                rdata
                            );

                    end

                endcase

            end

        end

    end

endmodule