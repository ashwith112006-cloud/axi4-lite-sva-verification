module axi4_lite_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input  logic                     aclk,
    input  logic                     aresetn,


    // AXI4-Lite Write Address
   
    input  logic [ADDR_WIDTH-1:0]    s_axi_awaddr,
    input  logic                     s_axi_awvalid,
    output logic                     s_axi_awready,

    // AXI4-Lite Write Data
    
    input  logic [DATA_WIDTH-1:0]    s_axi_wdata,
    input  logic [DATA_WIDTH/8-1:0]  s_axi_wstrb,
    input  logic                     s_axi_wvalid,
    output logic                     s_axi_wready,

    // AXI4-Lite Write Response
  
    output logic [1:0]               s_axi_bresp,
    output logic                     s_axi_bvalid,
    input  logic                     s_axi_bready,

   
    // AXI4-Lite Read Address
   
    input  logic [ADDR_WIDTH-1:0]    s_axi_araddr,
    input  logic                     s_axi_arvalid,
    output logic                     s_axi_arready,

    // AXI4-Lite Read Data
    
    output logic [DATA_WIDTH-1:0]    s_axi_rdata,
    output logic [1:0]               s_axi_rresp,
    output logic                     s_axi_rvalid,
    input  logic                     s_axi_rready
);

   
    // AXI4 Response Encoding
    
    localparam logic [1:0] RESP_OKAY   = 2'b00;
    localparam logic [1:0] RESP_SLVERR = 2'b10;

    // Register Bank
    // Address:
    //
    // 0x00 -> REG0
    // 0x04 -> REG1
    // 0x08 -> REG2
    // 0x0C -> REG3
   

    logic [DATA_WIDTH-1:0] reg0;
    logic [DATA_WIDTH-1:0] reg1;
    logic [DATA_WIDTH-1:0] reg2;
    logic [DATA_WIDTH-1:0] reg3;

   
    // Write Channel Internal Registers
   

    logic [ADDR_WIDTH-1:0] awaddr_reg;
    logic [DATA_WIDTH-1:0] wdata_reg;
    logic [DATA_WIDTH/8-1:0] wstrb_reg;

    logic aw_received;
    logic w_received;

    // Write Address Ready
    // Accept address only when previous address
    // has already been consumed.
  

    assign s_axi_awready = !aw_received && !s_axi_bvalid;

    // Write Data Ready
    
    assign s_axi_wready = !w_received && !s_axi_bvalid;

    
    // Read Address Ready
    // Only accept a new read when previous read
    // response has been consumed.
   

    assign s_axi_arready = !s_axi_rvalid;

    
    // Sequential Logic
    

    always_ff @(posedge aclk) begin

        if (!aresetn) begin

            // Reset register bank
            reg0 <= '0;
            reg1 <= '0;
            reg2 <= '0;
            reg3 <= '0;

            // Reset write channel
            awaddr_reg <= '0;
            wdata_reg  <= '0;
            wstrb_reg  <= '0;

            aw_received <= 1'b0;
            w_received  <= 1'b0;

            // Reset responses
            s_axi_bvalid <= 1'b0;
            s_axi_bresp  <= RESP_OKAY;

            // Reset read channel
            s_axi_rvalid <= 1'b0;
            s_axi_rdata  <= '0;
            s_axi_rresp  <= RESP_OKAY;

        end

        else begin

            // Capture Write Address
          

            if (s_axi_awvalid && s_axi_awready) begin

                awaddr_reg <= s_axi_awaddr;
                aw_received <= 1'b1;

            end

            
            // Capture Write Data
           

            if (s_axi_wvalid && s_axi_wready) begin

                wdata_reg <= s_axi_wdata;
                wstrb_reg <= s_axi_wstrb;
                w_received <= 1'b1;

            end

            // Perform Write
            //
            // AXI allows AW and W to arrive independently.
            // Therefore we wait until BOTH are received.
            

            if (aw_received && w_received && !s_axi_bvalid) begin

                case (awaddr_reg[31:4] == 28'd0 ? awaddr_reg[5:2] : 4'hF)

                    4'd0: begin

                        if (wstrb_reg[0])
                            reg0[7:0] <= wdata_reg[7:0];

                        if (wstrb_reg[1])
                            reg0[15:8] <= wdata_reg[15:8];

                        if (wstrb_reg[2])
                            reg0[23:16] <= wdata_reg[23:16];

                        if (wstrb_reg[3])
                            reg0[31:24] <= wdata_reg[31:24];

                        s_axi_bresp <= RESP_OKAY;

                    end

                    4'd1: begin

                        if (wstrb_reg[0])
                            reg1[7:0] <= wdata_reg[7:0];

                        if (wstrb_reg[1])
                            reg1[15:8] <= wdata_reg[15:8];

                        if (wstrb_reg[2])
                            reg1[23:16] <= wdata_reg[23:16];

                        if (wstrb_reg[3])
                            reg1[31:24] <= wdata_reg[31:24];

                        s_axi_bresp <= RESP_OKAY;

                    end

                    4'd2: begin

                        if (wstrb_reg[0])
                            reg2[7:0] <= wdata_reg[7:0];

                        if (wstrb_reg[1])
                            reg2[15:8] <= wdata_reg[15:8];

                        if (wstrb_reg[2])
                            reg2[23:16] <= wdata_reg[23:16];

                        if (wstrb_reg[3])
                            reg2[31:24] <= wdata_reg[31:24];

                        s_axi_bresp <= RESP_OKAY;

                    end

                    4'd3: begin

                        if (wstrb_reg[0])
                            reg3[7:0] <= wdata_reg[7:0];

                        if (wstrb_reg[1])
                            reg3[15:8] <= wdata_reg[15:8];

                        if (wstrb_reg[2])
                            reg3[23:16] <= wdata_reg[23:16];

                        if (wstrb_reg[3])
                            reg3[31:24] <= wdata_reg[31:24];

                        s_axi_bresp <= RESP_OKAY;

                    end

                    default: begin

                        s_axi_bresp <= RESP_SLVERR;

                    end

                endcase

                // Generate write response
                s_axi_bvalid <= 1'b1;

                // Clear captured transaction
                aw_received <= 1'b0;
                w_received  <= 1'b0;

            end

            // Write Response Handshake
           

            if (s_axi_bvalid && s_axi_bready) begin

                s_axi_bvalid <= 1'b0;

            end

            
            // READ TRANSACTION
           

            if (s_axi_arvalid && s_axi_arready) begin

                case (s_axi_araddr[31:4] == 28'd0 ? s_axi_araddr[5:2] : 4'hF)

                    4'd0: begin
                        s_axi_rdata <= reg0;
                        s_axi_rresp <= RESP_OKAY;
                    end

                    4'd1: begin
                        s_axi_rdata <= reg1;
                        s_axi_rresp <= RESP_OKAY;
                    end

                    4'd2: begin
                        s_axi_rdata <= reg2;
                        s_axi_rresp <= RESP_OKAY;
                    end

                    4'd3: begin
                        s_axi_rdata <= reg3;
                        s_axi_rresp <= RESP_OKAY;
                    end

                    default: begin
                        s_axi_rdata <= '0;
                        s_axi_rresp <= RESP_SLVERR;
                    end

                endcase

                // Generate read response
                s_axi_rvalid <= 1'b1;

            end

            // Read Response Handshake
           

            if (s_axi_rvalid && s_axi_rready) begin

                s_axi_rvalid <= 1'b0;

            end

        end

    end

endmodule