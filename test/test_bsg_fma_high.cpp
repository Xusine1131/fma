#include "obj_dir/Vbsg_fma_high.h"
#include "verilated.h"
int main(int argc, char **argv){

    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);
    Vbsg_fma_high *dut = new Vbsg_fma_high{};

    dut->clk_i = 0;
    dut->reset_i = 0;
    dut->opA_i = 0;
    dut->opB_i = 0;
    dut->signed_i = 0;
    dut->high_i = 0;
    dut->v_i = 0;
    dut->eval();

    dut->reset_i = 1;
    dut->eval();
    dut->clk_i = 1;
    dut->eval();
    dut->clk_i = 0;
    dut->eval();

    for(int i = 0 ; i < 10000; ++i){
        uint64_t opA = uint64_t(rand()) * uint64_t(rand());
        uint64_t opB = uint64_t(rand()) * uint64_t(rand());

        dut->opA_i = opA;
        dut->opB_i = opB;
        dut->signed_i = 0;
        dut->v_i = 1;
        dut->eval();

        dut->clk_i = 1;
        dut->eval();
        dut->clk_i = 0;
        dut->eval();

        while(!dut->v_o){
            dut->clk_i = 1;
            dut->eval();
            dut->clk_i = 0;
            dut->eval();
            getchar();
        }

        if(dut->mul_o != uint64_t(opA) * uint64_t(opB)){
            printf("opA: %d, opB: %d, mul_o: %d \b", opA, opB, dut->mul_o);
            return 1;
        } else {
            puts("Correct!");
        }
    }

    return 0;
}