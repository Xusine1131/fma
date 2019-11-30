// Note: This module is an algorithm-level verification.
// So we ignore timing when writing this module.
module bsg_fma #(
    parameter integer exp_p = 8
    ,parameter integer sig_p = 23
    ,localparam width_lp = exp_p + sig_p + 1
)(
    input [width_lp-1:0] opA_i
    ,input [width_lp-1:0] opB_i
    ,output [width_lp-1:0] mul_o
);

localparam mul_width_lp = (sig_p + 1);

wire [sig_p*2+1:0] res_part = opA_i[sig_p:0] * opB_i[sig_p:0];
wire [exp_p-1:0] aux_part;

bsg_fma_aux_adder aux_adder (
    .a_l_i(opA_i[7:0])
    ,.a_h_i(opA_i[31:24])
    ,.b_l_i(opB_i[7:0])
    ,.b_h_i(opB_i[31:24])

    ,.mod_o(aux_part)
);

assign mul_o = {res_part[31:24] + aux_part,res_part[23:0]};

endmodule
