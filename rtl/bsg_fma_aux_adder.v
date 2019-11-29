// -------------------------------------------------------
// -- bsg_fma_aux_adder.v
// -------------------------------------------------------
// This module implements an auxiliary adder for combining modified bits.
// These modified bits exits because 24 bit loses 
// Finally, this module will be replaced by a python-generated module, with CSA to aggregate these bits to save critical path.
// -------------------------------------------------------

module bsg_fma_aux_adder(
    input [7:0] a_l_i
    ,input [7:0] a_h_i
    //,input a_signed_i
    
    ,input [7:0] b_l_i
    ,input [7:0] b_h_i
    //,input b_signed_i

    ,output [7:0] mod_o
);

wire [15:0][7:0] mod_bit;

for(genvar i = 0; i < 8; ++i) begin: TOP_BIT;
    assign mod_bit[i] = ({8{b_l_i[i]}} & a_h_i) << i;
end: TOP_BIT

for(genvar i = 0; i < 8; ++i) begin: BOTTOM_BIT
    assign mod_bit[i+8] = ({8{b_h_i[i]}} & a_l_i)  << i;
end: BOTTOM_BIT

// Perform Accumulation

wire [7:0] csa_A;
wire [7:0] csa_B;

bsg_adder_wallace_tree #(
    .width_p(8)
    ,.iter_step_p(16)
    ,.max_out_size_lp(8)
) wallace_tree (
    .op_i(mod_bit)
    ,.resA_o(csa_A)
    ,.resB_o(csa_B)
);

assign mod_o = csa_A + csa_B;



endmodule