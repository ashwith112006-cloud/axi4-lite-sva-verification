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
    integer b_delay = 0;
    integer r_delay = 0;

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

    // TIMING RULE: this master changes its outputs and reads the slave's
    // outputs only at the FALLING clock edge (middle of the cycle). The slave
    // and the checkers work at the RISING edge. So nobody reads a signal at
    // the moment it changes, and every simulator gives the same result.
    // A transfer happens at the rising edge that follows a falling edge
    // where VALID and READY were both high.

    task automatic write(
        input logic [ADDR_WIDTH-1:0]   addr,
        input logic [DATA_WIDTH-1:0]   data,
        input logic [DATA_WIDTH/8-1:0] strb
    );
        logic       seen;
        logic [1:0] resp_seen;
        begin
            // Write address channel
            @(negedge aclk);
            awaddr  = addr;
            awvalid = 1'b1;
            seen    = awready;
            @(posedge aclk);
            while (!seen) begin
                @(negedge aclk);
                seen = awready;
                @(posedge aclk);
            end
            @(negedge aclk);
            awvalid = 1'b0;

            // Write data channel
            wdata  = data;
            wstrb  = strb;
            wvalid = 1'b1;
            seen   = wready;
            @(posedge aclk);
            while (!seen) begin
                @(negedge aclk);
                seen = wready;
                @(posedge aclk);
            end
            @(negedge aclk);
            wvalid = 1'b0;

            // Write response channel
            repeat (b_delay) @(negedge aclk);
            bready    = 1'b1;
            seen      = bvalid;
            resp_seen = bresp;
            @(posedge aclk);
            while (!seen) begin
                @(negedge aclk);
                seen      = bvalid;
                resp_seen = bresp;
                @(posedge aclk);
            end
            @(negedge aclk);
            bready = 1'b0;
            last_bresp = resp_seen;
            if (resp_seen == 2'b00)
                $display("[MASTER] WRITE SUCCESS ADDR=%h DATA=%h", addr, data);
            else
                $display("[MASTER] WRITE RESPONSE ERROR ADDR=%h BRESP=%b", addr, resp_seen);
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
            @(negedge aclk);
            araddr  = addr;
            arvalid = 1'b1;
            seen    = arready;
            @(posedge aclk);
            while (!seen) begin
                @(negedge aclk);
                seen = arready;
                @(posedge aclk);
            end
            @(negedge aclk);
            arvalid = 1'b0;

            // Read data channel
            repeat (r_delay) @(negedge aclk);
            rready    = 1'b1;
            seen      = rvalid;
            data_seen = rdata;
            resp_seen = rresp;
            @(posedge aclk);
            while (!seen) begin
                @(negedge aclk);
                seen      = rvalid;
                data_seen = rdata;
                resp_seen = rresp;
                @(posedge aclk);
            end
            @(negedge aclk);
            rready = 1'b0;
            data       = data_seen;
            last_rresp = resp_seen;
            if (resp_seen == 2'b00)
                $display("[MASTER] READ SUCCESS ADDR=%h DATA=%h", addr, data);
            else
                $display("[MASTER] READ RESPONSE ERROR ADDR=%h RRESP=%b", addr, resp_seen);
        end
    endtask
endmodule
