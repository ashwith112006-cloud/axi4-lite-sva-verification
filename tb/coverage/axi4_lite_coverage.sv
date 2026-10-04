module axi4_lite_coverage #(
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

    integer write_reg0_count;
    integer write_reg1_count;
    integer write_reg2_count;
    integer write_reg3_count;
    integer write_invalid_count;

    integer read_reg0_count;
    integer read_reg1_count;
    integer read_reg2_count;
    integer read_reg3_count;
    integer read_invalid_count;

    integer wstrb_1111_count;
    integer wstrb_0001_count;
    integer wstrb_0010_count;
    integer wstrb_0100_count;
    integer wstrb_1000_count;
    integer wstrb_partial_count;
    integer wstrb_0000_count;

    integer bresp_okay_count;
    integer bresp_slverr_count;

    integer rresp_okay_count;
    integer rresp_slverr_count;

    integer total_items;
    integer covered_items;
    real coverage_percentage;


    // INITIALIZATION
  

    initial begin

        write_reg0_count     = 0;
        write_reg1_count     = 0;
        write_reg2_count     = 0;
        write_reg3_count     = 0;
        write_invalid_count  = 0;

        read_reg0_count      = 0;
        read_reg1_count      = 0;
        read_reg2_count      = 0;
        read_reg3_count      = 0;
        read_invalid_count  = 0;

        wstrb_1111_count     = 0;
        wstrb_0001_count     = 0;
        wstrb_0010_count     = 0;
        wstrb_0100_count     = 0;
        wstrb_1000_count     = 0;
        wstrb_partial_count  = 0;
        wstrb_0000_count     = 0;

        bresp_okay_count     = 0;
        bresp_slverr_count   = 0;

        rresp_okay_count     = 0;
        rresp_slverr_count   = 0;

    end


    // COVERAGE SAMPLING
   

    always @(posedge aclk) begin

        if (aresetn) begin

            // WRITE ADDRESS
            if (awvalid && awready) begin

                case (awaddr[31:4] == 28'd0 ? awaddr[5:2] : 4'hF)

                    4'd0:
                        write_reg0_count = write_reg0_count + 1;

                    4'd1:
                        write_reg1_count = write_reg1_count + 1;

                    4'd2:
                        write_reg2_count = write_reg2_count + 1;

                    4'd3:
                        write_reg3_count = write_reg3_count + 1;

                    default:
                        write_invalid_count =
                            write_invalid_count + 1;

                endcase

            end


            // WRITE STROBE
            if (wvalid && wready) begin

                case (wstrb)

                    4'b1111:
                        wstrb_1111_count =
                            wstrb_1111_count + 1;

                    4'b0001:
                        wstrb_0001_count =
                            wstrb_0001_count + 1;

                    4'b0010:
                        wstrb_0010_count =
                            wstrb_0010_count + 1;

                    4'b0100:
                        wstrb_0100_count =
                            wstrb_0100_count + 1;

                    4'b1000:
                        wstrb_1000_count =
                            wstrb_1000_count + 1;

                    4'b0000:
                        wstrb_0000_count =
                            wstrb_0000_count + 1;

                    default:
                        wstrb_partial_count =
                            wstrb_partial_count + 1;

                endcase

            end


            // WRITE RESPONSE
            if (bvalid && bready) begin

                if (bresp == 2'b00)
                    bresp_okay_count =
                        bresp_okay_count + 1;

                else if (bresp == 2'b10)
                    bresp_slverr_count =
                        bresp_slverr_count + 1;

            end


            // READ ADDRESS
            if (arvalid && arready) begin

                case (araddr[31:4] == 28'd0 ? araddr[5:2] : 4'hF)

                    4'd0:
                        read_reg0_count =
                            read_reg0_count + 1;

                    4'd1:
                        read_reg1_count =
                            read_reg1_count + 1;

                    4'd2:
                        read_reg2_count =
                            read_reg2_count + 1;

                    4'd3:
                        read_reg3_count =
                            read_reg3_count + 1;

                    default:
                        read_invalid_count =
                            read_invalid_count + 1;

                endcase

            end


            // READ RESPONSE
            if (rvalid && rready) begin

                if (rresp == 2'b00)
                    rresp_okay_count =
                        rresp_okay_count + 1;

                else if (rresp == 2'b10)
                    rresp_slverr_count =
                        rresp_slverr_count + 1;

            end

        end

    end


    // FINAL COVERAGE REPORT
  

    final begin

        total_items = 21;
        covered_items = 0;

        if (write_reg0_count > 0)
            covered_items = covered_items + 1;

        if (write_reg1_count > 0)
            covered_items = covered_items + 1;

        if (write_reg2_count > 0)
            covered_items = covered_items + 1;

        if (write_reg3_count > 0)
            covered_items = covered_items + 1;

        if (write_invalid_count > 0)
            covered_items = covered_items + 1;


        if (read_reg0_count > 0)
            covered_items = covered_items + 1;

        if (read_reg1_count > 0)
            covered_items = covered_items + 1;

        if (read_reg2_count > 0)
            covered_items = covered_items + 1;

        if (read_reg3_count > 0)
            covered_items = covered_items + 1;

        if (read_invalid_count > 0)
            covered_items = covered_items + 1;


        if (wstrb_1111_count > 0)
            covered_items = covered_items + 1;

        if (wstrb_0001_count > 0)
            covered_items = covered_items + 1;

        if (wstrb_0010_count > 0)
            covered_items = covered_items + 1;

        if (wstrb_0100_count > 0)
            covered_items = covered_items + 1;

        if (wstrb_1000_count > 0)
            covered_items = covered_items + 1;

        if (wstrb_partial_count > 0)
            covered_items = covered_items + 1;

        if (wstrb_0000_count > 0)
            covered_items = covered_items + 1;


        if (bresp_okay_count > 0)
            covered_items = covered_items + 1;

        if (bresp_slverr_count > 0)
            covered_items = covered_items + 1;

        if (rresp_okay_count > 0)
            covered_items = covered_items + 1;

        if (rresp_slverr_count > 0)
            covered_items = covered_items + 1;


        coverage_percentage =
            (covered_items * 100.0) / total_items;


        $display("");
        $display("==============================================");
        $display("       AXI4-LITE FUNCTIONAL COVERAGE");
        $display("==============================================");

        $display("WRITE REG0      = %0d", write_reg0_count);
        $display("WRITE REG1      = %0d", write_reg1_count);
        $display("WRITE REG2      = %0d", write_reg2_count);
        $display("WRITE REG3      = %0d", write_reg3_count);
        $display("WRITE INVALID   = %0d", write_invalid_count);

        $display("");

        $display("READ REG0       = %0d", read_reg0_count);
        $display("READ REG1       = %0d", read_reg1_count);
        $display("READ REG2       = %0d", read_reg2_count);
        $display("READ REG3       = %0d", read_reg3_count);
        $display("READ INVALID    = %0d", read_invalid_count);

        $display("");

        $display("WSTRB 1111      = %0d", wstrb_1111_count);
        $display("WSTRB 0001      = %0d", wstrb_0001_count);
        $display("WSTRB 0010      = %0d", wstrb_0010_count);
        $display("WSTRB 0100      = %0d", wstrb_0100_count);
        $display("WSTRB 1000      = %0d", wstrb_1000_count);
        $display("WSTRB PARTIAL   = %0d", wstrb_partial_count);
        $display("WSTRB 0000      = %0d", wstrb_0000_count);

        $display("");

        $display("BRESP OKAY      = %0d", bresp_okay_count);
        $display("BRESP SLVERR    = %0d", bresp_slverr_count);
        $display("RRESP OKAY      = %0d", rresp_okay_count);
        $display("RRESP SLVERR    = %0d", rresp_slverr_count);

        $display("");

        $display("COVERED BINS    = %0d / %0d",
                 covered_items,
                 total_items);

        $display("COVERAGE        = %0.2f%%",
                 coverage_percentage);

        $display("==============================================");

    end

endmodule