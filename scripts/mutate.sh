#!/bin/bash
# Usage: scripts/mutate.sh <MUTANT_NAME>
cd "$(dirname "$0")/.." || exit 1
M=$1
D=/tmp/mut_$M
rm -rf "$D"; mkdir -p "$D"
cp rtl/axi4_lite_slave.sv "$D/slave.sv"
case "$M" in
  MISSING_B)
    sed -i "s/s_axi_bvalid <= 1'b1;/s_axi_bvalid <= 1'b0;/" "$D/slave.sv" ;;
  MISSING_R)
    sed -i "s/s_axi_rvalid <= 1'b1;/s_axi_rvalid <= 1'b0;/" "$D/slave.sv" ;;
  BVALID_DROP)
    sed -i "s/if (s_axi_bvalid && s_axi_bready) begin/if (s_axi_bvalid) begin/" "$D/slave.sv" ;;
  RDATA_UNSTABLE)
    sed -i "s/if (s_axi_rvalid && s_axi_rready) begin/if (s_axi_rvalid \&\& !s_axi_rready) s_axi_rdata <= ~s_axi_rdata;\n            if (s_axi_rvalid \&\& s_axi_rready) begin/" "$D/slave.sv" ;;
  ILLEGAL_BRESP)
    sed -i "/s_axi_bresp <= RESP_OKAY;/s/RESP_OKAY/2'b01/" "$D/slave.sv" ;;
  ILLEGAL_RRESP)
    sed -i "/s_axi_rresp <= RESP_OKAY;/s/RESP_OKAY/2'b01/" "$D/slave.sv" ;;
  STRB_IGNORED)
    sed -i "s/if (wstrb_reg\[[0-3]\])/if (1'b1)/" "$D/slave.sv" ;;
  ADDR_ALIAS)
    sed -i "s/case (\([A-Za-z_]*\)\[31:4\] == 28'd0 ? \1\[5:2\] : 4'hF)/case (\1[5:2])/" "$D/slave.sv" ;;
  *) echo "unknown mutant: $M"; exit 1 ;;
esac
if cmp -s rtl/axi4_lite_slave.sv "$D/slave.sv"; then
  echo "=== MUTANT: $M === MUTATION DID NOT APPLY (pattern not found)"; exit 1
fi
verilator --binary --timing --assert -Wno-fatal -DASSERTIONS --top-module tb_top -Mdir "$D/obj" -o vtb \
  "$D/slave.sv" tb/master/axi4_lite_master.sv tb/monitor/axi4_lite_monitor.sv \
  tb/scoreboard/axi4_lite_scoreboard.sv \
  tb/coverage/axi4_lite_coverage.sv tb/assertions/axi4_lite_sva.sv tb/tb_top.sv 2>&1 | grep "%Error" | head -5
timeout 120 stdbuf -o0 "$D/obj/vtb" > "$D/run.log" 2>&1
echo "=== MUTANT: $M ==="
echo "SVA rules that fired:"
grep -o "\[SVA_FAIL\] [A-Z0-9_]*" "$D/run.log" | sort | uniq -c | sed 's/^/  /'
first=$(grep -m1 "\[SVA_FAIL\]" "$D/run.log")
echo "First SVA failure: ${first:-none}"
grep -E "SCOREBOARD RESULT|EXTRA TESTS|WATCHDOG" "$D/run.log" | sed 's/^/  /'
