module axi4_lite_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input  logic                     aclk,
    input  logic                     aresetn,
    output logic [ADDR_WIDTH-1:0]    awaddr,
    output logic                     awvalid,
    input  logic                     awready,
    output logic [DATA_WIDTH-1:0]    wdata,
    output logic [DATA_WIDTH/8-1:0]  wstrb,
    output logic                     wvalid,
    input  logic                     wready,
    input  logic [1:0]               bresp,
    input  logic                     bvalid,
    output logic                     bready,
    output logic [ADDR_WIDTH-1:0]    araddr,
    output logic                     arvalid,
    input  logic                     arready,
    input  logic [DATA_WIDTH-1:0]    rdata,
    input  logic [1:0]               rresp,
    input  logic                     rvalid,
    output logic                     rready
);
    // Last response codes seen, so tests can check them
    logic [1:0] last_bresp = 2'b00;
    logic [1:0] last_rresp = 2'b00;

    initial begin
        awaddr  = '0;
        awvalid = 1'b0;
        wdata   = '0;
        wstrb   = '0;
        wvalid  = 1'b0;
        bready  = 1'b0;
        araddr  = '0;
        arvalid = 1'b0;
        rready  = 1'b0;
    end

    // Rule used in every channel below:
    //  - drive signals right after a rising clock edge
    //  - look at the other side's READY/VALID in the MIDDLE of the cycle
    //    (falling edge), when nothing is changing
    //  - if it was high, the handshake happens on the next rising edge

    task automatic write(
        input logic [ADDR_WIDTH-1:0]   addr,
        input logic [DATA_WIDTH-1:0]   data,
        input logic [DATA_WIDTH/8-1:0] strb
    );
        logic       seen;
        logic [1:0] resp_seen;
        begin
            // Write address channel
            @(posedge aclk);
            awaddr  <= addr;
            awvalid <= 1'b1;
            seen = 1'b0;
            while (!seen) begin
                @(negedge aclk);
                seen = awready;
                @(posedge aclk);
            end
            awvalid <= 1'b0;

            // Write data channel
            wdata  <= data;
            wstrb  <= strb;
            wvalid <= 1'b1;
            seen = 1'b0;
            while (!seen) begin
                @(negedge aclk);
                seen = wready;
                @(posedge aclk);
            end
            wvalid <= 1'b0;

            // Write response channel
            bready <= 1'b1;
            seen = 1'b0;
            while (!seen) begin
                @(negedge aclk);
                seen = bvalid;
                resp_seen = bresp;
                @(posedge aclk);
            end
            last_bresp = resp_seen;
            if (resp_seen == 2'b00)
                $display("[MASTER] WRITE SUCCESS ADDR=%h DATA=%h", addr, data);
            else
                $display("[MASTER] WRITE RESPONSE ERROR ADDR=%h BRESP=%b", addr, resp_seen);
            bready <= 1'b0;
        end
    endtask

    task automatic read(
        input  logic [ADDR_WIDTH-1:0] addr,
        output logic [DATA_WIDTH-1:0] data
    );
        logic                  seen;
        logic [1:0]            resp_seen;
        logic [DATA_WIDTH-1:0] data_seen;
        begin
            // Read address channel
            @(posedge aclk);
            araddr  <= addr;
            arvalid <= 1'b1;
            seen = 1'b0;
            while (!seen) begin
                @(negedge aclk);
                seen = arready;
                @(posedge aclk);
            end
            arvalid <= 1'b0;

            // Read data channel
            rready <= 1'b1;
            seen = 1'b0;
            while (!seen) begin
                @(negedge aclk);
                seen = rvalid;
                data_seen = rdata;
                resp_seen = rresp;
                @(posedge aclk);
            end
            data = data_seen;
            last_rresp = resp_seen;
            if (resp_seen == 2'b00)
                $display("[MASTER] READ SUCCESS ADDR=%h DATA=%h", addr, data);
            else
                $display("[MASTER] READ RESPONSE ERROR ADDR=%h RRESP=%b", addr, resp_seen);
            rready <= 1'b0;
        end
    endtask
endmodule
