`define SVA_FAIL(NAME) begin sva_fail_total = sva_fail_total + 1; $display("[SVA_FAIL] %s at time %0t", NAME, $time); end

module axi4_lite_sva #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter B_MAX_WAIT = 16,
    parameter R_MAX_WAIT = 16,
    parameter AW_MAX_WAIT = 32,
    parameter W_MAX_WAIT = 32,
    parameter AR_MAX_WAIT = 32
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
    input logic                     rready,
    input integer                   ready_delay
);
    integer sva_fail_total = 0;

    // ---------- helper counters (handshakes seen) ----------
    integer aw_cnt = 0, w_cnt = 0, b_cnt = 0, ar_cnt = 0, r_cnt = 0;
    integer b_wait = 0, r_wait = 0;

    wire b_pending = (aw_cnt > b_cnt) && (w_cnt > b_cnt);
    wire r_pending = (ar_cnt > r_cnt);

    always @(posedge aclk) begin
        if (!aresetn) begin
            aw_cnt <= 0; w_cnt <= 0; b_cnt <= 0;
            ar_cnt <= 0; r_cnt <= 0;
            b_wait <= 0; r_wait <= 0;
        end
        else begin
            if (awvalid && awready) aw_cnt <= aw_cnt + 1;
            if (wvalid  && wready ) w_cnt  <= w_cnt  + 1;
            if (bvalid  && bready ) b_cnt  <= b_cnt  + 1;
            if (arvalid && arready) ar_cnt <= ar_cnt + 1;
            if (rvalid  && rready ) r_cnt  <= r_cnt  + 1;
            if (b_pending && !bvalid) b_wait <= b_wait + 1; else b_wait <= 0;
            if (r_pending && !rvalid) r_wait <= r_wait + 1; else r_wait <= 0;
        end
    end

    // ---------- stability rules: sender must hold VALID and payload ----------
    A01_AWVALID_HOLD: assert property (@(posedge aclk)
        (aresetn && awvalid && !awready) |=> (!aresetn || awvalid))
        else `SVA_FAIL("A01_AWVALID_HOLD")
    A02_AWADDR_STABLE: assert property (@(posedge aclk)
        (aresetn && awvalid && !awready) |=> (!aresetn || $stable(awaddr)))
        else `SVA_FAIL("A02_AWADDR_STABLE")
    A03_WVALID_HOLD: assert property (@(posedge aclk)
        (aresetn && wvalid && !wready) |=> (!aresetn || wvalid))
        else `SVA_FAIL("A03_WVALID_HOLD")
    A04_WDATA_STABLE: assert property (@(posedge aclk)
        (aresetn && wvalid && !wready) |=> (!aresetn || $stable(wdata)))
        else `SVA_FAIL("A04_WDATA_STABLE")
    A05_WSTRB_STABLE: assert property (@(posedge aclk)
        (aresetn && wvalid && !wready) |=> (!aresetn || $stable(wstrb)))
        else `SVA_FAIL("A05_WSTRB_STABLE")
    A06_ARVALID_HOLD: assert property (@(posedge aclk)
        (aresetn && arvalid && !arready) |=> (!aresetn || arvalid))
        else `SVA_FAIL("A06_ARVALID_HOLD")
    A07_ARADDR_STABLE: assert property (@(posedge aclk)
        (aresetn && arvalid && !arready) |=> (!aresetn || $stable(araddr)))
        else `SVA_FAIL("A07_ARADDR_STABLE")
    A08_BVALID_HOLD: assert property (@(posedge aclk)
        (aresetn && bvalid && !bready) |=> (!aresetn || bvalid))
        else `SVA_FAIL("A08_BVALID_HOLD")
    A09_BRESP_STABLE: assert property (@(posedge aclk)
        (aresetn && bvalid && !bready) |=> (!aresetn || $stable(bresp)))
        else `SVA_FAIL("A09_BRESP_STABLE")
    A10_RVALID_HOLD: assert property (@(posedge aclk)
        (aresetn && rvalid && !rready) |=> (!aresetn || rvalid))
        else `SVA_FAIL("A10_RVALID_HOLD")
    A11_RDATA_STABLE: assert property (@(posedge aclk)
        (aresetn && rvalid && !rready) |=> (!aresetn || $stable(rdata)))
        else `SVA_FAIL("A11_RDATA_STABLE")
    A12_RRESP_STABLE: assert property (@(posedge aclk)
        (aresetn && rvalid && !rready) |=> (!aresetn || $stable(rresp)))
        else `SVA_FAIL("A12_RRESP_STABLE")

    // ---------- response legality (this design: OKAY or SLVERR only) ----------
    A13_BRESP_LEGAL: assert property (@(posedge aclk)
        (aresetn && bvalid) |-> (bresp == 2'b00 || bresp == 2'b10))
        else `SVA_FAIL("A13_BRESP_LEGAL")
    A14_RRESP_LEGAL: assert property (@(posedge aclk)
        (aresetn && rvalid) |-> (rresp == 2'b00 || rresp == 2'b10))
        else `SVA_FAIL("A14_RRESP_LEGAL")

    // ---------- reset ----------
    A15_RESET_RESP_LOW: assert property (@(posedge aclk)
        (!aresetn) |=> (!bvalid && !rvalid))
        else `SVA_FAIL("A15_RESET_RESP_LOW")

    // ---------- no response without a request ----------
    A16_NO_B_WITHOUT_WRITE: assert property (@(posedge aclk)
        (aresetn && bvalid) |-> (aw_cnt > b_cnt && w_cnt > b_cnt))
        else `SVA_FAIL("A16_NO_B_WITHOUT_WRITE")
    A17_NO_R_WITHOUT_READ: assert property (@(posedge aclk)
        (aresetn && rvalid) |-> (ar_cnt > r_cnt))
        else `SVA_FAIL("A17_NO_R_WITHOUT_READ")

    // ---------- bounded response (counter based; reports once) ----------
    always @(posedge aclk) begin
        if (aresetn) begin
            A18_B_TIMEOUT: assert (b_wait != B_MAX_WAIT + 1)
                else `SVA_FAIL("A18_B_TIMEOUT")
            A19_R_TIMEOUT: assert (r_wait != R_MAX_WAIT + 1)
                else `SVA_FAIL("A19_R_TIMEOUT")
        end
    end

    // ---------- request-channel READY timing (A20-A22 timeout, A23 early READY) ----------
    integer awv_wait = 0, wv_wait = 0, arv_wait = 0;
    always @(posedge aclk) begin
        if (!aresetn) begin
            awv_wait <= 0; wv_wait <= 0; arv_wait <= 0;
        end else begin
            awv_wait <= (awvalid && !awready) ? awv_wait + 1 : 0;
            wv_wait  <= (wvalid  && !wready ) ? wv_wait  + 1 : 0;
            arv_wait <= (arvalid && !arready) ? arv_wait + 1 : 0;
            A20_AWREADY_TIMEOUT: assert (awv_wait != AW_MAX_WAIT + 1)
                else `SVA_FAIL("A20_AWREADY_TIMEOUT")
            A21_WREADY_TIMEOUT: assert (wv_wait != W_MAX_WAIT + 1)
                else `SVA_FAIL("A21_WREADY_TIMEOUT")
            A22_ARREADY_TIMEOUT: assert (arv_wait != AR_MAX_WAIT + 1)
                else `SVA_FAIL("A22_ARREADY_TIMEOUT")
            A23_EARLY_READY: assert (!((awvalid && awready && awv_wait < ready_delay) ||
                                       (wvalid  && wready  && wv_wait  < ready_delay) ||
                                       (arvalid && arready && arv_wait < ready_delay)))
                else `SVA_FAIL("A23_EARLY_READY")
        end
    end

    // ---------- sanity counters: did each rule's trigger ever happen? ----------
    integer n_aw_stall = 0, n_w_stall = 0, n_ar_stall = 0;
    integer n_b_stall = 0, n_r_stall = 0, n_b_hs = 0, n_r_hs = 0;
    always @(posedge aclk) begin
        if (aresetn) begin
            if (awvalid && !awready) n_aw_stall = n_aw_stall + 1;
            if (wvalid  && !wready ) n_w_stall  = n_w_stall  + 1;
            if (arvalid && !arready) n_ar_stall = n_ar_stall + 1;
            if (bvalid  && !bready ) n_b_stall  = n_b_stall  + 1;
            if (rvalid  && !rready ) n_r_stall  = n_r_stall  + 1;
            if (bvalid  &&  bready ) n_b_hs     = n_b_hs     + 1;
            if (rvalid  &&  rready ) n_r_hs     = n_r_hs     + 1;
        end
    end

    final begin
        $display("");
        $display("==============================================");
        $display("               SVA SUMMARY");
        $display("==============================================");
        $display("SVA FAILS = %0d", sva_fail_total);
        $display("SANITY: AW stall cycles = %0d", n_aw_stall);
        $display("SANITY: W  stall cycles = %0d", n_w_stall);
        $display("SANITY: AR stall cycles = %0d", n_ar_stall);
        $display("SANITY: B  stall cycles = %0d", n_b_stall);
        $display("SANITY: R  stall cycles = %0d", n_r_stall);
        $display("SANITY: B handshakes    = %0d", n_b_hs);
        $display("SANITY: R handshakes    = %0d", n_r_hs);
        $display("(stall count 0 means the matching stability rules were never exercised)");
    end
endmodule
