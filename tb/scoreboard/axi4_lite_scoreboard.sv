module axi4_lite_scoreboard #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input logic                     aclk,
    input logic                     aresetn,
    input logic [ADDR_WIDTH-1:0]    awaddr,
    input logic                     awvalid,
    input logic                     awready,
    input logic [DATA_WIDTH-1:0]    wdata,
    input logic [DATA_WIDTH/8-1:0]  wstrb,
    input logic                     wvalid,
    input logic                     wready,
    input logic [1:0]               bresp,
    input logic                     bvalid,
    input logic                     bready,
    input logic [ADDR_WIDTH-1:0]    araddr,
    input logic                     arvalid,
    input logic                     arready,
    input logic [DATA_WIDTH-1:0]    rdata,
    input logic [1:0]               rresp,
    input logic                     rvalid,
    input logic                     rready
);
    localparam [1:0] RESP_OKAY   = 2'b00;
    localparam [1:0] RESP_SLVERR = 2'b10;

    // Reference model: 4 registers
    logic [DATA_WIDTH-1:0] ref_reg [0:3];

    // Captured write (AW and W can arrive separately)
    logic [ADDR_WIDTH-1:0]   cap_awaddr;
    logic [DATA_WIDTH-1:0]   cap_wdata;
    logic [DATA_WIDTH/8-1:0] cap_wstrb;
    logic aw_got;
    logic w_got;

    // Expected results for the transaction in flight
    logic [1:0]            exp_bresp;
    logic                  bresp_pending;
    logic [ADDR_WIDTH-1:0] rd_addr;
    logic [DATA_WIDTH-1:0] exp_rdata;
    logic [1:0]            exp_rresp;
    logic                  rd_pending;

    integer checks = 0;
    integer errors = 0;
    integer wi, ri, bb;
    logic [DATA_WIDTH-1:0] tmp;

    // Address map from the spec: four word registers at 0x0, 0x4, 0x8, 0xC.
    // Returns -1 for any other address.
    function automatic integer idx_of(input logic [ADDR_WIDTH-1:0] a);
        case (a)
            32'h0000_0000: idx_of = 0;
            32'h0000_0004: idx_of = 1;
            32'h0000_0008: idx_of = 2;
            32'h0000_000C: idx_of = 3;
            default:       idx_of = -1;
        endcase
    endfunction

    always @(posedge aclk) begin
        if (!aresetn) begin
            for (bb = 0; bb < 4; bb = bb + 1)
                ref_reg[bb] = '0;
            aw_got = 1'b0;
            w_got = 1'b0;
            bresp_pending = 1'b0;
            rd_pending = 1'b0;
        end
        else begin
            // Capture write address and write data handshakes
            if (awvalid && awready) begin
                cap_awaddr = awaddr;
                aw_got = 1'b1;
            end
            if (wvalid && wready) begin
                cap_wdata = wdata;
                cap_wstrb = wstrb;
                w_got = 1'b1;
            end

            // When both have arrived, update the model and the expected response
            if (aw_got && w_got) begin
                wi = idx_of(cap_awaddr);
                if (wi >= 0) begin
                    tmp = ref_reg[wi];
                    for (bb = 0; bb < 4; bb = bb + 1)
                        if (cap_wstrb[bb])
                            tmp[8*bb +: 8] = cap_wdata[8*bb +: 8];
                    ref_reg[wi] = tmp;
                    exp_bresp = RESP_OKAY;
                end
                else begin
                    exp_bresp = RESP_SLVERR;
                end
                bresp_pending = 1'b1;
                aw_got = 1'b0;
                w_got = 1'b0;
            end

            // Check the write response
            if (bvalid && bready) begin
                checks = checks + 1;
                if (!bresp_pending) begin
                    errors = errors + 1;
                    $display("[SCOREBOARD] ERROR: B handshake with no write pending");
                end
                else begin
                    if (bresp === exp_bresp)
                        $display("[SCOREBOARD] WRITE RESPONSE PASS: BRESP=%b", bresp);
                    else begin
                        errors = errors + 1;
                        $display("[SCOREBOARD] WRITE RESPONSE FAIL: EXPECTED=%b GOT=%b",
                                 exp_bresp, bresp);
                    end
                    bresp_pending = 1'b0;
                end
            end

            // Capture the read request and work out what the answer should be
            if (arvalid && arready) begin
                rd_addr = araddr;
                ri = idx_of(araddr);
                if (ri >= 0) begin
                    exp_rdata = ref_reg[ri];
                    exp_rresp = RESP_OKAY;
                end
                else begin
                    exp_rdata = '0;
                    exp_rresp = RESP_SLVERR;
                end
                rd_pending = 1'b1;
            end

            // Check the read response
            if (rvalid && rready) begin
                checks = checks + 1;
                if (!rd_pending) begin
                    errors = errors + 1;
                    $display("[SCOREBOARD] ERROR: R handshake with no read pending");
                end
                else begin
                    if (rdata === exp_rdata && rresp === exp_rresp)
                        $display("[SCOREBOARD] READ PASS: ADDR=%h DATA=%h RRESP=%b",
                                 rd_addr, rdata, rresp);
                    else begin
                        errors = errors + 1;
                        $display("[SCOREBOARD] READ FAIL: ADDR=%h EXP_DATA=%h EXP_RRESP=%b GOT_DATA=%h GOT_RRESP=%b",
                                 rd_addr, exp_rdata, exp_rresp, rdata, rresp);
                    end
                    rd_pending = 1'b0;
                end
            end
        end
    end

    final begin
        $display("");
        $display("==============================================");
        $display("            SCOREBOARD SUMMARY");
        $display("==============================================");
        $display("CHECKS = %0d  ERRORS = %0d", checks, errors);
        if (errors == 0 && checks > 0)
            $display("SCOREBOARD RESULT: PASS");
        else
            $display("SCOREBOARD RESULT: FAIL");
    end
endmodule
