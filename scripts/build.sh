#!/bin/bash
cd "$(dirname "$0")/.." || exit 1
iverilog -g2012 -o sim/axi4_lite.out rtl/axi4_lite_slave.sv tb/master/axi4_lite_master.sv tb/monitor/axi4_lite_monitor.sv tb/scoreboard/axi4_lite_scoreboard.sv tb/coverage/axi4_lite_coverage.sv tb/tb_top.sv && vvp sim/axi4_lite.out
