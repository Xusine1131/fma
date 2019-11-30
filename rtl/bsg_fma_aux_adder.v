// -------------------------------------------------------
// -- bsg_fma_aux_adder.v
// -------------------------------------------------------
// This module implements an auxiliary adder for combining modified bits.
// These modified bits exits because 24 bit loses 
// Finally, this module will be replaced by a python-generated module, with CSA to aggregate these bits to save critical path.
// -------------------------------------------------------

module bsg_fma_aux_adder #(
    parameter integer e_p = 8
)(
    input [e_p-1:0] a_l_i
    ,input [e_p-1:0] a_h_i
    //,input a_signed_i
    
    ,input [e_p-1:0] b_l_i
    ,input [e_p-1:0] b_h_i
    //,input b_signed_i

    ,output [e_p-1:0] mod_o
);

wire [2*e_p-1:0][e_p-1:0] mod_bit;

for(genvar i = 0; i < e_p; ++i) begin: TOP_BIT;
    assign mod_bit[i] = ({e_p{b_l_i[i]}} & a_h_i) << i;
end: TOP_BIT

for(genvar i = 0; i < e_p; ++i) begin: BOTTOM_BIT
    assign mod_bit[i+e_p] = ({e_p{b_h_i[i]}} & a_l_i)  << i;
end: BOTTOM_BIT

// Perform Accumulation

wire [e_p-1:0] csa_A;
wire [e_p-1:0] csa_B;

bsg_adder_wallace_tree #(
    .width_p(e_p)
    ,.iter_step_p(2*e_p)
    ,.max_out_size_lp(e_p)
) wallace_tree (
    .op_i(mod_bit)
    ,.resA_o(csa_A)
    ,.resB_o(csa_B)
);

assign mod_o = csa_A + csa_B;

endmodule