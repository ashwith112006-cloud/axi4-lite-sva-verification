 #include "Vtb_top.h"
#include "verilated.h"
#include "verilated_cov.h"
int main(int argc, char** argv) {
  VerilatedContext* ctx = new VerilatedContext;
  ctx->commandArgs(argc, argv);
  Vtb_top* top = new Vtb_top{ctx};
  while (!ctx->gotFinish()) {
    top->eval();
    if (!top->eventsPending()) break;
    ctx->time(top->nextTimeSlot());
  }
  top->final();
  ctx->coveragep()->write("coverage.dat");
  delete top; delete ctx; return 0;
}
