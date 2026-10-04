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

    task automatic write(
        input logic [ADDR_WIDTH-1:0]   addr,
        input logic [DATA_WIDTH-1:0]   data,
        input logic [DATA_WIDTH/8-1:0] strb
    );
        begin
            // Write address channel
            @(posedge aclk);
            awaddr  <= addr;
            awvalid <= 1'b1;
            @(posedge aclk);              // first edge with VALID visible
            while (!awready)
                @(posedge aclk);
            awvalid <= 1'b0;

            // Write data channel
            wdata  <= data;
            wstrb  <= strb;
            wvalid <= 1'b1;
            @(posedge aclk);
            while (!wready)
                @(posedge aclk);
            wvalid <= 1'b0;

            // Write response channel
            bready <= 1'b1;
            @(posedge aclk);
            while (!bvalid)
                @(posedge aclk);
            last_bresp = bresp;
            if (bresp == 2'b00)
                $display("[MASTER] WRITE SUCCESS ADDR=%h DATA=%h", addr, data);
            else
                $display("[MASTER] WRITE RESPONSE ERROR ADDR=%h BRESP=%b", addr, bresp);
            bready <= 1'b0;
        end
    endtask

    task automatic read(
        input  logic [ADDR_WIDTH-1:0] addr,
        output logic [DATA_WIDTH-1:0] data
    );
        begin
            // Read address channel
            @(posedge aclk);
            araddr  <= addr;
            arvalid <= 1'b1;
            @(posedge aclk);              // first edge with VALID visible
            while (!arready)
                @(posedge aclk);
            arvalid <= 1'b0;

            // Read data channel
            rready <= 1'b1;
            @(posedge aclk);
            while (!rvalid)
                @(posedge aclk);
            data = rdata;
            last_rresp = rresp;
            if (rresp == 2'b00)
                $display("[MASTER] READ SUCCESS ADDR=%h DATA=%h", addr, data);
            else
                $display("[MASTER] READ RESPONSE ERROR ADDR=%h RRESP=%b", addr, rresp);
            rready <= 1'b0;
        end
    endtask
endmodule
