// -------------------------------------------------------
// -- test_mulAddRectFN_int_mul.v
// -------------------------------------------------------
// This Verilog file is a testing for integer multiplying with FMA module.
// Different from Softfloat, the testing vector is generated from internal.
// -------------------------------------------------------

`include "HardFloat_consts.vi"
`include "HardFloat_specialize.vi"

module test_mulAddRectFN_int_mul #(
    parameter integer expWidth = 3,
    parameter integer sigWidth = 3
);

reg [expWidth + sigWidth-1:0] a;
reg  [expWidth + sigWidth-1:0] b;
wire [expWidth + sigWidth-1:0] expected_o = a * b;
wire [expWidth + sigWidth-1:0] o;
wire [expWidth + sigWidth:0] fpo;
wire [4:0] flags;

mulAddRecFN#(expWidth, sigWidth)
mulAddRecFN(
    `floatControlWidth'(0),
    2'b00,
    1'b1,
    a,
    b,
    (expWidth + sigWidth)'(0),
    3'b0,
    fpo,
    flags,
    o
);

initial begin
    // We generate 1000 examples to test the function.
    for(int i = 0; i < 1000; ++i) begin
        a = $random;
        b = $random;
        assert(expected_o == o) else 
            $error("Error occurs! a = %d, b = %d", a, b);
    end
end

endmodule


module test_mulAddRecF16;

    test_mulAddRectFN_int_mul#(5, 11) test_mulAddRecF16();

endmodule

module test_mulAddRecF32;

    test_mulAddRectFN_int_mul#(8, 24) test_mulAddRecF32();

endmodule

module test_mulAddRecF64;

    test_mulAddRectFN_int_mul#(11, 53) test_mulAddRecF64();

endmodule

module test_mulAddRecF128;

    test_mulAddRectFN_int_mul#(15, 113) test_mulAddRecF128();

endmodule
