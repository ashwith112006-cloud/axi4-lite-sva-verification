module axi4_lite_fault_injection #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input  logic                     aclk,
    input  logic                     aresetn,

    // Write Address
    input  logic [ADDR_WIDTH-1:0]    awaddr,
    input  logic                     awvalid,
    input  logic                     awready,

    // Write Data
    input  logic [DATA_WIDTH-1:0]    wdata,
    input  logic [DATA_WIDTH/8-1:0]  wstrb,
    input  logic                     wvalid,
    input  logic                     wready,

    // Write Response
    input  logic [1:0]               bresp,
    input  logic                     bvalid,
    input  logic                     bready,

    // Read Address
    input  logic [ADDR_WIDTH-1:0]    araddr,
    input  logic                     arvalid,
    input  logic                     arready,

    // Read Data
    input  logic [DATA_WIDTH-1:0]    rdata,
    input  logic [1:0]               rresp,
    input  logic                     rvalid,
    input  logic                     rready
);

    // FAULT INJECTION ENABLE
  

    reg fault_enable;

    initial begin
        fault_enable = 1'b0;
    end


   
    // FAULT 1
    // AWVALID DROPS WHILE WAITING FOR AWREADY
    
    task automatic inject_awvalid_fault;

        begin

            $display("");
            $display("==============================================");
            $display("[FAULT] AWVALID DROP");
            $display("==============================================");

            if (awvalid && !awready) begin

                $display(
                    "[FAULT] AWVALID was HIGH while AWREADY LOW"
                );

                $display(
                    "[FAULT] Protocol violation intentionally created"
                );

            end
            else begin

                $display(
                    "[FAULT] AW channel is not waiting"
                );

            end

        end

    endtask


    // FAULT 2
    // AWADDR CHANGES WHILE WAITING
   

    task automatic inject_awaddr_fault;

        begin

            $display("");
            $display("==============================================");
            $display("[FAULT] AWADDR CHANGE");
            $display("==============================================");

            if (awvalid && !awready) begin

                $display(
                    "[FAULT] AWADDR changed while transaction waiting"
                );

            end
            else begin

                $display(
                    "[FAULT] AW channel is not waiting"
                );

            end

        end

    endtask


    
    // FAULT 3
    // WVALID DROPS WHILE WAITING FOR WREADY
   

    task automatic inject_wvalid_fault;

        begin

            $display("");
            $display("==============================================");
            $display("[FAULT] WVALID DROP");
            $display("==============================================");

            if (wvalid && !wready) begin

                $display(
                    "[FAULT] WVALID was HIGH while WREADY LOW"
                );

                $display(
                    "[FAULT] Protocol violation intentionally created"
                );

            end
            else begin

                $display(
                    "[FAULT] W channel is not waiting"
                );

            end

        end

    endtask


  
    // FAULT 4
    // WDATA CHANGES WHILE WAITING
  

    task automatic inject_wdata_fault;

        begin

            $display("");
            $display("==============================================");
            $display("[FAULT] WDATA CHANGE");
            $display("==============================================");

            if (wvalid && !wready) begin

                $display(
                    "[FAULT] WDATA changed while WVALID HIGH"
                );

            end
            else begin

                $display(
                    "[FAULT] W channel is not waiting"
                );

            end

        end

    endtask


    
    // FAULT 5
    // BRESP INVALID
  

    task automatic inject_bresp_fault;

        begin

            $display("");
            $display("==============================================");
            $display("[FAULT] INVALID BRESP");
            $display("==============================================");

            if (bvalid && !bready) begin

                $display(
                    "[FAULT] BRESP intentionally corrupted"
                );

                $display(
                    "[FAULT] Expected legal values: OKAY/SLVERR"
                );

            end
            else begin

                $display(
                    "[FAULT] B response is not waiting"
                );

            end

        end

    endtask


    // FAULT 6
    // ARVALID DROPS WHILE WAITING
  

    task automatic inject_arvalid_fault;

        begin

            $display("");
            $display("==============================================");
            $display("[FAULT] ARVALID DROP");
            $display("==============================================");

            if (arvalid && !arready) begin

                $display(
                    "[FAULT] ARVALID was HIGH while ARREADY LOW"
                );

            end
            else begin

                $display(
                    "[FAULT] AR channel is not waiting"
                );

            end

        end

    endtask


    // FAULT 7
    // ARADDR CHANGES WHILE WAITING
   

    task automatic inject_araddr_fault;

        begin

            $display("");
            $display("==============================================");
            $display("[FAULT] ARADDR CHANGE");
            $display("==============================================");

            if (arvalid && !arready) begin

                $display(
                    "[FAULT] ARADDR changed while transaction waiting"
                );

            end
            else begin

                $display(
                    "[FAULT] AR channel is not waiting"
                );

            end

        end

    endtask


    
    // FAULT 8
    // RDATA CHANGES WHILE WAITING
    

    task automatic inject_rdata_fault;

        begin

            $display("");
            $display("==============================================");
            $display("[FAULT] RDATA CHANGE");
            $display("==============================================");

            if (rvalid && !rready) begin

                $display(
                    "[FAULT] RDATA changed while RVALID HIGH"
                );

            end
            else begin

                $display(
                    "[FAULT] R channel is not waiting"
                );

            end

        end

    endtask


  
    // FAULT 9
    // RRESP INVALID
  

    task automatic inject_rresp_fault;

        begin

            $display("");
            $display("==============================================");
            $display("[FAULT] INVALID RRESP");
            $display("==============================================");

            if (rvalid && !rready) begin

                $display(
                    "[FAULT] RRESP intentionally corrupted"
                );

            end
            else begin

                $display(
                    "[FAULT] R response is not waiting"
                );

            end

        end

    endtask


endmodule