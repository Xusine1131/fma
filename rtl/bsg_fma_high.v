// -------------------------------------------------------
// -- bsg_fma_high.v
// -------------------------------------------------------
// Use 24bit multiplier and 48bit adder to calculate 32bit multiply.
// -------------------------------------------------------


module bsg_fma_high #(
    parameter integer exp_p = 8
    ,parameter integer sig_p = 24
    ,localparam width_lp = exp_p + sig_p
)(
    input clk_i
    ,input reset_i

    ,input [width_lp-1:0] opA_i
    ,input [width_lp-1:0] opB_i
    ,input signed_i
    ,input high_i
    ,input v_i
    ,output ready_o

    ,output [width_lp-1:0] mul_o
    ,output v_o
);

// >>>>>>>>> STAGE1: 24bit MUL >>>>>>>>>>>>>>>>>>
typedef enum logic [2:0] {eIdle, eMod1, eMod2, eSig1, eSig2} state_e;

state_e state_1_r;

always_ff @(posedge clk_i) begin
    if(reset_i) begin
        state_1_r <= eIdle;
    end
    else unique case(state_1_r)
        eIdle: begin
            if(v_i && high_i) state_1_r <= eMod1;
        end
        eMod1: state_1_r <= eMod2;
        eMod2: state_1_r <= eSig1;
        eSig1: state_1_r <= eSig2;
        eSig2: state_1_r <= eIdle;
        default: begin

        end
    endcase
end

// latch for operand
reg [width_lp:0] opA_r;
reg [width_lp:0] opB_r;

always_ff @(posedge clk_i) begin
    if(reset_i) begin
        opA_r <= '0;
        opB_r <= '0;
    end
    else if(v_i && high_i && state_1_r == eIdle) begin
        opA_r <= {opA_i[width_lp-1] & signed_i,opA_i};
        opB_r <= {opB_i[width_lp-1] & signed_i,opB_i};
    end
end

// ready signal
assign ready_o = state_1_r == eIdle;

// 24bit mul
logic [sig_p-1:0] mul_opA;
logic [sig_p-1:0] mul_opB;
wire [2*sig_p-1:0] mul_res = mul_opA * mul_opB;

// update for mul_opA/B
always_comb unique case(state_1_r)
    eIdle: begin
        mul_opA = opA_i[sig_p-1:0];
        mul_opB = opB_i[sig_p-1:0];
    end
    eMod1: begin
        mul_opA = opA_r[width_lp-1-:sig_p];
        mul_opB = opB_r[width_lp-1-:exp_p];
    end
    eMod2: begin
        mul_opA = opA_r[width_lp-1-:exp_p];
        mul_opB = opB_r[width_lp-1-exp_p:exp_p];
    end
    default: begin
        mul_opA = '0;
        mul_opB = '0;
    end
endcase

// aux multiplier A
wire [exp_p-1:0] aux_mul_a_opA = opA_i[exp_p-1:0];
wire [exp_p-1:0] aux_mul_a_opB = opB_i[width_lp-1-:exp_p];
wire [2*exp_p-1:0] aux_mul_a_res = aux_mul_a_opA * aux_mul_a_opB;

// aux multiplier B
wire [exp_p-1:0] aux_mul_b_opA = opB_i[exp_p-1:0];
wire [exp_p-1:0] aux_mul_b_opB = opA_i[width_lp-1-:exp_p];
wire [2*exp_p-1:0] aux_mul_b_res = aux_mul_b_opA * aux_mul_b_opB;


// Information to send to level 2
reg v_r;
reg [2*sig_p-1:0] mul_r;
reg [2*exp_p:0] aux_mul_r;

always_ff @(posedge clk_i) begin
    if(reset_i) begin
        v_r <= '0;
        mul_r <= '0;
        aux_mul_r <= '0;
    end
    else begin
        if(state_1_r == eIdle)
            v_r <= v_i;
        mul_r <= mul_res;
        aux_mul_r <= aux_mul_a_res + aux_mul_b_res;
    end
end


// >>>>>>>>>>>>>>>>>> STATE2: 48Bit Add <<<<<<<<<<<<<<<<<<<<<<<<<<<

// The state machine of state_2_r
state_e state_2_r;
always_ff @(posedge clk_i) begin
    if(reset_i) begin
        state_2_r <= eIdle;
    end
    else unique case(state_2_r)
        eIdle: if(state_1_r == eMod1) begin
            state_2_r <= eMod1;
        end
        eMod1: state_2_r <= eMod2;
        eMod2: state_2_r <= eSig1;
        eSig1: state_2_r <= eSig2;
        eSig2: state_2_r <= eIdle;
        default: begin

        end
    endcase
end

logic [2*sig_p-1:0] cpa_opA;
logic [2*sig_p-1:0] cpa_opB;
logic opcode;
wire [2*sig_p:0] cpa_res = cpa_opA + ({2*sig_p{opcode}} ^ cpa_opB) + opcode;

// update of cpa operand
wire [2*sig_p:0] acc;

always_comb unique case(state_2_r)
    eIdle: begin
        cpa_opA = mul_r;
        cpa_opB = {aux_mul_r, sig_p'(0)};
        opcode = 1'b0;
    end
    eMod1: begin
        cpa_opA = acc[2*sig_p:width_lp];
        cpa_opB = mul_r;
        opcode = 1'b0;
    end
    eMod2: begin
        cpa_opA = acc;
        cpa_opB = mul_r;
        opcode = 1'b0;
    end
    eSig1: begin
        cpa_opA = acc;
        cpa_opB = opA_r[width_lp-1:0] & {width_lp{opB_r[width_lp]}};
        opcode = opB_r[width_lp];
    end
    eSig2: begin
        cpa_opA = acc;
        cpa_opB = opB_r[width_lp-1:0] & {width_lp{opA_r[width_lp]}};
        opcode = opA_r[width_lp];
    end
    default: begin
        cpa_opA = '0;
        cpa_opB = '0;
        opcode = '0;
    end
endcase

// accumulator
reg [2*sig_p:0] acc_r;
assign acc = acc_r;

// update accumulator
always_ff @(posedge clk_i) begin
    if(reset_i) begin
        acc_r <= cpa_res;
    end
    else acc_r <= cpa_res;
end

// valid 
reg v_2_r;
always_ff @(posedge clk_i) begin
    if(reset_i) begin
        v_2_r <= '0;
    end
    else if(state_2_r == eIdle) begin
        v_2_r <= v_r;
    end
end

always_ff @(posedge clk_i) begin
    //$display("=========================");
    //$display("v_r:%b",v_r);
    //$display("state_1_r:%s", state_1_r.name());
    //$display("v_2_r:%b",v_2_r);
    //$display("state_2_r:%s", state_1_r.name());
end

assign mul_o = acc_r[width_lp-1:0];
assign v_o = v_2_r && state_2_r == eIdle;

endmodule
