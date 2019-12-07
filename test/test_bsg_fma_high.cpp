#include "obj_dir/Vbsg_fma_high.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

vluint64_t main_time = 0;

double sc_time_stamp() {
    return main_time;
}

void evalAndTick(Vbsg_fma_high *dut, VerilatedVcdC *tfp){
    tfp->dump(main_time);
    main_time += 5;
    dut->eval();
}

int main(int argc, char **argv){
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);
    VerilatedVcdC *tfp = new VerilatedVcdC{};
    Vbsg_fma_high *dut = new Vbsg_fma_high{};
    dut->trace(tfp, 0);
    tfp->open("simx.vcd");
    dut->clk_i = 0;
    dut->reset_i = 0;
    dut->opA_i = 0;
    dut->opB_i = 0;
    dut->signed_i = 0;
    dut->high_i = 0;
    dut->v_i = 0;
    evalAndTick(dut, tfp);

    dut->reset_i = 1;
    evalAndTick(dut, tfp);
    dut->clk_i = 1;
    evalAndTick(dut, tfp);
    dut->reset_i = 0;
    dut->clk_i = 0;
    evalAndTick(dut, tfp);

    for(int i = 0 ; i < 10000; ++i){
        int32_t opA = rand();
        int32_t opB = rand();

        dut->opA_i = opA;
        dut->opB_i = opB;
        dut->signed_i = 1;
        dut->high_i = 1;
        dut->v_i = 1;
        evalAndTick(dut, tfp);

        dut->clk_i = 1;
        evalAndTick(dut, tfp);
        dut->v_i = 0;
        dut->clk_i = 0;
        evalAndTick(dut, tfp);

        while(!dut->v_o){
            dut->clk_i = 1;
            evalAndTick(dut, tfp);
            dut->clk_i = 0;
            evalAndTick(dut, tfp);
            //getchar();
        }

        int64_t res = int64_t(opA) * int64_t(opB);
        int64_t exp;
        if(dut->high_i)
            exp = res >> 32;
        else
            exp = res & 0xFFFFFFFF;

        if(dut->mul_o != exp){
            printf("opA: %d, opB: %d, mul_o: %d \n", opA, opB, dut->mul_o);
            tfp->close();
            return 1;
        } else {
            puts("Correct!");
        }
    }

    return 0;
}