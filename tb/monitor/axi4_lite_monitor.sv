module axi4_lite_monitor #(
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

    // Stored Write Information
    

    logic [ADDR_WIDTH-1:0]   monitored_awaddr;
    logic [DATA_WIDTH-1:0]   monitored_wdata;
    logic [DATA_WIDTH/8-1:0] monitored_wstrb;

    logic aw_seen;
    logic w_seen;


    // Monitor
 

    always @(posedge aclk) begin

        if (!aresetn) begin

            monitored_awaddr = '0;
            monitored_wdata  = '0;
            monitored_wstrb  = '0;

            aw_seen = 1'b0;
            w_seen  = 1'b0;

        end

        else begin

            // WRITE ADDRESS HANDSHAKE
         

            if (awvalid && awready) begin

                monitored_awaddr = awaddr;
                aw_seen = 1'b1;

                $display(
                    "[MONITOR] AW HANDSHAKE: ADDR=%h",
                    awaddr
                );

            end

            // WRITE DATA HANDSHAKE
            

            if (wvalid && wready) begin

                monitored_wdata = wdata;
                monitored_wstrb = wstrb;
                w_seen = 1'b1;

                $display(
                    "[MONITOR] W HANDSHAKE: DATA=%h WSTRB=%b",
                    wdata,
                    wstrb
                );

            end


          
            // WRITE RESPONSE
           

            if (bvalid && bready) begin

                $display(
                    "[MONITOR] WRITE COMPLETE: ADDR=%h DATA=%h WSTRB=%b BRESP=%b",
                    monitored_awaddr,
                    monitored_wdata,
                    monitored_wstrb,
                    bresp
                );

                aw_seen = 1'b0;
                w_seen  = 1'b0;

            end


        
            // READ ADDRESS HANDSHAKE
            

            if (arvalid && arready) begin

                $display(
                    "[MONITOR] AR HANDSHAKE: ADDR=%h",
                    araddr
                );

            end


           
            // READ RESPONSE
            

            if (rvalid && rready) begin

                $display(
                    "[MONITOR] READ COMPLETE: DATA=%h RRESP=%b",
                    rdata,
                    rresp
                );

            end

        end

    end

endmodule