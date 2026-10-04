module axi4_lite_sva #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    axi4_lite_if axi
);


    // 1. WRITE ADDRESS CHANNEL
   

    // AWVALID must remain HIGH until AWREADY
    property p_awvalid_stable;
        @(posedge axi.aclk)
        disable iff (!axi.aresetn)
        axi.awvalid && !axi.awready
        |=> axi.awvalid;
    endproperty

    assert property (p_awvalid_stable)
        else $error("[SVA] AWVALID dropped before AWREADY");


    // AWADDR must remain stable while waiting
    property p_awaddr_stable;
        @(posedge axi.aclk)
        disable iff (!axi.aresetn)
        axi.awvalid && !axi.awready
        |=> $stable(axi.awaddr);
    endproperty

    assert property (p_awaddr_stable)
        else $error("[SVA] AWADDR changed before AWREADY");


    // 2. WRITE DATA CHANNEL
  

    // WVALID must remain HIGH until WREADY
    property p_wvalid_stable;
        @(posedge axi.aclk)
        disable iff (!axi.aresetn)
        axi.wvalid && !axi.wready
        |=> axi.wvalid;
    endproperty

    assert property (p_wvalid_stable)
        else $error("[SVA] WVALID dropped before WREADY");


    // WDATA must remain stable while waiting
    property p_wdata_stable;
        @(posedge axi.aclk)
        disable iff (!axi.aresetn)
        axi.wvalid && !axi.wready
        |=> $stable(axi.wdata);
    endproperty

    assert property (p_wdata_stable)
        else $error("[SVA] WDATA changed before WREADY");


    // WSTRB must remain stable while waiting
    property p_wstrb_stable;
        @(posedge axi.aclk)
        disable iff (!axi.aresetn)
        axi.wvalid && !axi.wready
        |=> $stable(axi.wstrb);
    endproperty

    assert property (p_wstrb_stable)
        else $error("[SVA] WSTRB changed before WREADY");


    // 3. WRITE RESPONSE CHANNEL
   

    // BVALID must remain HIGH until BREADY
    property p_bvalid_stable;
        @(posedge axi.aclk)
        disable iff (!axi.aresetn)
        axi.bvalid && !axi.bready
        |=> axi.bvalid;
    endproperty

    assert property (p_bvalid_stable)
        else $error("[SVA] BVALID dropped before BREADY");


    // BRESP must remain stable while waiting
    property p_bresp_stable;
        @(posedge axi.aclk)
        disable iff (!axi.aresetn)
        axi.bvalid && !axi.bready
        |=> $stable(axi.bresp);
    endproperty

    assert property (p_bresp_stable)
        else $error("[SVA] BRESP changed before BREADY");


   
    // 4. READ ADDRESS CHANNEL
  

    // ARVALID must remain HIGH until ARREADY
    property p_arvalid_stable;
        @(posedge axi.aclk)
        disable iff (!axi.aresetn)
        axi.arvalid && !axi.arready
        |=> axi.arvalid;
    endproperty

    assert property (p_arvalid_stable)
        else $error("[SVA] ARVALID dropped before ARREADY");


    // ARADDR must remain stable while waiting
    property p_araddr_stable;
        @(posedge axi.aclk)
        disable iff (!axi.aresetn)
        axi.arvalid && !axi.arready
        |=> $stable(axi.araddr);
    endproperty

    assert property (p_araddr_stable)
        else $error("[SVA] ARADDR changed before ARREADY");


   
    // 5. READ RESPONSE CHANNEL
   

    // RVALID must remain HIGH until RREADY
    property p_rvalid_stable;
        @(posedge axi.aclk)
        disable iff (!axi.aresetn)
        axi.rvalid && !axi.rready
        |=> axi.rvalid;
    endproperty

    assert property (p_rvalid_stable)
        else $error("[SVA] RVALID dropped before RREADY");


   
    property p_rdata_stable;
        @(posedge axi.aclk)
        disable iff (!axi.aresetn)
        axi.rvalid && !axi.rready
        |=> $stable(axi.rdata);
    endproperty

    assert property (p_rdata_stable)
        else $error("[SVA] RDATA changed before RREADY");


    property p_rresp_stable;
        @(posedge axi.aclk)
        disable iff (!axi.aresetn)
        axi.rvalid && !axi.rready
        |=> $stable(axi.rresp);
    endproperty

    assert property (p_rresp_stable)
        else $error("[SVA] RRESP changed before RREADY");


    
    // 6. RESPONSE VALUES
  

    // BRESP can only be OKAY or SLVERR in this design
    property p_valid_bresp;
        @(posedge axi.aclk)
        disable iff (!axi.aresetn)
        axi.bvalid |-> (axi.bresp == 2'b00 ||
                        axi.bresp == 2'b10);
    endproperty

    assert property (p_valid_bresp)
        else $error("[SVA] Invalid BRESP value");


    // RRESP can only be OKAY or SLVERR
    property p_valid_rresp;
        @(posedge axi.aclk)
        disable iff (!axi.aresetn)
        axi.rvalid |-> (axi.rresp == 2'b00 ||
                        axi.rresp == 2'b10);
    endproperty

    assert property (p_valid_rresp)
        else $error("[SVA] Invalid RRESP value");


    // 7. RESET CHECKS
  

    // During reset, responses must not be valid
    property p_no_bvalid_during_reset;
        @(posedge axi.aclk)
        !axi.aresetn |-> !axi.bvalid;
    endproperty

    assert property (p_no_bvalid_during_reset)
        else $error("[SVA] BVALID active during reset");


    property p_no_rvalid_during_reset;
        @(posedge axi.aclk)
        !axi.aresetn |-> !axi.rvalid;
    endproperty

    assert property (p_no_rvalid_during_reset)
        else $error("[SVA] RVALID active during reset");


endmodule