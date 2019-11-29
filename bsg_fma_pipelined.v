// -------------------------------------------------------
// -- bsg_fma_pipelined.v
// -------------------------------------------------------
// This module implements a Fused-multiply-add operation for single precision floating-point numbers.
// At present the function of this module is to use 24bit multiplier and 48bit CPA to perform 32bit multiplication.
// -------------------------------------------------------


module bsg_fma_pipelined #(
  parameter bit enable_32_bit_multiplier_p = 1'b1
)(
   input clk_i
  ,input reset_i
  
  // Mode
  // if opcode_i == 1, we perform A[23:0] + B[23:0] + C[47:0]
  // if opcode_i == 0, we perform A[31:0] * B[31:0]
  ,input opcode_i 
  // Operand
  ,input [31:0] opA_i
  ,input [31:0] opB_i
  ,input [47:0] opC_i
  ,input op_v_i

  // Output
  ,output [47:0] res_o
  // Here ports regarding the floating-point should be modified.
  ,output type_o
  ,output v_o
);

// calculate the 24 bit multiplication.
wire [47:0] mul_24res = opA_i[23:0] * opB_i[23:0];




endmodule
