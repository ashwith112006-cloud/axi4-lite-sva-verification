interface axi4_lite_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input logic aclk,
    input logic aresetn
);

   
    // WRITE ADDRESS CHANNEL
   

    logic [ADDR_WIDTH-1:0] awaddr;
    logic                  awvalid;
    logic                  awready;


    // WRITE DATA CHANNEL
  

    logic [DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH/8-1:0] wstrb;
    logic                  wvalid;
    logic                  wready;


    // WRITE RESPONSE CHANNEL
   

    logic [1:0]            bresp;
    logic                  bvalid;
    logic                  bready;


    
    // READ ADDRESS CHANNEL
    
    logic [ADDR_WIDTH-1:0] araddr;
    logic                  arvalid;
    logic                  arready;


    // READ DATA CHANNEL
   

    logic [DATA_WIDTH-1:0] rdata;
    logic [1:0]            rresp;
    logic                  rvalid;
    logic                  rready;


   
    // Useful AXI4-Lite Handshake Signals
    

    // Write address handshake
    wire aw_handshake;

    // Write data handshake
    wire w_handshake;

    // Write response handshake
    wire b_handshake;

    // Read address handshake
    wire ar_handshake;

    // Read data handshake
    wire r_handshake;


    assign aw_handshake = awvalid && awready;
    assign w_handshake  = wvalid  && wready;
    assign b_handshake  = bvalid  && bready;
    assign ar_handshake = arvalid && arready;
    assign r_handshake  = rvalid  && rready;


endinterface