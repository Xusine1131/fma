// -------------------------------------------------------
// -- bsg_fma_aux_adder.v
// -------------------------------------------------------
// This module implements an auxiliary adder for combining modified bits.
// These modified bits exits because 24 bit loses 
// Finally, this module will be replaced by a python-generated module, with CSA to aggregate these bits to save critical path.
// -------------------------------------------------------

module bsg_fma_aux_adder(
    ,input [7:0] a_l_i
    ,input [7:0] a_h_i
    //,input a_signed_i
    
    ,input [7:0] b_l_i
    ,input [7:0] b_h_i
    //,input b_signed_i

    ,output [7:0] mod_o
);

wire [7:0][7:0] top_mod_bit;
wire [7:0][7:0] bottom_mod_bit;

for(genvar i = 0; i < 8; ++i) begin: TOP_BIT;
    assign top_mod_bit[i] = ({8{b_l_i[i]}} & a_h_i) << i;
end: TOP_BIT

for(genvar i = 0; i < 8; ++i) begin: BOTTOM_BIT
    assign bottom_mod_bit[i] = ({8{b_h_i[i]}} & a_l_i)  << i;
end: BOTTOM_BIT

// Perform Accumulation





endmodule