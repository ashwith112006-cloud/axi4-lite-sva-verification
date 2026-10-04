#!/bin/bash
cd "$(dirname "$0")/.." || exit 1
verilator --binary --timing --assert -Wno-fatal --top-module tb_top -Mdir sim/vl_obj -o vtb \
  rtl/axi4_lite_slave.sv tb/master/axi4_lite_master.sv tb/monitor/axi4_lite_monitor.sv \
  tb/scoreboard/axi4_lite_scoreboard.sv tb/fault_injection/axi4_lite_fault_injection.sv \
  tb/coverage/axi4_lite_coverage.sv tb/tb_top.sv 2>&1 | grep -E "%Error" | head -20
timeout 20 stdbuf -o0 ./sim/vl_obj/vtb 2>&1
