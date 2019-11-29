// Note: This module is an algorithm-level verification.
// So we ignore timing when writing this module.
module fma_test(
    input [31:0] opA_i
    ,input [31:0] opB_i
    ,output [31:0] mul_o
);

wire [47:0] res_part = opA_i[23:0] * opB_i[23:0];
wire [7:0] aux_part;

bsg_fma_aux_adder aux_adder (
    .a_l_i(opA_i[7:0])
    ,.a_h_i(opA_i[31:24])
    ,.b_l_i(opB_i[7:0])
    ,.b_h_i(opB_i[31:24])

    ,.mod_o(aux_part)
);

assign mul_o = {res_part[31:24] + aux_part,res_part[23:0]};

endmodule
